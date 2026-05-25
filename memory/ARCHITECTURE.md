# ARCHITECTURE — FocusGuard

## Architecture Overview

FocusGuard is a **Flutter single-process application** using Provider for state management.

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter App (single process)              │
│                                                              │
│  main.dart                                                   │
│  ├── AudioService.init()                                     │
│  ├── NotificationService.init()                              │
│  └── ChangeNotifierProvider<TimerModel>                      │
│       └── FocusGuardApp → HomeScreen                         │
│                                                              │
│  TimerModel (ChangeNotifier)                                 │
│  ├── Timer.periodic (1s tick)                                │
│  ├── AudioService  → audioplayers (WAV files)                │
│  └── NotificationService → flutter_local_notifications       │
│                                                              │
│  HomeScreen (StatefulWidget)                                 │
│  ├── KeyboardListener (Space, Ctrl+K, Ctrl+R, Ctrl+M)        │
│  ├── WakelockPlus (screen-on during active focus)            │
│  ├── ProgressRing widget                                     │
│  ├── AlarmBanner widget                                      │
│  ├── StatsBar widget                                         │
│  ├── TimelineDots widget                                     │
│  └── SettingsPanel widget                                    │
└─────────────────────────────────────────────────────────────┘
```

## Layer Responsibilities

### Entry Point — main.dart

- Initializes `AudioService` and `NotificationService` (both async)
- Wraps app in `ChangeNotifierProvider<TimerModel>`
- Runs `FocusGuardApp` (MaterialApp) → `HomeScreen`

### State — TimerModel (lib/models/timer_model.dart)

The single source of truth. Extends `ChangeNotifier`; all UI rebuilds happen via `notifyListeners()`.

**State fields:**

| Field | Type | Default | Purpose |
|-------|------|---------|---------|
| `focusMins` | int | 75 | Focus session duration |
| `breakMins` | int | 20 | Break session duration |
| `running` | bool | false | Timer is active |
| `paused` | bool | false | Timer is paused |
| `isFocus` | bool | true | Current session type |
| `secsLeft` | int | 4500 | Seconds remaining |
| `sessionsCompleted` | int | 0 | Completed focus sessions |
| `totalFocusSecs` | int | 0 | Accumulated focus seconds |
| `cycles` | int | 0 | Completed break sessions |
| `history` | List<String> | [] | Session sequence |
| `alarmActive` | bool | false | Alarm banner visible |
| `soundEnabled` | bool | true | Sound on/off |
| `autoStart` | bool | true | Auto-start next session |
| `volume` | double | 0.7 | Playback volume 0..1 |

**Public controls:**

| Method | Effect |
|--------|--------|
| `toggleStartStop()` | Start → Pause → Resume cycle |
| `skip()` | End current session immediately |
| `reset()` | Full reset — clears all state |
| `dismissAlarm()` | Hide alarm banner |
| `applySettings({focusM, breakM})` | Update durations + reset |
| `toggleSound()` | Toggle sound on/off |
| `setVolume(v)` | Set volume 0..1 |
| `setAutoStart(v)` | Toggle auto-start |

### Services

#### AudioService (lib/services/audio_service.dart)

Four `AudioPlayer` instances (from `audioplayers` package):

| Player | WAV file | Triggered by |
|--------|----------|--------------|
| `_focus` | `sounds/focus_alarm.wav` | Session ending → break starts |
| `_brk` | `sounds/break_alarm.wav` | Break ending → focus starts |
| `_click` | `sounds/click.wav` | Any button / control action |
| `_tick` | `sounds/tick.wav` | Last 10 seconds of any session |

#### NotificationService (lib/services/notification_service.dart)

Wraps `flutter_local_notifications`. Initialized with platform-specific settings for Android, iOS, Linux, and Windows. Shows a high-priority silent notification on every session transition.

### UI — HomeScreen (lib/screens/home_screen.dart)

`StatefulWidget` — only owns `_settingsOpen` (bool). Everything else reads from `TimerModel` via `context.watch<TimerModel>()`.

**Side effects per rebuild:**
- `WakelockPlus.toggle(enable: running && !paused && isFocus)` — keeps screen on during active focus
- `SystemChrome.setApplicationSwitcherDescription(...)` — updates window/task-switcher title

### Widgets (lib/widgets/)

| Widget | Props | Purpose |
|--------|-------|---------|
| `ProgressRing` | progress, isFocus, timeStr | SVG-style countdown ring (CustomPaint) |
| `AlarmBanner` | isFocus, focusMins, breakMins, onDismiss | Alarm dismissal banner |
| `StatsBar` | sessions, focusTime, cycles, isFocus | Stats row |
| `TimelineDots` | history, running, isFocus | Session history dots |
| `SettingsPanel` | focusMins, breakMins, onApply | Duration customization |

### Theme (lib/theme.dart)

Abstract class `C` holds all color constants. Three font helpers return `TextStyle` via `google_fonts`:
- `orbitron(size, weight, color)` — display/headings
- `mono(size, color)` — monospace/labels
- `exo(size, weight, color)` — body/controls

## Data Flow

### Timer Tick Flow

```
Timer.periodic (1s)
    │
    ▼ _tick()
    ├── if secsLeft > 10: secsLeft--
    ├── if secsLeft <= 10: playTick()
    └── if secsLeft == 0: _onSessionEnd()
           ├── _recordSession() → history, sessionsCompleted, cycles
           ├── toggle isFocus, reset secsLeft
           ├── playAlarm()
           ├── notif.show()
           ├── alarmActive = true
           └── if autoStart: Future.delayed → _start()
