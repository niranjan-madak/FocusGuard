# STATE_AND_FLOW — FocusGuard

Updated: 2026-05-25. Framework: Flutter/Dart (rewritten from Electron).

## Runtime State (TimerModel)

All state lives in `lib/models/timer_model.dart` as a `ChangeNotifier`.

```dart
int focusMins = 75;
int breakMins = 20;

bool running = false;
bool paused  = false;
bool isFocus = true;
int  secsLeft;           // initialised to focusMins * 60

int sessionsCompleted = 0;
int totalFocusSecs    = 0;
int cycles            = 0;      // count of completed breaks
List<String> history  = [];     // 'focus' | 'break'

bool alarmActive  = false;
bool soundEnabled = true;
bool autoStart    = true;
double volume     = 0.7;
```

**Derived getters:**

| Getter | Computation |
|--------|------------|
| `totalSecs` | `(isFocus ? focusMins : breakMins) * 60` |
| `progress` | `secsLeft / totalSecs` (0.0 → 1.0) |
| `timeStr` | `MM:SS` string |
| `focusTimeStr` | `Xh Ym` string |
| `statusText` | `READY` / `FOCUSING` / `ON BREAK` / `PAUSED` |

## Primary Flows

### 1. App Start

```
main() → AudioService.init() → NotificationService.init()
       → ChangeNotifierProvider<TimerModel> → FocusGuardApp → HomeScreen
```

`TimerModel` constructor sets `secsLeft = focusMins * 60`.

### 2. Start Timer

```
User taps START or presses SPACE
  → toggleStartStop() → _start()
     → running = true, paused = false
     → Timer.periodic(1s, _tick)
     → notifyListeners()
```

### 3. Tick (every second)

```
_tick(Timer)
  ├─ if !running || paused → return
  ├─ if secsLeft > 0
  │    secsLeft--
  │    if isFocus: totalFocusSecs++
  │    if secsLeft <= 10 && secsLeft > 0 && soundEnabled: audio.playTick(volume)
  │    notifyListeners()
  └─ else: _onSessionEnd()
```

### 4. Session End

```
_onSessionEnd()
  ├─ _ticker?.cancel()
  ├─ running = false
  ├─ _recordSession()            → history.add(), sessionsCompleted++, cycles
  ├─ isFocus = !isFocus          (toggle mode)
  ├─ secsLeft = new session length
  ├─ alarmActive = true
  ├─ if soundEnabled: audio.playAlarm(isFocus, volume)
  ├─ notif.show(title, body)
  ├─ notifyListeners()
  └─ if autoStart:
       Future.delayed(isFocus ? 3200ms : 4000ms, () {
         if !running && autoStart: _start()
       })
```

### 5. Pause / Resume

```
toggleStartStop()
  ├─ if !running:  _start()
  ├─ if !paused:   _pause()   → paused=true
  └─ else:         _resume()  → paused=false
```

Paused state: `_tick()` returns early — timer stops without cancelling the `Timer`.

### 6. Skip Session

```
skip()
  ├─ _recordSession()
  ├─ isFocus = !isFocus
  ├─ secsLeft = new session length
  ├─ running = false, paused = false
  ├─ _ticker?.cancel()
  ├─ if soundEnabled: audio.playClick(volume)
  └─ notifyListeners()
```

No alarm or notification on skip (user-initiated).

### 7. Reset

```
reset()
  ├─ _ticker?.cancel()
  ├─ running=false, paused=false, isFocus=true
  ├─ secsLeft = focusMins * 60
  ├─ sessionsCompleted=0, totalFocusSecs=0, cycles=0
  ├─ history=[], alarmActive=false
  ├─ if soundEnabled: audio.playClick(volume)
  └─ notifyListeners()
```

### 8. Apply Settings

```
applySettings({focusM, breakM})
  └─ focusMins=focusM, breakMins=breakM → reset()
```

### 9. Keyboard Shortcuts (HomeScreen._handleKey)

```
SPACE (no Ctrl)  → m.toggleStartStop()
Ctrl+K           → m.skip()
Ctrl+R           → m.reset()
Ctrl+M           → m.toggleSound()
```

Handled by `KeyboardListener` wrapping the `Scaffold`. Only triggers on `KeyDownEvent`.

### 10. Wakelock Side Effect

On every widget rebuild:
```dart
WakelockPlus.toggle(enable: m.running && !m.paused && m.isFocus);
```
Screen stays on only during active focus sessions; sleeps normally during breaks or when paused.

## Audio Mapping

| Condition | Sound file |
|-----------|-----------|
| Focus session just ended (break starting) | `break_alarm.wav` via `_brk` player |
| Break just ended (focus starting) | `focus_alarm.wav` via `_focus` player |
| Any button tap / control action | `click.wav` via `_click` player |
| Last 10 seconds of any session | `tick.wav` via `_tick` player |

Note: `playAlarm(isFocus, volume)` is called with the NEW `isFocus` value after toggling, so the alarm played corresponds to the session that just ended — not the one about to start.

## Concurrency Notes

- Single `Timer.periodic` — no race conditions
- `_tick()` guards: `if (!running || paused) return` prevents double-decrement
- `Future.delayed` for auto-start checks `!running && autoStart` before calling `_start()` — safe if user manually starts first

## No IPC / No Shared State Between Processes

Flutter is single-process. There are no IPC channels, no main/renderer split, no contextBridge. All state is in one `TimerModel` instance.
