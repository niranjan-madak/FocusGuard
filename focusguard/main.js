'use strict';

const {
  app, BrowserWindow, Tray, Menu, ipcMain,
  Notification, globalShortcut, nativeImage,
  shell, dialog, powerSaveBlocker
} = require('electron');
const path = require('path');
const os   = require('os');

// ── Security: Disable remote module + kill Node access in renderer ──────────
app.on('web-contents-created', (_, contents) => {
  contents.on('will-navigate', (e, url) => {
    const allowed = new URL(url).protocol === 'file:';
    if (!allowed) { e.preventDefault(); }
  });
  contents.setWindowOpenHandler(() => ({ action: 'deny' }));
  contents.on('did-attach-webview', (e) => { e.preventDefault(); });
});
// Prevent second instance
if (!app.requestSingleInstanceLock()) { app.quit(); process.exit(0); }

// ── State ────────────────────────────────────────────────────────────────────
let mainWindow  = null;
let tray        = null;
let psBlockerId = null;
let quitting    = false;

let timerState = {
  running: false, paused: false, isFocus: true,
  secsLeft: 75 * 60,
  focusMins: 75, breakMins: 20,
  sessionsCompleted: 0, totalFocusSecs: 0, cycles: 0
};

// ── Icon helpers ─────────────────────────────────────────────────────────────
function assetPath(name) {
  return path.join(
    app.isPackaged ? process.resourcesPath : __dirname,
    'assets', name
  );
}
function getTrayIcon() {
  try {
    const img = nativeImage.createFromPath(assetPath('tray-icon.png'));
    if (process.platform === 'darwin') return img.resize({ width: 18, height: 18 });
    return img.resize({ width: 16, height: 16 });
  } catch { return nativeImage.createEmpty(); }
}
function getAppIcon() {
  try { return nativeImage.createFromPath(assetPath('icon.png')); }
  catch { return nativeImage.createEmpty(); }
}

// ── Create BrowserWindow ─────────────────────────────────────────────────────
function createWindow() {
  mainWindow = new BrowserWindow({
    width: 500,
    height: 760,
    minWidth:  460,
    minHeight: 680,
    title: 'FocusGuard',
    icon: getAppIcon(),
    backgroundColor: '#05070f',
    show: false,
    center: true,
    resizable: true,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration:              false,   // No Node in renderer
      contextIsolation:             true,    // Isolated context
      sandbox:                      true,    // Sandbox renderer process
      webSecurity:                  true,    // Enforce same-origin
      allowRunningInsecureContent:  false,
      experimentalFeatures:         false,
      navigateOnDragDrop:           false,
      spellcheck:                   false,
      devTools: !app.isPackaged,
    },
  });

  // ── Content-Security-Policy via session ──────────────────────────────────
  mainWindow.webContents.session.webRequest.onHeadersReceived((details, cb) => {
    cb({
      responseHeaders: {
        ...details.responseHeaders,
        'Content-Security-Policy': [
          "default-src 'self'; " +
          "script-src 'self' 'unsafe-inline'; " +
          "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; " +
          "font-src https://fonts.gstatic.com 'self' data:; " +
          "img-src 'self' data:; connect-src 'none'; " +
          "object-src 'none'; base-uri 'self'; form-action 'none';"
        ],
        'X-Content-Type-Options':  ['nosniff'],
        'X-Frame-Options':         ['DENY'],
        'Referrer-Policy':         ['no-referrer'],
        'Permissions-Policy':      ['geolocation=(), microphone=(), camera=()'],
      }
    });
  });

  mainWindow.loadFile(path.join(__dirname, 'src', 'index.html'));

  // Show when ready
  mainWindow.once('ready-to-show', () => {
    mainWindow.show();
    if (process.platform === 'darwin') app.dock.show();
  });

  // Hide to tray instead of close
  mainWindow.on('close', (e) => {
    if (!quitting) {
      e.preventDefault();
      mainWindow.hide();
      if (process.platform === 'darwin') app.dock.hide();
      if (timerState.running) {
        showNativeNotification('FocusGuard running in tray',
          'Timer is still running. Click the tray icon to restore.', false);
      }
    }
  });

  // Build app menu
  buildAppMenu();
}