```

### Settings Change Flow

```
SettingsPanel → onApply({focusM, breakM})
    │
    ▼ TimerModel.applySettings()
    └── focusMins = focusM, breakMins = breakM → reset()
```

### Keyboard Flow

```
KeyboardListener (HomeScreen)
    │ KeyDownEvent
    ├── SPACE           → m.toggleStartStop()
    ├── Ctrl+K          → m.skip()
    ├── Ctrl+R          → m.reset()
    └── Ctrl+M          → m.toggleSound()
```

## State Management

Provider (`ChangeNotifier`) is the only state management layer. There is no Redux, Riverpod, Bloc, or other secondary system. The `TimerModel` is created once at `main()` and lives for the app lifetime.

## Platform Support

Flutter targets all of: Android, iOS, Windows, macOS, Linux.

`NotificationService` initialises platform-specific settings for Android, iOS, Linux, and Windows. iOS/macOS share the `DarwinInitializationSettings`. The Windows initialization uses a stable GUID (`d49b0314-ee7a-4196-8b0b-3b951a7c4f08`) and app model ID `com.focusguard.app`.

There is no system tray and no global media keys — those were Electron-only features dropped in the Flutter rewrite.

## File Structure

```
lib/
├── main.dart                    # Entry point, Provider setup
├── theme.dart                   # Color constants, font helpers
├── models/
│   └── timer_model.dart         # All timer state and logic
├── services/
│   ├── audio_service.dart       # audioplayers wrapper
│   └── notification_service.dart # flutter_local_notifications wrapper
├── screens/
│   └── home_screen.dart         # Main UI, keyboard handler
└── widgets/
    ├── progress_ring.dart        # CustomPaint countdown ring
    ├── alarm_banner.dart         # Session-end alarm UI
    ├── stats_bar.dart            # Sessions / focus time / cycles
    ├── timeline_dots.dart        # Session history row
    └── settings_panel.dart       # Duration settings form

assets/
└── sounds/
    ├── focus_alarm.wav
    ├── break_alarm.wav
    ├── click.wav
    └── tick.wav
```

## Known Limitations

1. **No system tray** — app must stay on screen; no background tray indicator
2. **No global media keys** — keyboard shortcuts only work when app is focused
3. **State not persisted** — timer resets on app restart (shared_preferences is a dependency but not yet wired to save state)
4. **No statistics persistence** — session history is in-memory only
5. **No auto-updater** — manual reinstall for updates
