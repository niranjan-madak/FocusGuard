# PROJECT_CONTEXT — FocusGuard

## Project Type

**Classification:** EXISTING PROJECT (post-Electron-to-Flutter rewrite)
**Development Stage:** Active
**Release Status:** v1.0.1+2

---

## Codebase Health

### Age

**Estimated Age:** < 2 years (Electron version ~Q4 2024; Flutter rewrite ~2026)

### Developers

**Team Size:** 1 developer (solo project)

### Documentation

**Status:** Complete (synced 2026-05-25)
- ✅ README.md
- ✅ AGENT_PROMPT.md
- ✅ /memory/ folder — 27 files covering architecture, features, security, etc.

### Test Suite

**Status:** None
- ❌ No tests
- ❌ No test framework configured (flutter_test is available)
- ❌ No CI/CD

### Known Problems

**Technical Debt:**
- No tests (highest priority debt)
- No CI/CD
- `shared_preferences` declared but not wired — settings and state not persisted

---

## Foundation Decisions

### Technology

- **Framework:** Flutter / Dart
- **State:** Provider (ChangeNotifier)
- **Audio:** audioplayers (WAV files)
- **Notifications:** flutter_local_notifications
- **Fonts:** google_fonts package

### Platform Targets

Android, iOS, Windows, macOS, Linux

### Existing Infrastructure

**Hosting:** None (offline desktop/mobile app)
**CI/CD:** None (manual builds)
**Version Control:** Git / GitHub

---

## Product Context

### Business Domain

**Category:** Productivity / Focus / Time Management

### Primary Users

**Persona:** Knowledge workers, developers, writers, students
**User Type:** B2C (individual users)

### Business Model

**Model:** Free / Open Source
**Revenue:** None

---

## Technical Context

### Greenfield vs Existing

**Type:** EXISTING (Flutter rewrite of prior Electron app)
**Implications:**
- Respect existing architecture and widget patterns
- Improve incrementally (persistence, tests)
- Don't rewrite working code without reason

### Architecture

**Pattern:** Flutter single-process, Provider for state management
- `TimerModel` (ChangeNotifier) — all state and logic
- `AudioService` — audio playback
- `NotificationService` — OS notifications
- `HomeScreen` + widgets — UI layer

**Previous architecture (removed):** Three-process Electron (main/preload/renderer)

### Technical Debt

**High Priority:**
- No tests — `flutter_test` is available, write unit tests for `TimerModel` first
- `shared_preferences` not wired — settings don't persist across restarts

**Medium Priority:**
- No CI/CD pipeline
- No code signing for distribution

**Low Priority:**
- No system tray (not critical for mobile-first distribution)

---

## Security Context

**Level:** Appropriate for scope
**Attack Surface:** None (fully offline, no auth, no network)
**Posture:** OS-level sandboxing per platform, minimal dependencies

See SECURITY.md for full details.

---

## Performance Context

**Requirements:**
- Startup: < 3 seconds ✅
- Timer precision: ±1 second (Dart `Timer.periodic`) ✅
- Memory: Typical Flutter app range (~80–150 MB) ✅

---

## Deployment Context

### Distribution

**Method:** Direct download / build from source
**Platforms:** Android, iOS, Windows, macOS, Linux
**Build:** `flutter build <platform>`

### Release Process

**Current:** Manual
- Build per platform
- Upload to GitHub Releases

### Update Mechanism

**Current:** None (manual reinstall)

---

## Development Guidelines

### When Making Changes

1. Follow existing widget patterns (stateless where possible, watch `TimerModel`)
2. Keep business logic in `TimerModel` — not in widgets or screens
3. Services (`AudioService`, `NotificationService`) should remain thin wrappers
4. Update /memory/ docs after any significant change (post-change protocol)
5. No untested changes to `TimerModel._tick()` or `_onSessionEnd()` — these are the core flows

### When Adding Features

1. Define state changes in `TimerModel` first
2. Build widgets that consume state reactively
3. Write tests before or alongside implementation
4. Update FEATURES.md and CHANGELOG.md

---

## Summary

**Project Type:** Existing Flutter app (rewritten from Electron)
**Domain:** Productivity / Focus timer
**Scale:** Individual users, no infrastructure
**Complexity:** Low (small codebase, clear separation of concerns)
**Technical Debt:** Moderate (no tests, no persistence, no CI/CD)
**Posture:** Maintain and improve incrementally

**Key Insight:** The Flutter rewrite is clean and well-structured. Priority next steps are: (1) wire shared_preferences for settings persistence, (2) add unit tests for TimerModel, (3) add widget tests for key UI components.
