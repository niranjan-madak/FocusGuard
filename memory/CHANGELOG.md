# CHANGELOG — FocusGuard

All notable changes to FocusGuard will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Planned
- Session data persistence (shared_preferences — dependency already declared)
- Settings persistence across restarts (volume, sound, auto-start)
- Statistics dashboard (daily/weekly focus time)
- Custom alarm sounds
- System tray integration (community plugin)
- Code signing for distribution builds

---

## [1.0.1+2] — 2026-05-25 — Post-rewrite Polish (Session 2)

### Fixed

- **`audio_service.dart`:** Removed `const` from `AudioContext(...)` constructors — not const-constructible in audioplayers 6.6.0
- **`notification_service.dart`:** Removed Windows-specific init/show code (`windows:` parameter does not exist in flutter_local_notifications 18.0.1); Windows OS notifications silently skipped (in-app `AlarmBanner` covers this)
- **`windows/CMakeLists.txt`:** Added `-D_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS` to fix MSVC 14.51+ hard error on `<experimental/coroutine>` from audioplayers_windows 4.3.0
- **`test/widget_test.dart`:** Replaced broken scaffold test (referenced non-existent `MyApp`) with placeholder test; diagnosed via `flutter analyze`

### Added

- **Responsive desktop layout** (`lib/screens/home_screen.dart`): Two-column layout at ≥800px via `LayoutBuilder`; ring scales via `(maxWidth * 0.22).clamp(260.0, 340.0)`
- **`ProgressRing` `size` parameter** (`lib/widgets/progress_ring.dart`): Fonts and stroke width scale proportionally via `size / 230`
- **`_ControlsCard` widget** (`home_screen.dart`): Right-column-specific controls card for desktop layout (no embedded ring)
- **MSIX packaging** (`pubspec.yaml` + `msix ^3.16.7` dev dependency): `dart run msix:create` produces signed `.msix`; identity `com.madaklabs.focusguard.app`
- **`build_and_launch.md`** (project root): Complete build/package/ship reference for all 5 platforms

### Changed

- Font sizes increased across `stats_bar.dart` (9.5→12sp labels), `timeline_dots.dart` (10→12sp labels), shortcut key labels (10→12sp) for readability on desktop
- Documentation rewrite: `README.md`, `CONTRIBUTING.md`, `SECURITY.md`, `CHANGELOG.md` — all Electron references removed
- Deleted Electron-era artifacts: `SCAN_REPORT.md`, `memory/FONTS_AND_CSP_IMPROVEMENTS.md`, `memory/IMPLEMENTATION_CHECKLIST.md`, `memory/CSP_REFERENCE.md`

---

## [1.0.1+2] — Flutter Rewrite

### Changed — Breaking Rewrite

- **Full rewrite from Electron to Flutter/Dart**
- Replaced Electron + Vanilla JS with Flutter + Provider (ChangeNotifier)
- Replaced Web Audio API synthesis with `audioplayers` package + WAV files
- Replaced Electron Notification API with `flutter_local_notifications`
- Replaced Electron `powerSaveBlocker` with `wakelock_plus`
- Replaced `electron-builder` packaging with Flutter build system

### Added

- Android and iOS platform support (mobile targets not possible with Electron)
- `AudioService` — four dedicated `AudioPlayer` instances for alarm/click/tick sounds
- `NotificationService` — cross-platform notifications (Android, iOS, Windows, Linux)
- `TimerModel` — ChangeNotifier with all timer state and business logic
- `ProgressRing` widget — CustomPaint arc-based countdown ring
- `AlarmBanner` widget — in-app alarm dismissal
- `StatsBar` widget — sessions / focus time / cycles display
- `TimelineDots` widget — session history dot row
- `SettingsPanel` widget — duration customization form
- `shared_preferences` dependency declared (ready for persistence feature)
- Countdown tick sound in last 10 seconds of any session
- `google_fonts` package (Orbitron, Share Tech Mono, Exo 2 — same fonts, now package-based)

### Removed

- System tray integration (no Flutter equivalent)
- Global media keys (no Flutter equivalent)
- Window flash on notification (not applicable)
- Security badge UI element
- Electron IPC (main/preload/renderer) architecture
- CSP enforcement (not applicable in Flutter)
- `main.js`, `preload.js`, `src/index.html`, `src/renderer.js`, `src/styles.css`
- `package.json`, `package-lock.json`, `electron-builder` config

### Security

- Security model updated: OS-level sandboxing per platform, no network requests, minimal dependencies
- See SECURITY.md for full updated posture

---

## [1.0.0] — Electron Release

### Added (Electron implementation — superseded)

- Initial release of FocusGuard as Electron + Vanilla JS desktop app
- 75-minute focus timer (configurable 1–240 min)
- 20-minute break timer (configurable 1–120 min)
- Multi-tone alarm sounds via Web Audio API
- Native OS notifications
- System tray integration with dynamic menus
- Power save blocker during focus sessions
- Global media key support (Play/Pause, Next)
- Session history with color-coded timeline
- Auto-start next session option
- Keyboard shortcuts (Space, Ctrl+K, Ctrl+R, Ctrl+M)
- Dark theme with amber focus / cyan break modes
- Settings panel for customization
- Security-first Electron architecture (sandbox, contextBridge, CSP, IPC allowlists)
- Cross-platform support (Windows, macOS, Linux)

### Security (Electron)

- `nodeIntegration: false`, `contextIsolation: true`, `sandbox: true`
- Strict CSP with `connect-src 'none'`
- IPC channel allowlists in preload
- Input sanitization for all IPC data
- Navigation guards and new window guards
- Object.prototype freezing
- Single instance lock

---

## Version Format

- **[Unreleased]** — Features planned but not yet released
- **[X.Y.Z]** — Released versions with date (Flutter: version+build)

## Categories

- **Added** — New features
- **Changed** — Changes in existing functionality
- **Deprecated** — Soon-to-be removed features
- **Removed** — Removed features
- **Fixed** — Bug fixes
- **Security** — Security vulnerability fixes or improvements
