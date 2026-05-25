# TECH_STACK_DECISION — FocusGuard

## Technology Stack Summary

| Layer | Technology | Version | Rationale |
|-------|-----------|---------|-----------|
| **App Framework** | Flutter | SDK ^3.11.4 | Cross-platform (mobile + desktop), single Dart codebase |
| **Language** | Dart | ^3.11.4 | Required by Flutter, null-safe, strongly typed |
| **State Management** | Provider (ChangeNotifier) | ^6.1.2 | Lightweight, official Flutter recommendation for this scope |
| **Audio** | audioplayers | ^6.1.0 | Cross-platform WAV playback, simple API |
| **Notifications** | flutter_local_notifications | ^18.0.1 | Cross-platform OS notifications (Android/iOS/Windows/Linux) |
| **Wakelock** | wakelock_plus | ^1.2.10 | Keeps screen on during focus sessions |
| **Preferences** | shared_preferences | ^2.3.3 | Lightweight key-value persistence (not yet wired) |
| **Fonts** | google_fonts | ^6.2.1 | Orbitron, Share Tech Mono, Exo 2 via package (no CDN) |
| **Linting** | flutter_lints | ^6.0.0 | Official Flutter lint rules |

---

## Decision Records

### ADR-001: Flutter Rewrite (from Electron)

**Date:** 2026 (after v1.0.0 Electron release)
**Status:** Accepted — current implementation

#### Context

FocusGuard was originally built with Electron + Vanilla JavaScript. The decision was made to rewrite it in Flutter for better cross-platform mobile support, smaller runtime overhead, and a more maintainable Dart codebase.

#### Decision

Rewrite the entire application in Flutter/Dart.

#### Reasoning

**Pros:**
- True mobile support (Android/iOS) — Electron cannot run on mobile
- Smaller runtime than Electron (~50 MB vs ~80 MB)
- Single codebase covering mobile + desktop
- Dart is strongly typed, null-safe — more maintainable
- Flutter's widget system is well-suited for this UI scope
- Hot reload speeds up development
- No multi-process IPC complexity

**Cons:**
- Loss of system tray integration (no Flutter tray plugin)
- Loss of global media keys
- Dart learning curve vs JavaScript
- Some Electron security model specifics (CSP, contextBridge) not applicable
- Audio requires asset files (WAV) — previously Web Audio API needed no files

#### Alternatives Considered

**Keep Electron:**
- Rejected because mobile support was a priority
- Electron mobile is not a viable option

**Tauri (Rust):**
- Rejected due to Rust learning curve and no mobile support at the time

**React Native:**
- Rejected due to less complete desktop support
- Dart/Flutter preferred for single-codebase confidence

#### Consequences

- App now supports Android and iOS in addition to desktop
- System tray and global media keys were dropped
- Audio uses bundled WAV files instead of Web Audio API synthesis
- Security posture is simpler (no multi-process isolation) but equally appropriate for a local-only offline app
- State management uses Provider rather than a global JS object

#### Review Date

Re-evaluate if Flutter desktop support regresses or if Tauri adds first-class mobile support.

---

### ADR-002: Provider (ChangeNotifier) for State Management

**Date:** 2026
**Status:** Accepted

#### Context

Need to share timer state across multiple widgets efficiently.

#### Decision

Use `provider` package with `ChangeNotifier`.

#### Reasoning

**Pros:**
- Official Flutter recommendation for simple apps
- Minimal boilerplate for this scope
- `context.watch<TimerModel>()` is readable and ergonomic
- `ChangeNotifier` is in the Flutter SDK — no extra abstraction
- `TimerModel` holds all state and business logic cleanly

**Cons:**
- Not as scalable as Riverpod or Bloc for complex apps
- Manual `notifyListeners()` calls

#### Alternatives Considered

**Riverpod:**
- More powerful but more boilerplate for this scope
- Overkill for a single-model app

**Bloc / Cubit:**
- Stream-based, better for complex event flows
- Unnecessary ceremony for a simple timer

**setState (no Provider):**
- Rejected because `TimerModel` needs to be shared by multiple widgets

#### Consequences

- Single `TimerModel` is the source of truth for all timer state
- Widget rebuilds are driven by `notifyListeners()`
- Separation of concerns: UI in widgets, logic in `TimerModel`

---

