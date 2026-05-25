# TECH_DECISIONS — FocusGuard

Updated: 2026-05-25. Records significant architectural/technology decisions.

## ADR-001: Rewrite from Electron to Flutter

Date: 2026
Status: Accepted — current implementation

### Decision

Rewrite the entire FocusGuard application in Flutter/Dart, replacing the Electron + Vanilla JavaScript implementation.

### Reasoning

- Mobile support (Android/iOS) — Electron cannot run on mobile
- Smaller runtime footprint vs Electron (~50 MB vs ~80 MB)
- Single Dart codebase for mobile + desktop
- Strongly typed, null-safe language improves maintainability
- No multi-process IPC complexity

### Alternatives considered

- Keep Electron: no mobile support
- Tauri: Rust learning curve, no mobile at time of decision
- React Native: weaker desktop support than Flutter

### Consequences

- System tray and global media keys were dropped (no Flutter equivalent)
- Audio requires bundled WAV files (vs Web Audio API synthesis)
- Security model is simpler (OS sandbox, no CSP/contextBridge) — appropriate for local-only app
- State management via Provider instead of a plain JS object

---

## ADR-002: Provider (ChangeNotifier) for State Management

Date: 2026
Status: Accepted

### Decision

Use the `provider` package with `ChangeNotifier` as the sole state management layer.

### Reasoning

- Official Flutter recommendation for apps of this scope
- `TimerModel` cleanly encapsulates all timer state and business logic
- `context.watch<TimerModel>()` is readable and ergonomic
- No need for streams or complex event flows

### Alternatives considered

- Riverpod: more boilerplate for a single-model app
- Bloc/Cubit: stream-based, overkill for simple timer
- setState only: state needs to be shared across multiple widgets

### Consequences

- Single `TimerModel` instance is the source of truth
- All UI rebuilds driven by `notifyListeners()`

---

## ADR-003: audioplayers for Audio (WAV files)

Date: 2026
Status: Accepted

### Decision

Use `audioplayers` package with four dedicated `AudioPlayer` instances, each playing a specific WAV file from `assets/sounds/`.

### Reasoning

- Cross-platform (Android, iOS, Windows, macOS, Linux)
- Simple API; four players avoid interference between concurrent sounds
- WAV has no codec issues across platforms

### Alternatives considered

- Web Audio API: not available in Flutter
- just_audio / flutter_sound: heavier APIs, overkill for short sound effects

### Consequences

- Four WAV files added to bundle
- `AudioService` must be disposed properly (currently no explicit dispose in main)

---

## ADR-004: In-memory State (no persistence yet)

Date: 2026
Status: Accepted (temporary)

### Decision

Timer state and session history are kept in `TimerModel` in memory. `shared_preferences` is declared as a dependency but not yet wired.

### Reasoning

- Simplest implementation for initial release
- `shared_preferences` is already available when persistence is needed

### Next step

Wire `shared_preferences` to save `focusMins`, `breakMins`, `soundEnabled`, `autoStart`, `volume` on each settings change.

---

## Future Decisions to Document

- Code signing approach for Windows and macOS distribution
- System tray implementation (if added via community plugin)
- State persistence implementation via shared_preferences
- Test strategy (unit tests for TimerModel, widget tests for ProgressRing etc.)
