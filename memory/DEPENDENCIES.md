# DEPENDENCIES — FocusGuard

## Dependency Overview

FocusGuard is a Flutter/Dart app. All dependencies are managed via `pubspec.yaml`.

**Total Direct Dependencies:** 9 (6 runtime + 3 dev)
**Lock file:** `pubspec.lock`
**Audit tool:** `flutter pub outdated`, `dart pub audit`

---

## Runtime Dependencies

### flutter (SDK)

**Purpose:** Core UI framework
**Source:** Flutter SDK (not pub.dev)

---

### provider ^6.1.2

**Purpose:** State management — `ChangeNotifierProvider` wraps `TimerModel`
**Why:** Official Flutter recommendation for this scope; minimal boilerplate
**Used in:** `main.dart`, all widgets via `context.watch<TimerModel>()`

---

### audioplayers ^6.1.0

**Purpose:** Cross-platform audio playback for alarm and UI sounds
**Why:** Simple API, supports all Flutter platforms, good WAV support
**Used in:** `lib/services/audio_service.dart`
**Assets:** `assets/sounds/focus_alarm.wav`, `break_alarm.wav`, `click.wav`, `tick.wav`

**Alternatives considered:**
- `just_audio` — heavier for short sound effects
- `flutter_sound` — recording focus, overkill

---

### flutter_local_notifications ^18.0.1

**Purpose:** Native OS notifications on session end
**Why:** Supports Android, iOS, Windows, Linux from one package; fully local (no push server)
**Used in:** `lib/services/notification_service.dart`

**Platform setup:**
- Android: `@mipmap/ic_launcher`, requests permission on Android 13+
- iOS: `DarwinInitializationSettings`
- Linux: `LinuxInitializationSettings(defaultActionName: 'Open')`
- Windows: GUID `d49b0314-ee7a-4196-8b0b-3b951a7c4f08`, app model ID `com.focusguard.app`

---

### wakelock_plus ^1.2.10

**Purpose:** Prevents screen sleep during active focus sessions
**Why:** Drop-in replacement for deprecated `wakelock`; cross-platform
**Used in:** `lib/screens/home_screen.dart`
**Activation:** `WakelockPlus.toggle(enable: running && !paused && isFocus)`

---

### shared_preferences ^2.3.3

**Purpose:** Key-value persistence (settings, future state saving)
**Status:** Dependency declared; not yet wired in any Dart file
**Why declared:** Ready for upcoming persistence feature (timer settings, session history)

---

### google_fonts ^6.2.1

**Purpose:** Orbitron, Share Tech Mono, Exo 2 fonts
**Why:** Bundled with package — no CDN at runtime; same fonts as original Electron version
**Used in:** `lib/theme.dart` — `orbitron()`, `mono()`, `exo()` helpers

---

## Dev Dependencies

### flutter_test (SDK)

**Purpose:** Testing framework
**Source:** Flutter SDK
**Status:** Framework present, no tests written yet

---

### flutter_lints ^6.0.0

**Purpose:** Official Flutter lint rules
**Config:** `analysis_options.yaml`

---

### msix ^3.16.7

**Purpose:** MSIX installer packaging for Windows distribution
**Why:** Official Microsoft installer format; supports code signing, Windows Store, auto-update
**Used in:** Dev-only — `dart run msix:create` (not imported in any Dart file)
**Config in `pubspec.yaml` (`msix_config`):**
- `identity_name: com.madaklabs.focusguard.app`
- `publisher_display_name: Niranjan Madak`
- `msix_version: 1.0.1.2`
- `capabilities: runFullTrust`
- `install_certificate: true`

**Usage:** Run `flutter build windows --release` first, then `dart run msix:create`

---

## Dependency Health

### Checking for Outdated Packages

```bash
flutter pub outdated
```

### Security Audit

```bash
dart pub audit
```

### Known Issues

None currently.

---

## Dependency Management Rules

### Before Adding a Dependency

1. Can Flutter / Dart stdlib do it natively?
2. Is the package actively maintained (last release < 12 months)?
3. Does it support all target platforms (Android, iOS, Windows, macOS, Linux)?
4. What is the transitive dependency footprint?
5. Is the license compatible (MIT / BSD / Apache)?

### Approval Process

1. Document rationale in this file
2. Run `flutter pub get` and test on all target platforms
3. Run `dart pub audit`

### Removing Dependencies

1. Verify no Dart file imports the package
2. Remove from `pubspec.yaml`, run `flutter pub get`
3. Update this file

---

## License Compliance

| Package | License |
|---------|---------|
| provider | MIT |
| audioplayers | MIT |
| flutter_local_notifications | BSD |
| wakelock_plus | BSD |
| shared_preferences | BSD |
| google_fonts | Apache 2.0 |
| flutter_lints | BSD |
| msix | MIT |

All licenses are permissive and compatible with MIT project license.

---

## Summary

FocusGuard maintains a minimal, justified dependency set:

- 6 runtime packages, all actively maintained
- 3 dev packages (test framework + lints + msix)
- No network-dependent dependencies at runtime
- `shared_preferences` declared, ready for state persistence feature
- All packages support the full Flutter target matrix
- `msix` is Windows-only dev tool; does not affect runtime or other platforms
