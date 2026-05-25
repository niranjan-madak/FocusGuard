# CODEBASE_MAP — FocusGuard

Repository scan: 2026-05-25. Framework: Flutter/Dart (rewritten from Electron).

## Top-level layout

```
lib/                        # All Dart source
├── main.dart               # Entry point, Provider setup, app bootstrap
├── theme.dart              # Color constants (C class), font helpers
├── models/
│   └── timer_model.dart    # All timer state + logic (ChangeNotifier)
├── services/
│   ├── audio_service.dart  # audioplayers wrapper (4 players)
│   └── notification_service.dart  # flutter_local_notifications wrapper
├── screens/
│   └── home_screen.dart    # Main UI, keyboard handler, wakelock
└── widgets/
    ├── progress_ring.dart  # CustomPaint countdown ring
    ├── alarm_banner.dart   # Session-end alarm dismissal
    ├── stats_bar.dart      # Sessions / focus time / cycles row
    ├── timeline_dots.dart  # Session history dot row
    └── settings_panel.dart # Duration settings form

assets/
└── sounds/
    ├── focus_alarm.wav     # Played when break ends → focus starts
    ├── break_alarm.wav     # Played when focus ends → break starts
    ├── click.wav           # UI interaction feedback
    └── tick.wav            # Last-10-seconds countdown tick

pubspec.yaml                # Dependencies + asset declarations + msix_config
pubspec.lock                # Locked dependency versions
analysis_options.yaml       # Lint rules (flutter_lints)
build_and_launch.md         # Build/package/ship reference for all platforms
android/                    # Android platform files
ios/                        # iOS platform files
windows/                    # Windows platform files
  CMakeLists.txt            # Includes -D_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS fix
linux/                      # Linux platform files
macos/                      # macOS platform files
test/                       # Placeholder test (widget_test.dart — no real tests yet)
memory/                     # Project documentation
```

## Entry Points

- **Application startup:** `lib/main.dart` — `void main()` initialises services, sets up Provider, runs `FocusGuardApp`
- **Main UI:** `lib/screens/home_screen.dart` — `HomeScreen` widget
- **State:** `lib/models/timer_model.dart` — `TimerModel` (ChangeNotifier, single instance via Provider)

## Critical Files

| File | Risk | Notes |
|------|------|-------|
| `lib/models/timer_model.dart` | High | All timer logic here — test before refactoring |
| `lib/services/audio_service.dart` | Medium | 4 concurrent players — dispose carefully; `AudioContext` constructors are NOT `const` (audioplayers 6.6.0) |
| `lib/services/notification_service.dart` | Medium | Windows notifications unsupported in flutter_local_notifications 18.0.1 — no `windows:` param |
| `lib/screens/home_screen.dart` | Medium | Responsive layout: `LayoutBuilder` at 800px; wakelock side-effect on every rebuild |
| `lib/widgets/progress_ring.dart` | Low | Accepts `size` param — fonts and stroke width scale via `size / 230` |
| `windows/CMakeLists.txt` | Low | Contains `-D_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS` to fix MSVC 14.51+ hard error |
| `pubspec.yaml` | Medium | Asset paths must match `assets/sounds/` files exactly; `msix_config` section for Windows installer |

## State Access Pattern

All widgets read state via:
```dart
final m = context.watch<TimerModel>(); // rebuilds on notifyListeners()
```

Or for one-time reads (no rebuild):
```dart
final m = context.read<TimerModel>();
```

## Timer Logic Summary (timer_model.dart)

```
_start()       → running=true, Timer.periodic(1s, _tick)
_pause()       → paused=true
_resume()      → paused=false
_tick()        → secsLeft-- | playTick (last 10s) | _onSessionEnd (at 0)
_onSessionEnd()→ stop ticker, _recordSession(), toggle isFocus,
                 playAlarm(), notif.show(), alarmActive=true,
                 if autoStart → Future.delayed → _start()
```

## No IPC / No Multi-process

Flutter is a single-process model. There is no:
- `main.js` / `preload.js` / `renderer.js`
- IPC channels
- contextBridge
- CSP headers

These were Electron-specific and were dropped in the Flutter rewrite.

## Suggested Next Steps

- Wire `shared_preferences` in `timer_model.dart` to persist `focusMins`, `breakMins`, `soundEnabled`, `autoStart`, `volume`
- Add widget tests for `ProgressRing`, `StatsBar`, `TimelineDots`
- Add unit tests for `TimerModel` state transitions
- Implement system tray via a community plugin if needed
