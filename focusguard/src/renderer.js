'use strict';

// ── Security: freeze prototype to prevent pollution attacks ──────────────────
(function() {
  const np = Object.getPrototypeOf({});
  try { Object.freeze(np); } catch(_) {}
})();

// ── Safe helpers ──────────────────────────────────────────────────────────────
function sanitize(str) {
  if (typeof str !== 'string') return '';
  return str.replace(/[<>&"'`]/g, c => (
    {'<':'&lt;','>':'&gt;','&':'&amp;','"':'&quot;',"'":'&#x27;','`':'&#x60;'}[c]
  )).slice(0, 512);
}
function safeInt(val, min, max, def) {
  const n = parseInt(val, 10);
  return (!isNaN(n) && n >= min && n <= max) ? n : def;
}
const _lastClick = Object.create(null);
function rateLimit(key, ms) {
  const now = Date.now();
  if (_lastClick[key] && now - _lastClick[key] < ms) return false;
  _lastClick[key] = now;
  return true;
}

// ── CONFIG ────────────────────────────────────────────────────────────────────
const CONFIG = { focusMins: 75, breakMins: 20, alarmReps: 3 };

// ── State ─────────────────────────────────────────────────────────────────────
const state = {
  running: false, paused: false, isFocus: true,
  secsLeft: CONFIG.focusMins * 60,
  sessionsCompleted: 0, totalFocusSecs: 0, cycles: 0,
  history: [], alarmActive: false, volume: 0.7, soundEnabled: true, autoStart: true
};

let tickInterval = null;
let alarmTimeouts = [];
let audioCtx = null;
const RING_CIRC = 2 * Math.PI * 104;

// ── Web Audio API (generates sound — no external files) ───────────────────────
function getAudioCtx() {
  if (!audioCtx) {
    try { audioCtx = new (window.AudioContext || window.webkitAudioContext)(); }
    catch (_) { return null; }
  }
  if (audioCtx.state === 'suspended') audioCtx.resume();
  return audioCtx;
}
function playTone(freq, dur, type, vol) {
  const ctx = getAudioCtx();
  if (!ctx || !state.soundEnabled) return;
  try {
    const osc  = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.connect(gain);
    gain.connect(ctx.destination);
    osc.type = type || 'sine';
    osc.frequency.setValueAtTime(freq, ctx.currentTime);
    osc.frequency.exponentialRampToValueAtTime(freq * 0.82, ctx.currentTime + dur);
    gain.gain.setValueAtTime(0, ctx.currentTime);
    gain.gain.linearRampToValueAtTime(Math.min((vol || 0.5) * state.volume, 1), ctx.currentTime + 0.012);
    gain.gain.exponentialRampToValueAtTime(0.001, ctx.currentTime + dur);
    osc.start(ctx.currentTime);
    osc.stop(ctx.currentTime + dur + 0.01);
  } catch (_) {}
}
function clearAlarmTimeouts() {
  alarmTimeouts.forEach(t => clearTimeout(t));
  alarmTimeouts = [];
}
function playAlarm(isFocusAlarm) {
  if (!state.soundEnabled) return;
  clearAlarmTimeouts();
  let count = 0;
  function ring() {
    if (count >= CONFIG.alarmReps) return;
    if (isFocusAlarm) {
      // Ascending chime → start working
      playTone(523.25, 0.15, 'triangle', 0.55);
      alarmTimeouts.push(setTimeout(() => playTone(659.25, 0.15, 'triangle', 0.55), 160));
      alarmTimeouts.push(setTimeout(() => playTone(783.99, 0.28,  'triangle', 0.65), 320));
    } else {
      // Descending chime → relax
      playTone(880, 0.2, 'sine', 0.5);
      alarmTimeouts.push(setTimeout(() => playTone(698.46, 0.2, 'sine', 0.5), 250));
      alarmTimeouts.push(setTimeout(() => playTone(587.33, 0.32, 'sine', 0.5), 500));
    }
    count++;
    if (count < CONFIG.alarmReps) alarmTimeouts.push(setTimeout(ring, 1300));
  }
  ring();
}
function playTick() {
  if (state.secsLeft <= 10 && state.secsLeft > 0 && state.soundEnabled) {
    playTone(900, 0.04, 'square', 0.08);
  }
}
function playClick() { playTone(440, 0.055, 'sine', 0.13); }

