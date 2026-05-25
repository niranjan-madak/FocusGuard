# BUNDLE_OPTIMIZATION — FocusGuard

Framework: Flutter/Dart. Updated 2026-05-25.

## Overview

FocusGuard is a Flutter desktop/mobile application. Traditional web-bundle optimization (code splitting, tree-shaking JS bundles) does not apply. This document covers Flutter-specific build size and runtime optimization.

**Current Status:** Already well-optimized. No significant action required.

---

## Installer / Package Size

### Per-Platform Estimates

| Platform | Format | Approximate Size |
|----------|--------|-----------------|
| Windows | MSIX / EXE | 60–80 MB |
| macOS | DMG | 60–80 MB |
| Linux | AppImage / deb | 50–70 MB |
| Android | APK | 20–40 MB |
| iOS | IPA | 30–50 MB |

**Breakdown (all platforms):**
- Flutter engine (Skia/Impeller + Dart VM): ~40–60 MB
- App code + widgets: <1 MB
- Assets (WAV files + fonts via google_fonts): ~5 MB

**Note:** Flutter is significantly smaller than the previous Electron runtime (~80–100 MB for Electron vs ~50–70 MB for Flutter).

---

## Optimization Strategies

### Already Implemented

- ✅ Minimal runtime dependencies (6 packages)
- ✅ No production network access (fully offline)
- ✅ WAV audio files (no decode overhead vs MP3)
- ✅ `google_fonts` package bundles fonts — no CDN at runtime
- ✅ Flutter tree-shaking removes unused Dart code at build time
- ✅ `--release` builds enable AOT compilation (smaller, faster than JIT)

---

### Flutter-Specific Build Optimizations

#### Release vs Debug Build Size

```bash
# Always use --release for distribution builds
flutter build apk --release      # ~20-40 MB
flutter build apk --debug        # ~100+ MB (includes JIT, debug info)

flutter build windows --release  # ~60-80 MB
flutter build windows --debug    # ~200+ MB
```

**Rule:** Never distribute debug builds.

---

#### Android APK vs AAB

```bash
# APK — universal (larger, for sideloading)
flutter build apk --release

# AAB — Android App Bundle (smaller, for Play Store)
flutter build appbundle --release
```

**Recommendation:** Use AAB for Play Store (Google splits by ABI/density). Use APK for direct distribution.

---

#### ARM Split (Android)

```bash
# Split APK per ABI (smaller per-device download)
flutter build apk --split-per-abi --release
# Produces: armeabi-v7a, arm64-v8a, x86_64 APKs
```

**Impact:** Reduces download size by ~40% per device. Use for direct distribution if targeting specific device types.

---

### Potential Optimizations

#### Low Priority (already fast)

- **Cap `history` list at ~200 entries** — Prevents unbounded `TimelineDots` growth after very long sessions (see `DATA_MODELS.md`)
- **`const` constructors on all static widgets** — Minor rebuild optimization, cosmetic improvement
- **Font subsetting** — `google_fonts` bundles full fonts; subsetting would reduce asset size by ~20–50 KB (negligible)

#### Not Applicable

- Code splitting — Flutter handles this natively via tree-shaking
- Lazy loading — App loads instantly (~1.5–2.5s cold start)
- JS minification — No JavaScript
- Web bundle limits — Not a web app
- ASAR packaging — Electron-only concept
- Webpack/Rollup — Not used

---

## Dependency Optimization

### Current Dependencies

**Runtime (6 packages):**
- `provider` ^6.1.2
- `audioplayers` ^6.1.0
- `flutter_local_notifications` ^18.0.1
- `wakelock_plus` ^1.2.10
- `shared_preferences` ^2.3.3
- `google_fonts` ^6.2.1

**Dev (1 package):**
- `flutter_lints` ^5.0.0

**Transitive:** ~30–50 additional packages (from Flutter SDK + audioplayers native bindings)

### Dependency Audit

**Status:** No unnecessary dependencies.  
All dependencies are essential to core functionality.

---

## Code Size

### Dart Code

| File | Lines |
|------|-------|
| `lib/main.dart` | ~30 |
| `lib/models/timer_model.dart` | ~220 |
| `lib/services/audio_service.dart` | ~60 |
| `lib/services/notification_service.dart` | ~70 |
| `lib/screens/home_screen.dart` | ~200 |
| `lib/widgets/*.dart` | ~300 total |
| `lib/theme.dart` | ~40 |

**Total:** ~920 lines. Flutter AOT compiles this to ~200–500 KB native code, negligible vs engine.

---

## Asset Optimization

### Current Assets

| Asset | Format | Approximate Size |
|-------|--------|-----------------|
| `assets/sounds/focus_alarm.wav` | WAV | ~100–300 KB |
| `assets/sounds/break_alarm.wav` | WAV | ~100–300 KB |
| `assets/sounds/click.wav` | WAV | ~10–30 KB |
| `assets/sounds/tick.wav` | WAV | ~5–15 KB |

**Total assets:** ~500 KB

### Audio Format

**Current:** WAV (uncompressed, lowest decode overhead)  
**Alternative:** MP3/OGG (smaller files, ~30–50 KB each, but requires decode)

**Recommendation:** WAV is fine for these small files. No optimization needed.

---

## Performance Optimization

### Startup Time

**Current:** ~1.5–2.5s cold start  
**Target:** <3 seconds ✅

**What to avoid adding:**
- Heavy `main()` initialization beyond current `AudioService.init()` + `NotificationService.init()`
- Synchronous file I/O at startup
- Large asset preloading

---

### Memory Usage

**Current:** ~80–160 MB (Flutter runtime + Dart VM + four AudioPlayer instances)  
**Target:** <200 MB ✅

---

### CPU Usage

**Current:** <1% idle, ~2–5% during alarm playback  
**Target:** <5% ✅

---

## Size Monitoring

### Recommended Tools

```bash
# Flutter build size report (Android)
flutter build apk --analyze-size --release

# Flutter build size report (other platforms)
flutter build <platform> --analyze-size --release
```

This generates a `*-code-size-analysis_01.json` file viewable in Dart DevTools.

---

## Size Budgets (Recommended)

| Platform | Budget |
|----------|--------|
| Android APK | <50 MB |
| iOS IPA | <60 MB |
| Windows installer | <100 MB |
| macOS DMG | <100 MB |
| Linux AppImage | <100 MB |

**Current Status:** All within budget ✅

---

## Optimization Summary

**Current Status:** Already well-optimized.

**Key strengths:**
- Flutter runtime is ~30% smaller than previous Electron runtime
- AOT compilation produces fast, compact native code
- Fully offline — zero network overhead
- Small asset footprint (~500 KB)
- Minimal dependencies

**Recommendations:**
- No major optimizations needed
- Use `--release` builds always for distribution
- Use AAB format for Play Store
- Consider `--split-per-abi` for Android sideloading

**Optimization Philosophy:** Flutter handles most optimization automatically (tree-shaking, AOT). Focus on not adding unnecessary dependencies or blocking startup operations.
