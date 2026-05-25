# Changelog

All notable changes to FocusGuard are documented here.

---

## [1.0.1+2] — 2026-05-25 — Flutter Rewrite

Complete rewrite from Electron + Vanilla JavaScript to Flutter/Dart.

### Added
- Flutter/Dart codebase replacing entire Electron implementation
- Provider (ChangeNotifier) state management
- `audioplayers` package for WAV file playback (focus_alarm, break_alarm, click, tick)
- `flutter_local_notifications` for cross-platform OS notifications
- `wakelock_plus` to prevent screen sleep during focus sessions
- `google_fonts` package — fonts bundled at build time, no CDN at runtime
- `shared_preferences` dependency (wired for future settings persistence)
- Responsive desktop layout — two-column at ≥800px (timer ring left, controls right)
- MSIX installer support via `msix` package
- `build_and_launch.md` — complete build/package/ship reference for all platforms

### Changed
- Framework: Electron (Node.js) → Flutter (Dart)
- State management: global JS object → Provider ChangeNotifier (`TimerModel`)
- Audio: Web Audio API synthesis → `audioplayers` WAV playback
- Notifications: Electron Notification API → `flutter_local_notifications`
- Screen wakelock: `electron.powerSaveBlocker` → `wakelock_plus`
- Fonts: Google Fonts CDN → `google_fonts` package (zero runtime network)
- Build: `electron-builder` (npm) → `flutter build` + `dart run msix:create`
- Keyboard shortcuts: global media keys → window-focused `KeyboardListener`

### Removed
- System tray icon and background operation (no stable Flutter equivalent cross-platform)
- Global media key shortcuts (Play/Pause, Stop)
- Electron IPC / contextBridge / preload.js architecture
- Content-Security-Policy (not applicable to Flutter's Skia renderer)
- `main.js`, `preload.js`, `src/renderer.js`, `src/index.html`, `src/styles.css`

### Platform Support
- Windows ✅ (MSIX installer)
- Android ✅ (APK / AAB)
- iOS ✅ (IPA)
- macOS ✅ (App bundle / DMG)
- Linux ✅ (AppImage / deb)

---

## [1.0.0] — 2024-Q4 — Initial Release (Electron)

### Added
- 75-minute focus sessions with 20-minute breaks
- Animated progress ring with amber/teal color modes
- Web Audio API alarms
- System tray with live timer display and controls
- Native OS notifications on session transitions
- Power save blocker during focus sessions
- Global media key shortcuts
- Customizable durations (1–240 min focus, 1–120 min break)
- Session timeline dots
- Auto-start next session toggle
- Sound enable/disable toggle with volume slider
- Keyboard shortcuts: Space, Ctrl+K, Ctrl+R, Ctrl+M
- Dark industrial theme (Orbitron / Share Tech Mono / Exo 2 fonts)
- Windows NSIS installer, macOS DMG, Linux AppImage + deb
