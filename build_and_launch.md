# FocusGuard — Build, Package & Ship Guide

> Reference for every platform: dev run → release build → production installer.

---

## Prerequisites

```bash
flutter doctor          # shows what's missing per platform
flutter --version       # confirm SDK ≥ 3.11.4
flutter pub get         # install dependencies (run after any pubspec.yaml change)
```

---

## Version Bumping

Edit `pubspec.yaml` before any release:

```yaml
version: 1.0.1+2   # format: MAJOR.MINOR.PATCH+BUILD
```

Also update `msix_config.msix_version` to match (4-part: `MAJOR.MINOR.PATCH.BUILD`).

---

## Windows

### Prerequisites
- Flutter SDK ≥ 3.11.4
- Visual Studio 2022 with **Desktop development with C++** workload
- OR Visual Studio Build Tools 2022 with same workload

### Dev Run
```powershell
flutter run -d windows
```

**Hot reload:** `r` — **Hot restart:** `R` — **Quit:** `q`

### Release Build
```powershell
flutter build windows --release
# Output: build\windows\x64\runner\Release\
```

The Release folder contains:
```
focusguard.exe
flutter_windows.dll
audioplayers_windows_plugin.dll
dartjni.dll
data\
```
> The exe requires all files in this folder beside it. Do not distribute the exe alone.

### Package — MSIX Installer (recommended)
```powershell
dart run msix:create
# Output: build\windows\x64\runner\Release\focusguard.msix
```

- Prompts UAC to install the signing certificate — click **Yes**
- Double-click `.msix` to install
- App appears in Start Menu and Apps & Features

**Config** (`pubspec.yaml`):
```yaml
msix_config:
  display_name: FocusGuard
  publisher_display_name: Niranjan Madak
  identity_name: com.madaklabs.focusguard.app
  logo_path: assets/icon.png
  msix_version: 1.0.1.2          # keep in sync with pubspec version
  capabilities: runFullTrust
  install_certificate: true
```

> **Note:** The auto-generated test certificate is only trusted on your machine.
> For public distribution, buy a code-signing certificate (DigiCert / Sectigo, ~$100–300/yr)
> and set `certificate_path` + `certificate_password` in msix_config.

### Package — ZIP (quick distribution)
```powershell
Compress-Archive -Path "build\windows\x64\runner\Release\*" `
  -DestinationPath "FocusGuard-1.0.1-windows.zip"
```

Recipient extracts and runs `focusguard.exe` directly. No install needed.

### Known Issues
| Issue | Fix |
|-------|-----|
| MSVC 14.51+ blocks `<experimental/coroutine>` | `_SILENCE_EXPERIMENTAL_COROUTINE_DEPRECATION_WARNINGS` already added to `windows/CMakeLists.txt` |
| Build fails with generic "exited with code 1" | Run again — usually a stale incremental cache |

---

## Android

### Prerequisites
- Android Studio or Android SDK CLI tools
- `ANDROID_HOME` environment variable set
- A connected device or running emulator (`flutter devices` to list)

### Dev Run
```bash
flutter run -d <device-id>
flutter run                    # picks the only connected device
flutter run --debug            # explicit debug mode
```

### Release Build — APK (sideloading / direct download)
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Split per ABI (smaller per-device file, ~40% smaller):
flutter build apk --split-per-abi --release
# Outputs: app-armeabi-v7a-release.apk, app-arm64-v8a-release.apk, app-x86_64-release.apk
```

### Release Build — AAB (Google Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### Signing for Production
Without a keystore, release APKs are signed with a debug key (not accepted by Play Store).

**1. Generate keystore (one-time):**
```bash
keytool -genkey -v -keystore focusguard.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias focusguard
```

**2. Create `android/key.properties`:**
```
storePassword=<password>
keyPassword=<password>
keyAlias=focusguard
storeFile=../focusguard.jks
```

**3. Reference in `android/app/build.gradle`:**
```groovy
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    buildTypes {
        release {
            signingConfig signingConfigs.release
        }
    }
}
```

> Keep `focusguard.jks` and `key.properties` out of git (add to `.gitignore`).

---

## iOS

### Prerequisites
- macOS machine (required — cannot build iOS on Windows/Linux)
- Xcode (latest stable)
- Apple Developer account ($99/yr for distribution)
- CocoaPods: `sudo gem install cocoapods`

### Dev Run
```bash
flutter run -d <ios-device-id>
flutter run                      # picks connected iPhone/iPad
open -a Simulator                # launch iOS Simulator first
flutter run -d iPhone            # run on Simulator
```

### Release Build
```bash
flutter build ios --release
# Output: build/ios/iphoneos/Runner.app
```