### ADR-003: audioplayers for Audio Playback

**Date:** 2026
**Status:** Accepted

#### Context

Need to play alarm sounds, click feedback, and tick countdown.

#### Decision

Use `audioplayers` package with bundled WAV files.

#### Reasoning

**Pros:**
- Cross-platform (Android, iOS, Windows, macOS, Linux)
- Simple `play(AssetSource(...))` API
- Supports multiple concurrent players
- WAV files have no codec issues
- Low latency

**Cons:**
- Requires audio asset files in bundle (unlike Web Audio API synthesis)
- Four `AudioPlayer` instances in memory

#### Alternatives Considered

**Web Audio API (previous Electron approach):**
- Not available in Flutter

**flutter_sound:**
- More complex API, recording focus too
- Heavier for this use case

**just_audio:**
- Good alternative, but audioplayers is simpler for short sound effects

#### Consequences

- Four WAV files added to `assets/sounds/`
- `AudioService` manages four dedicated player instances
- Sound playback is offline (no streaming)

---

### ADR-004: flutter_local_notifications for OS Notifications

**Date:** 2026
**Status:** Accepted

#### Context

Need OS-level notifications when sessions end.

#### Decision

Use `flutter_local_notifications`.

#### Reasoning

**Pros:**
- Supports Android, iOS, Windows, Linux in one package
- Platform-specific configuration for each target
- High-priority, sound-disabled notifications
- No cloud/push service needed (fully local)

**Cons:**
- Verbose initialization per platform
- Android 13+ requires explicit permission request

#### Consequences

- Notifications initialized in `NotificationService.init()` for all four platforms
- Android requests notification permission at startup (Android 13+)
- Windows uses stable GUID and app user model ID

---

### ADR-005: google_fonts Package for Typography

**Date:** 2026
**Status:** Accepted

#### Context

Need Orbitron, Share Tech Mono, and Exo 2 fonts.

#### Decision

Use `google_fonts` Flutter package.

#### Reasoning

**Pros:**
- Fonts bundled with the package — no CDN dependency at runtime
- No manual font file management
- Same fonts as the Electron version (Orbitron, Share Tech Mono, Exo 2)
- Free, MIT-compatible

**Cons:**
- Package adds some size
- Fonts technically cached after first load by the package

#### Alternatives Considered

**Manual font asset files:**
- Would require downloading and managing font files
- More maintenance

**System fonts:**
- Poor aesthetic control across platforms

---

### ADR-006: In-Memory State (No Persistence Yet)

**Date:** 2026
**Status:** Accepted (temporary)

#### Context

Timer state and session history reset on app restart.

#### Decision

Keep state in-memory for now. `shared_preferences` is already a dependency but not yet wired to persist state.

#### Reasoning

- Simplest implementation first
- `shared_preferences` is available when ready to add persistence

#### Consequences

- App starts fresh each launch
- `shared_preferences` dependency is present — adding persistence is the next logical step

---

## Technology Constraints

### Team Expertise

**Dart / Flutter:** Medium-High (primary language for this project)
**JavaScript / Electron:** Former primary stack (pre-rewrite)

---

## Technology Risks

### Flutter Desktop Maturity

**Risk:** Flutter desktop support has rough edges on some platforms.

**Mitigation:**
- Target platforms tested individually
- Use stable Flutter channel

**Likelihood:** Low-Medium
**Impact:** Medium

### audioplayers Compatibility

**Risk:** Platform-specific audio issues on some Flutter targets.

**Mitigation:**
- Test on all target platforms
- Four dedicated players avoid interference between sounds

---

## Summary

**Technology Stack:** Flutter + Dart + Provider + audioplayers + flutter_local_notifications + google_fonts

**Key Decisions:**
- Flutter for cross-platform (mobile + desktop) from single codebase
- Provider/ChangeNotifier for simple, readable state management
- audioplayers for cross-platform WAV playback
- flutter_local_notifications for OS-level session alerts
- google_fonts package for offline font delivery
- In-memory state (shared_preferences available for future persistence)

**Trade-offs:**
- System tray and global media keys dropped (Electron-only features)
- Audio requires WAV asset files (vs Web Audio API synthesis)
- Dart learning curve vs JavaScript familiarity

**Review:** Stack is appropriate. Add state persistence via shared_preferences next.