// ── DOM ───────────────────────────────────────────────────────────────────────
const $ = id => document.getElementById(id);

function updateRing() {
  const total  = (state.isFocus ? CONFIG.focusMins : CONFIG.breakMins) * 60;
  const frac   = total > 0 ? state.secsLeft / total : 0;
  $('ringProg').style.strokeDashoffset = RING_CIRC * (1 - frac);
}
function fmt(secs) {
  const m = Math.floor(secs / 60), s = secs % 60;
  return `${String(m).padStart(2,'0')}:${String(s).padStart(2,'0')}`;
}
function renderTimeline() {
  const dots = $('timelineDots');
  dots.innerHTML = '';
  state.history.forEach(h => {
    const d = document.createElement('div');
    d.className = `t-dot ${h === 'focus' ? 'focus-done' : 'break-done'}`;
    d.title = h === 'focus' ? 'Completed focus session' : 'Completed break';
    dots.appendChild(d);
  });
  if (state.running) {
    const cur = document.createElement('div');
    cur.className = 't-dot current';
    cur.title = state.isFocus ? 'Current focus session' : 'Current break';
    dots.appendChild(cur);
  }
}
function updateDisplay() {
  $('timeDisplay').textContent = fmt(state.secsLeft);
  updateRing();
  $('modeLabel').textContent = state.isFocus ? 'FOCUS SESSION' : 'BREAK TIME';

  const fh = Math.floor(state.totalFocusSecs / 3600);
  const fm = Math.floor((state.totalFocusSecs % 3600) / 60);
  $('sessCount').textContent = state.sessionsCompleted;
  $('focusTime').textContent = `${fh}h ${fm}m`;
  $('cycleCount').textContent = state.cycles;

  const startBtn = $('startStopBtn');
  const icon = $('startIcon');
  if (state.running && !state.paused) {
    $('startLabel').textContent = 'PAUSE';
    icon.innerHTML = '<path d="M5.5 3.5A1.5 1.5 0 017 5v6a1.5 1.5 0 01-3 0V5a1.5 1.5 0 011.5-1.5zm5 0A1.5 1.5 0 0112 5v6a1.5 1.5 0 01-3 0V5a1.5 1.5 0 011.5-1.5z"/>';
  } else {
    $('startLabel').textContent = state.paused ? 'RESUME' : 'START';
    icon.innerHTML = '<path d="M11.596 8.697L4.707 12.46A1 1 0 013 11.565V4.435a1 1 0 011.707-.714l6.889 3.765a1 1 0 010 1.712z"/>';
  }

  const badge = $('statusBadge');
  if (state.paused)          { $('statusText').textContent = 'PAUSED';  badge.classList.add('paused'); }
  else if (!state.running)   { $('statusText').textContent = 'READY';   badge.classList.remove('paused'); }
  else if (state.isFocus)    { $('statusText').textContent = 'FOCUSING'; badge.classList.remove('paused'); }
  else                       { $('statusText').textContent = 'ON BREAK'; badge.classList.remove('paused'); }

  if (state.isFocus) document.body.classList.remove('break-mode');
  else               document.body.classList.add('break-mode');

  document.title = `${fmt(state.secsLeft)} — ${state.isFocus ? 'Focus' : 'Break'} | FocusGuard`;

  renderTimeline();

  // Send state to main process for tray update
  if (window.focusAPI) {
    window.focusAPI.send('timer-state-update', {
      running: state.running, paused: state.paused, isFocus: state.isFocus,
      secsLeft: state.secsLeft, sessionsCompleted: state.sessionsCompleted,
      focusMins: CONFIG.focusMins, breakMins: CONFIG.breakMins
    });
  }
}