### App Store Distribution (IPA)
```bash
# 1. Build
flutter build ipa --release
# Output: build/ios/ipa/FocusGuard.ipa

# 2. Upload via Transporter or Xcode Organizer
open build/ios/archive/Runner.xcarchive
```

Or via Xcode:
1. `open ios/Runner.xcworkspace`
2. Product → Archive
3. Distribute App → App Store Connect

### TestFlight (beta)
Upload the IPA to App Store Connect, then distribute via TestFlight.

### Signing
- Requires an Apple Developer team set in Xcode: `ios/Runner.xcworkspace → Signing & Capabilities`
- Set `DEVELOPMENT_TEAM` in `ios/Runner.xcodeproj/project.pbxproj` or via Xcode GUI

---

## macOS

### Prerequisites
- macOS machine
- Xcode (latest stable)
- Apple Developer account (for notarization / Mac App Store)

### Dev Run
```bash
flutter run -d macos
```

### Release Build
```bash
flutter build macos --release
# Output: build/macos/Build/Products/Release/FocusGuard.app
```

### Package — DMG
Flutter doesn't create a DMG automatically. Use `create-dmg`:

```bash
brew install create-dmg

create-dmg \
  --volname "FocusGuard" \
  --window-size 600 400 \
  --icon-size 100 \
  --app-drop-link 450 180 \
  "FocusGuard-1.0.1.dmg" \
  "build/macos/Build/Products/Release/FocusGuard.app"
```

### Notarization (required for Gatekeeper on other Macs)
```bash
# Codesign
codesign --deep --force --verify --verbose \
  --sign "Developer ID Application: <Your Name> (<Team ID>)" \
  build/macos/Build/Products/Release/FocusGuard.app

# Notarize
xcrun notarytool submit FocusGuard-1.0.1.dmg \
  --apple-id your@email.com \
  --team-id <Team ID> \
  --password <app-specific-password> \
  --wait

# Staple
xcrun stapler staple FocusGuard-1.0.1.dmg
```

---

## Linux

### Prerequisites
```bash
sudo apt-get install clang cmake ninja-build pkg-config \
  libgtk-3-dev liblzma-dev libstdc++-12-dev
```

### Dev Run
```bash
flutter run -d linux
```

### Release Build
```bash
flutter build linux --release
# Output: build/linux/x64/release/bundle/
```

The bundle folder contains the executable and all required libraries:
```
focusguard
lib/
data/
```

### Package — AppImage
```bash
# Install appimagetool
wget https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage
chmod +x appimagetool-x86_64.AppImage

# Structure the AppDir
mkdir -p FocusGuard.AppDir/usr/bin
cp -r build/linux/x64/release/bundle/* FocusGuard.AppDir/usr/bin/
# Add .desktop file and icon, then:
./appimagetool-x86_64.AppImage FocusGuard.AppDir FocusGuard-1.0.1.AppImage
```

### Package — .deb
```bash
# Create package structure
mkdir -p focusguard-pkg/usr/bin
mkdir -p focusguard-pkg/usr/share/applications
mkdir -p focusguard-pkg/DEBIAN

cp -r build/linux/x64/release/bundle/* focusguard-pkg/usr/bin/

# Create control file
cat > focusguard-pkg/DEBIAN/control << EOF
Package: focusguard
Version: 1.0.1
Architecture: amd64
Maintainer: Niranjan Madak
Description: Deep Work Focus Timer
EOF

dpkg-deb --build focusguard-pkg FocusGuard-1.0.1.deb
```

---

## All-Platform Quick Reference

| Platform | Dev Run | Release Build | Installer |
|----------|---------|---------------|-----------|
| Windows | `flutter run -d windows` | `flutter build windows --release` | `dart run msix:create` |
| Android | `flutter run -d <id>` | `flutter build apk --release` | `flutter build appbundle` (Play Store) |
| iOS | `flutter run -d <id>` | `flutter build ios --release` | `flutter build ipa` |
| macOS | `flutter run -d macos` | `flutter build macos --release` | `create-dmg` |
| Linux | `flutter run -d linux` | `flutter build linux --release` | `appimagetool` / `dpkg-deb` |

---

## Production Checklist

Before shipping any platform:

- [ ] Bump version in `pubspec.yaml` (`version` + `msix_config.msix_version` for Windows)
- [ ] Run `flutter analyze` — zero errors
- [ ] Run `flutter test` — all pass
- [ ] Test release build locally (not debug)
- [ ] Verify sounds play correctly in release mode
- [ ] Verify notifications fire correctly
- [ ] Windows: production code-signing certificate configured
- [ ] Android: release keystore configured, not in git
- [ ] iOS/macOS: Apple Developer account, provisioning profiles valid
- [ ] Update `CHANGELOG.md` with release notes