// ── App Menu ─────────────────────────────────────────────────────────────────
function buildAppMenu() {
  const template = [
    {
      label: 'FocusGuard',
      submenu: [
        { label: 'About FocusGuard', role: 'about' },
        { type: 'separator' },
        { label: 'Hide', accelerator: 'CmdOrCtrl+H', role: 'hide' },
        { type: 'separator' },
        { label: 'Quit', accelerator: 'CmdOrCtrl+Q', click: () => { quitting = true; app.quit(); } }
      ]
    },
    {
      label: 'Timer',
      submenu: [
        { label: 'Start / Pause', accelerator: 'Space',         click: () => sendToRenderer('shortcut', 'toggle') },
        { label: 'Skip Session',  accelerator: 'CmdOrCtrl+K',   click: () => sendToRenderer('shortcut', 'skip') },
        { label: 'Reset All',     accelerator: 'CmdOrCtrl+R',   click: () => sendToRenderer('shortcut', 'reset') },
        { type: 'separator' },
        { label: 'Toggle Mute',   accelerator: 'CmdOrCtrl+M',   click: () => sendToRenderer('shortcut', 'mute') },
      ]
    },
    {
      label: 'View',
      submenu: [
        { label: 'Reload', accelerator: 'CmdOrCtrl+Shift+R', role: 'reload', visible: !app.isPackaged },
        { label: 'Toggle DevTools', accelerator: 'F12', role: 'toggleDevTools', visible: !app.isPackaged },
        { type: 'separator' },
        { label: 'Actual Size',    accelerator: 'CmdOrCtrl+0',      role: 'resetZoom' },
        { label: 'Zoom In',        accelerator: 'CmdOrCtrl+Plus',   role: 'zoomIn' },
        { label: 'Zoom Out',       accelerator: 'CmdOrCtrl+-',      role: 'zoomOut' },
        { type: 'separator' },
        { label: 'Toggle Fullscreen', role: 'togglefullscreen' },
      ]
    }
  ];
  Menu.setApplicationMenu(Menu.buildFromTemplate(template));
}

// ── System Tray ───────────────────────────────────────────────────────────────
function createTray() {
  tray = new Tray(getTrayIcon());
  tray.setToolTip('FocusGuard — Focus Timer');
  buildTrayMenu();
  tray.on('double-click', showWindow);
  tray.on('click', () => { if (process.platform !== 'darwin') showWindow(); });
}
function buildTrayMenu(state) {
  const s = state || timerState;
  const timeStr = formatTime(s.secsLeft);
  const modeStr = s.isFocus ? '🟠 Focus' : '🟢 Break';
  const statusStr = !s.running ? 'Stopped' : s.paused ? 'Paused' : `${modeStr} — ${timeStr}`;

  const menu = Menu.buildFromTemplate([
    { label: 'FocusGuard', enabled: false },
    { label: statusStr,    enabled: false },
    { type: 'separator' },
    {
      label: !s.running || s.paused ? '▶  Start / Resume' : '⏸  Pause',
      click: () => sendToRenderer('shortcut', 'toggle')
    },
    { label: '⏭  Skip Session', click: () => sendToRenderer('shortcut', 'skip') },
    { label: '↺  Reset',        click: () => sendToRenderer('shortcut', 'reset') },
    { type: 'separator' },
    { label: '🪟  Open Window', click: showWindow },
    { type: 'separator' },
    { label: 'Quit FocusGuard', click: () => { quitting = true; app.quit(); } }
  ]);
  tray.setContextMenu(menu);
}
function updateTrayTitle(state) {
  const s = state || timerState;
  if (s.running && !s.paused) {
    const t = formatTime(s.secsLeft);
    tray.setToolTip(`FocusGuard — ${s.isFocus ? 'Focus' : 'Break'} ${t}`);
    if (process.platform === 'darwin') tray.setTitle(t);
  } else {
    tray.setToolTip('FocusGuard — Paused');
    if (process.platform === 'darwin') tray.setTitle('');
  }
  buildTrayMenu(s);
}

