# ENVIRONMENT_SETUP — FocusGuard

## Prerequisites

### Required Software

| Software | Minimum Version | Purpose |
|----------|-----------------|---------|
| Flutter SDK | ^3.11.4 | App framework and build tool |
| Dart SDK | ^3.11.4 | Included with Flutter |
| Android Studio / Xcode | Latest stable | Mobile platform builds |
| VS Code (recommended) | Any | IDE with Flutter extension |

Install Flutter: https://docs.flutter.dev/get-started/install

Verify installation:
```bash
flutter doctor
```

All checks should pass for the platforms you intend to build.

---

## Installation Steps

### 1. Clone Repository

```bash
git clone <repository-url>
cd focusguard
```

### 2. Install Dependencies

```bash
flutter pub get
```

This installs all packages declared in `pubspec.yaml`.

---

## Running in Development

```bash
# Run on connected device or emulator
flutter run

# Run on a specific platform
flutter run -d windows
flutter run -d linux
flutter run -d macos
flutter run -d android
flutter run -d ios

# Enable hot reload (press 'r' in terminal, or save in IDE)
```

---

## Building for Release

### Android

```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS

```bash
flutter build ios --release
# Requires macOS + Xcode
```

### Windows

```bash
flutter build windows --release
# Output: build/windows/x64/runner/Release/
```

### macOS

```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/FocusGuard.app
```

### Linux

```bash
flutter build linux --release
# Output: build/linux/x64/release/bundle/
```

---

## Platform-Specific Setup

### Android

- Install Android Studio and Android SDK
- Accept SDK licenses: `flutter doctor --android-licenses`
- Connect device or start emulator

### iOS / macOS

- Requires macOS + Xcode (latest stable)
- Run `xcode-select --install` for command-line tools
- Connect iOS device or start simulator

### Windows

- No special setup beyond Flutter SDK installation
- Requires Visual Studio Build Tools (C++ workload) — `flutter doctor` will flag if missing

### Linux

- Install required system libraries:
  ```bash
  sudo apt install clang cmake ninja-build pkg-config libgtk-3-dev liblzma-dev
  ```

---

## IDE Setup

### VS Code (Recommended)

Extensions:
- **Flutter** — Official Flutter extension (includes Dart)
- **Dart** — Dart language support

Settings (`.vscode/settings.json`):
```json
{
  "dart.flutterSdkPath": "/path/to/flutter",
  "editor.formatOnSave": true,
  "[dart]": {
    "editor.defaultFormatter": "Dart-Code.dart-code"
  }
}
```

### Android Studio / IntelliJ

Install Flutter and Dart plugins from the marketplace.

---

## Troubleshooting

### `flutter doctor` shows issues

Follow the suggested fixes for each failing check. Most common:
- Android SDK not found → Install Android Studio
- Xcode not installed → Only required for iOS/macOS builds
- VS Build Tools missing → Required for Windows builds

### `flutter pub get` fails

```bash
flutter clean
flutter pub get
```

### App fails to build on Windows

Ensure Visual Studio Build Tools with C++ Desktop Development workload is installed.

### Notifications not showing on Android

The app requests notification permission at startup (Android 13+). Accept the permission prompt. If denied, grant via device settings → Apps → FocusGuard → Notifications.

### Audio not playing

Verify sound files exist in `assets/sounds/`:
- `focus_alarm.wav`
- `break_alarm.wav`
- `click.wav`
- `tick.wav`

These must be listed in `pubspec.yaml` under `flutter.assets`.

---

## Environment Variables

FocusGuard does not use environment variables. All configuration is in:
- In-app settings panel
- `pubspec.yaml` (version, dependencies)

---

## Clean Build

```bash
flutter clean
flutter pub get
flutter build <platform> --release
```

---

## Network Requirements

- **Initial setup:** Internet required for `flutter pub get` (downloads packages)
- **Runtime:** No network access required — fully offline

---

## Summary

Development setup:
1. Install Flutter SDK (`flutter doctor` passes)
2. `flutter pub get` — install dependencies
3. `flutter run` — launch app

Release build:
1. `flutter build <platform> --release`
2. Test on target device
3. Distribute via GitHub Releases