// ── Timer logic ───────────────────────────────────────────────────────────────
function tick() {
  if (!state.running || state.paused) return;
  if (state.secsLeft > 0) {
    state.secsLeft--;
    if (state.isFocus) state.totalFocusSecs++;
    playTick();
    updateDisplay();
  } else {
    onSessionEnd();
  }
}

function onSessionEnd() {
  clearInterval(tickInterval);
  tickInterval = null;
  state.running = false;

  state.history.push(state.isFocus ? 'focus' : 'break');
  if (state.isFocus) state.sessionsCompleted++;
  state.cycles = state.history.filter(h => h === 'break').length;

  const wasBreak = !state.isFocus;
  state.isFocus  = !state.isFocus;
  state.secsLeft = (state.isFocus ? CONFIG.focusMins : CONFIG.breakMins) * 60;

  // Flash display
  const disp = $('timeDisplay');
  disp.classList.add('alarm-flash');
  setTimeout(() => disp.classList.remove('alarm-flash'), 2600);

  playAlarm(state.isFocus); // ascending=focus, descending=break

  showAlarmBanner();

  // Tell main process to send native notification + flash taskbar
  if (window.focusAPI) {
    window.focusAPI.send('session-alarm', {
      newMode: state.isFocus ? 'focus' : 'break',
      sessions: state.sessionsCompleted
    });
    window.focusAPI.send('window-flash', null);
  }

  updateDisplay();

  if (state.autoStart) {
    setTimeout(() => { if (!state.running && state.autoStart) startTimer(); },
      state.isFocus ? 3200 : 4000);
  }
}

function startTimer() {
  if (state.running && !state.paused) return;
  getAudioCtx();
  state.running = true;
  state.paused  = false;
  tickInterval  = setInterval(tick, 1000);
  updateDisplay();
}
function pauseTimer() {
  if (!state.running) return;
  state.paused = true;
  updateDisplay();
}
function resumeTimer() {
  if (!state.running || !state.paused) return;
  state.paused = false;
  updateDisplay();
}

// ── Public API (called by HTML onclick attrs and shortcut handler) ─────────────
window.app = {

  toggleStartStop() {
    if (!rateLimit('ss', 280)) return;
    playClick();
    if (!state.running)       startTimer();
    else if (!state.paused)   pauseTimer();
    else                      resumeTimer();
  },

  async skipSession() {
    if (!rateLimit('skip', 500)) return;
    let ok = true;
    if (window.focusAPI) {
      ok = await window.focusAPI.invoke('show-confirm-dialog', {
        title: 'Skip Session', message: 'Skip current session and move to the next?'
      });
    } else {
      ok = confirm('Skip current session?');
    }
    if (!ok) return;
    playClick();
    clearInterval(tickInterval); tickInterval = null;
    state.history.push(state.isFocus ? 'focus' : 'break');
    if (state.isFocus) state.sessionsCompleted++;
    state.cycles = state.history.filter(h => h === 'break').length;
    state.isFocus = !state.isFocus;
    state.secsLeft = (state.isFocus ? CONFIG.focusMins : CONFIG.breakMins) * 60;
    state.running = false; state.paused = false;
    updateDisplay();
  },

  async resetTimer() {
    if (!rateLimit('reset', 400)) return;
    if (state.sessionsCompleted > 0 || state.running) {
      let ok = true;
      if (window.focusAPI) {
        ok = await window.focusAPI.invoke('show-confirm-dialog', {
          title: 'Reset Timer', message: 'Reset all sessions and the timer?'
        });
      } else {
        ok = confirm('Reset all sessions?');
      }
      if (!ok) return;
    }
    playClick();
    clearInterval(tickInterval); clearAlarmTimeouts();
    tickInterval = null;
    Object.assign(state, {
      running: false, paused: false, isFocus: true,
      secsLeft: CONFIG.focusMins * 60,
      sessionsCompleted: 0, totalFocusSecs: 0, cycles: 0,
      history: [], alarmActive: false
    });
    dismissAlarm();
    document.body.classList.remove('break-mode');
    updateDisplay();
    document.title = 'FocusGuard — Deep Work Timer';
  },

  dismissAlarm,
  toggleSettings,
  applySettings
};