// ── Helpers ───────────────────────────────────────────────────────────────────
function showWindow() {
  if (!mainWindow) return;
  if (mainWindow.isMinimized()) mainWindow.restore();
  mainWindow.show();
  mainWindow.focus();
  if (process.platform === 'darwin') app.dock.show();
}
function sendToRenderer(channel, data) {
  if (mainWindow && !mainWindow.isDestroyed()) {
    mainWindow.webContents.send(channel, data);
  }
}
function formatTime(secs) {
  const m = Math.floor(secs / 60);
  const s = secs % 60;
  return `${String(m).padStart(2,'0')}:${String(s).padStart(2,'0')}`;
}
function showNativeNotification(title, body, showWindow_ = true) {
  if (!Notification.isSupported()) return;
  try {
    const notif = new Notification({
      title,
      body,
      icon: assetPath('icon.png'),
      urgency: 'critical',
      timeoutType: 'never',
      silent: true
    });
    if (showWindow_) notif.on('click', showWindow);
    notif.show();
  } catch (e) { /* ignore */ }
}

// ── Power save blocker (prevent sleep during focus session) ──────────────────
function enablePowerSave() {
  if (psBlockerId === null || !powerSaveBlocker.isStarted(psBlockerId)) {
    psBlockerId = powerSaveBlocker.start('prevent-display-sleep');
  }
}
function disablePowerSave() {
  if (psBlockerId !== null && powerSaveBlocker.isStarted(psBlockerId)) {
    powerSaveBlocker.stop(psBlockerId);
    psBlockerId = null;
  }
}

// ── IPC Handlers (renderer → main) ───────────────────────────────────────────
ipcMain.on('timer-state-update', (_, state) => {
  timerState = { ...timerState, ...state };
  updateTrayTitle(timerState);
  // Power save blocker: keep screen awake during focus session
  if (state.running && !state.paused && state.isFocus) {
    enablePowerSave();
  } else {
    disablePowerSave();
  }
});

ipcMain.on('session-alarm', (_, data) => {
  const isFocus = data.newMode === 'focus';
  const title   = isFocus ? '⚡ Focus Session Started!' : '🌿 Break Time!';
  const body    = isFocus
    ? `Break is over. Focus for ${timerState.focusMins} minutes.`
    : `Great work! You've completed ${data.sessions} sessions. Rest for ${timerState.breakMins} minutes.`;
  showNativeNotification(title, body, false);
  showWindow(); // Bring window to front on alarm
});

ipcMain.handle('get-platform', () => process.platform);

ipcMain.handle('show-confirm-dialog', async (_, opts) => {
  const result = await dialog.showMessageBox(mainWindow, {
    type: 'question',
    buttons: ['OK', 'Cancel'],
    title: opts.title || 'FocusGuard',
    message: opts.message || 'Are you sure?',
    defaultId: 0,
    cancelId: 1
  });
  return result.response === 0;
});

ipcMain.on('update-config', (_, cfg) => {
  timerState.focusMins = cfg.focusMins || timerState.focusMins;
  timerState.breakMins = cfg.breakMins || timerState.breakMins;
});

ipcMain.on('window-flash', () => {
  if (mainWindow && !mainWindow.isFocused()) {
    mainWindow.flashFrame(true);
    setTimeout(() => {
      if (mainWindow && !mainWindow.isDestroyed()) mainWindow.flashFrame(false);
    }, 3000);
  }
});

// ── Second instance handler ───────────────────────────────────────────────────
app.on('second-instance', () => { showWindow(); });

// ── App lifecycle ─────────────────────────────────────────────────────────────
app.whenReady().then(() => {
  createWindow();
  createTray();

  // Register global media key shortcuts
  globalShortcut.register('MediaPlayPause', () => sendToRenderer('shortcut', 'toggle'));
  globalShortcut.register('MediaNextTrack',  () => sendToRenderer('shortcut', 'skip'));

  app.on('activate', () => { if (!mainWindow || mainWindow.isDestroyed()) createWindow(); else showWindow(); });
});

app.on('will-quit', () => {
  globalShortcut.unregisterAll();
  disablePowerSave();
});

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    /* Keep running in tray on Windows/Linux */
  }
});

app.on('before-quit', () => { quitting = true; });
