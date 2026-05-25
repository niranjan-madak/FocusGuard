# DEPLOYMENT — FocusGuard

## Overview

FocusGuard is built with Flutter and distributed as platform-specific release builds.

**Distribution Method:** Direct download (GitHub Releases or build from source)
**Deployment Automation:** Manual (no CI/CD configured)
**Update Mechanism:** None (manual reinstall)

---

## Build Process

### Prerequisites

- Flutter SDK ^3.11.4 installed and `flutter doctor` passing
- Target platform SDK (Android Studio / Xcode / VS Build Tools as needed)

### Build Commands

```bash
# Android APK (direct install)
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS (requires macOS + Xcode)
flutter build ios --release

# Windows
flutter build windows --release

# macOS (requires macOS)
flutter build macos --release

# Linux
flutter build linux --release
```

### Build Output Locations

| Platform | Output |
|----------|--------|
| Android APK | `build/app/outputs/flutter-apk/app-release.apk` |
| Android AAB | `build/app/outputs/bundle/release/app-release.aab` |
| iOS | `build/ios/iphoneos/Runner.app` |
| Windows | `build/windows/x64/runner/Release/` |
| macOS | `build/macos/Build/Products/Release/FocusGuard.app` |
| Linux | `build/linux/x64/release/bundle/` |

---

## Platform Notes

### Android

- Distribute as APK (direct) or AAB (Google Play Store)
- App requests notification permission on Android 13+ at first launch
- No additional permissions required

### iOS

- Requires Apple Developer account for distribution
- Archive via Xcode: `Product → Archive → Distribute`
- Submit via App Store Connect or ad-hoc distribution

### Windows

**MSIX installer** (preferred — official Microsoft format):
```bash
flutter build windows --release
dart run msix:create
# Output: build/windows/x64/runner/Release/focusguard.msix
```

MSIX config is in `pubspec.yaml` under `msix_config`. Identity: `com.madaklabs.focusguard.app`.

- **Code signing:** Obtain an EV code signing certificate to avoid Windows SmartScreen warnings
- Current status: unsigned — SmartScreen will warn on first run; MSIX installs via right-click → Install

### macOS

- Distribute `.app` wrapped in a DMG
- **Code signing:** Requires Apple Developer ID Application certificate
- **Notarization:** Required for macOS 10.15+ if distributing outside App Store
- Current status: unsigned — Gatekeeper will warn

### Linux

- Distribute the `bundle/` folder as a tar.gz, AppImage, or Flatpak
- No code signing required

---

## Release Process (Manual)

1. Update `version` in `pubspec.yaml` (format: `MAJOR.MINOR.PATCH+BUILD`)
2. Update `memory/CHANGELOG.md`
3. Run `flutter clean && flutter pub get`
4. Build for each target platform
5. Test each build on a clean device/VM
6. Create GitHub Release with tag `vX.Y.Z`
7. Upload build artifacts as release assets
8. Update README with new version
9. Announce release

### Release Checklist

- [ ] `pubspec.yaml` version updated
- [ ] `CHANGELOG.md` updated
- [ ] All target platforms built successfully
- [ ] Tested on clean device/VM per platform
- [ ] GitHub Release created with correct tag
- [ ] Build artifacts uploaded
- [ ] README version updated

---

## Versioning

Flutter uses `MAJOR.MINOR.PATCH+BUILD` format in `pubspec.yaml`.

**Current version:** `1.0.1+2`

- `1.0.1` — semantic version (shown to users)
- `+2` — build number (used by app stores for upgrade ordering)

---

## Update Mechanism

**Current status:** None. Users must manually download and install new versions.

**Future:** Add in-app update check pointing to GitHub Releases API.

---

## CI/CD (Recommended Future Setup)

GitHub Actions workflow on tag push:

```yaml
name: Build and Release

on:
  push:
    tags:
      - 'v*'

jobs:
  build-android:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: flutter build apk --release
      - uses: actions/upload-artifact@v4
        with:
          name: android-apk
          path: build/app/outputs/flutter-apk/app-release.apk

  build-windows:
    runs-on: windows-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter build windows --release
      - uses: actions/upload-artifact@v4
        with:
          name: windows-build
          path: build/windows/x64/runner/Release/
```

---

## Code Signing

### Windows

1. Obtain EV Code Signing Certificate (DigiCert, Sectigo)
2. Sign the `.exe` or installer with `signtool.exe`
3. SmartScreen reputation builds over time after signing

### macOS

1. Obtain Apple Developer ID Application certificate
2. Sign: `codesign --deep --force --sign "Developer ID Application: ..." FocusGuard.app`
3. Notarize: `xcrun notarytool submit FocusGuard.zip --apple-id ... --wait`
4. Staple: `xcrun stapler staple FocusGuard.app`

### Android

1. Generate keystore: `keytool -genkey -v -keystore focusguard.jks ...`
2. Configure in `android/key.properties`
3. Sign via Flutter build: `flutter build apk --release` (automatic if configured)

---

## Summary

FocusGuard deployment is currently manual. Priority improvements:
1. Set up GitHub Actions for automated per-platform builds
2. Add code signing for Windows and macOS
3. Publish to Google Play and Apple App Store
4. Add in-app update notification

**Philosophy:** Ship working, tested builds. Automate when the manual process becomes a bottleneck.