// ── Alarm banner ──────────────────────────────────────────────────────────────
function showAlarmBanner() {
  const banner = $('alarmBanner');
  banner.classList.add('visible');
  const msg = state.isFocus
    ? `⚡ Break over! Focus for ${CONFIG.focusMins} minutes.`
    : `🌿 Session done! Rest for ${CONFIG.breakMins} minutes.`;
  $('alarmMsg').textContent = sanitize(msg);
  $('alarmIcon').textContent = state.isFocus ? '⚡' : '🌿';
  state.alarmActive = true;
  setTimeout(() => { if (state.alarmActive) dismissAlarm(); }, 18000);
}
function dismissAlarm() {
  $('alarmBanner').classList.remove('visible');
  state.alarmActive = false;
  clearAlarmTimeouts();
}

// ── Settings ───────────────────────────────────────────────────────────────────
function toggleSettings() {
  if (!rateLimit('sets', 200)) return;
  $('settingsPanel').classList.toggle('open');
}
function applySettings() {
  if (!rateLimit('apply', 500)) return;
  const fd = safeInt($('focusDur').value, 1, 240, 75);
  const bd = safeInt($('breakDur').value, 1, 120, 20);
  const ar = safeInt($('alarmRep').value, 1, 10, 3);
  CONFIG.focusMins = fd; CONFIG.breakMins = bd; CONFIG.alarmReps = ar;
  $('focusDur').value = fd; $('breakDur').value = bd; $('alarmRep').value = ar;
  $('settingsPanel').classList.remove('open');
  if (window.focusAPI) window.focusAPI.send('update-config', { focusMins: fd, breakMins: bd });
  app.resetTimer();
  playClick();
}

// ── Event listeners ───────────────────────────────────────────────────────────
$('autoStart').addEventListener('change',    function() { state.autoStart    = this.checked; });
$('soundEnabled').addEventListener('change', function() { state.soundEnabled = this.checked; });
$('volSlider').addEventListener('input',     function() { state.volume       = parseFloat(this.value) || 0; });

document.addEventListener('keydown', e => {
  if (e.target.tagName === 'INPUT') return;
  if (e.repeat) return;
  const ctrl = e.ctrlKey || e.metaKey;
  if (e.code === 'Space' && !ctrl)  { e.preventDefault(); app.toggleStartStop(); }
  if (e.code === 'KeyK' && ctrl)    { e.preventDefault(); app.skipSession(); }
  if (e.code === 'KeyR' && ctrl)    { e.preventDefault(); app.resetTimer(); }
  if (e.code === 'KeyM' && ctrl)    {
    const s = $('soundEnabled'); s.checked = !s.checked;
    state.soundEnabled = s.checked; playClick();
  }
});

// ── IPC from main process (keyboard media keys / menu items) ─────────────────
if (window.focusAPI) {
  window.focusAPI.on('shortcut', action => {
    if (action === 'toggle') app.toggleStartStop();
    if (action === 'skip')   app.skipSession();
    if (action === 'reset')  app.resetTimer();
    if (action === 'mute') {
      const s = $('soundEnabled'); s.checked = !s.checked;
      state.soundEnabled = s.checked; playClick();
    }
  });
}

// ── Init ──────────────────────────────────────────────────────────────────────
updateDisplay();
