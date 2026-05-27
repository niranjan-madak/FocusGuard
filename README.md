# FocusGuard — Deep Work Focus Timer

A cross-platform focus timer built with Flutter. 75-minute focus sessions, 20-minute breaks, offline-first, no accounts, no tracking.

---

## Features

- Animated progress ring with amber (focus) / cyan (break) color modes
- Alarm sounds on session transitions (WAV, plays even when window is in background)
- OS notifications on session end
- Auto-start next session toggle
- Session timeline — visual history of completed sessions
- Keyboard shortcuts: `Space` start/pause, `Ctrl+K` skip, `Ctrl+R` reset, `Ctrl+M` mute
- Responsive layout — two-column desktop view, single-column on mobile
- Fully offline — zero network requests at runtime

## Platform Support

| Platform | Status |
|----------|--------|
| Windows | ✅ |
| Android | ✅ |
| iOS | ✅ |
| Linux | ✅ |
| macOS | 🔲 Planned |

---

## Quick Start

**Prerequisites:** [Flutter SDK](https://docs.flutter.dev/get-started/install) ≥ 3.11.4

```bash
git clone https://github.com/your-username/FocusGuard
cd FocusGuard
flutter pub get
flutter run
```

`flutter run` auto-selects a connected device. To target a specific platform:

```bash
flutter run -d windows
flutter run -d android
flutter run -d linux
# flutter run -d macos   ← not yet implemented (planned)
```

---

## Build & Ship

See **[build_and_launch.md](build_and_launch.md)** for complete instructions:
- Release builds per platform
- MSIX installer (Windows)
- APK / AAB (Android)
- IPA (iOS)
- AppImage / deb (Linux)
- DMG (macOS) ← planned, not yet implemented
- Production checklist

---

## Project Structure

```
lib/
  main.dart                     Entry point — initialises services, runs app
  models/
    timer_model.dart            All timer state and business logic (ChangeNotifier)
  services/
    audio_service.dart          WAV playback via audioplayers
    notification_service.dart   OS notifications via flutter_local_notifications
  screens/
    home_screen.dart            Main UI — responsive layout, keyboard shortcuts
  widgets/
    progress_ring.dart          Countdown arc (CustomPaint)
    stats_bar.dart              Sessions / focus time / cycles display
    timeline_dots.dart          Session history dots
    alarm_banner.dart           In-app alarm overlay
    settings_panel.dart         Duration settings
  theme.dart                    Color constants and font helpers
assets/
  sounds/                       WAV files (focus_alarm, break_alarm, click, tick)
  icon.png                      App icon
windows/
  CMakeLists.txt                Windows build config
```

---

## Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| State management | Provider (ChangeNotifier) |
| Audio | audioplayers |
| Notifications | flutter_local_notifications |
| Screen wakelock | wakelock_plus |
| Fonts | google_fonts (bundled, no CDN) |

---

## License

MIT

---

## SDLC Framework

_MadakLabs SDLC Framework v1.0 adopted: S01 / 2026-05-26._  
_All framework artifacts are in `aiagent-generated-artifacts/FocusGuard/`._  
_Agent memory files are in `memory/`._
