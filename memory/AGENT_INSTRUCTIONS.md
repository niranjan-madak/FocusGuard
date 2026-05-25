# AGENT_INSTRUCTIONS — FocusGuard

Framework: Flutter/Dart. Updated 2026-05-25.

## Agent Context

You are working on the **FocusGuard** project, a cross-platform focus timer application built with Flutter/Dart.

**Project Type:** EXISTING (production-ready)  
**Tech Stack:** Flutter + Dart + Provider (ChangeNotifier)  
**Complexity:** LOW (small codebase, ~900 lines of Dart)  
**Platform targets:** Android, iOS, Windows, macOS, Linux

---

## Before Starting Work

### Pre-Change Checklist

**Read These Files First:**
1. `memory/ARCHITECTURE.md` — Flutter single-process architecture
2. `memory/SECURITY.md` — Offline-by-design security posture
3. `memory/CODING_STANDARDS.md` — Dart naming and widget conventions
4. `memory/API_REFERENCE.md` — TimerModel public API

**Verify:**
- [ ] You understand the project is EXISTING, not greenfield
- [ ] You understand the Provider (ChangeNotifier) state management pattern
- [ ] You know which files are critical (timer_model.dart, home_screen.dart)
- [ ] You follow existing Dart/Flutter patterns

---

## Making Changes

### Code Changes

**Rules:**
1. Follow existing Dart code style (`CODING_STANDARDS.md`)
2. Maintain offline-by-design posture (no new network access)
3. Don't break existing features
4. Test on target platform(s) if possible
5. Update relevant `/memory/` documentation

**Process:**
1. Read the affected Dart files
2. Understand the existing Provider pattern
3. Make minimal changes
4. Test the changes
5. Update documentation

---

### Adding Features

**Rules:**
1. Follow Provider (ChangeNotifier) state management pattern
2. Add new state to `TimerModel` if needed
3. Add new widgets to `lib/widgets/` if needed
4. Update `FEATURES.md`
5. Update `API_REFERENCE.md` if adding to `TimerModel`

**Process:**
1. Design the feature — does state go in `TimerModel`?
2. Add state fields and methods to `TimerModel` if needed
3. Call `notifyListeners()` after state mutation
4. Build widget using `context.watch<TimerModel>()` or `context.read<TimerModel>()`
5. Test thoroughly
6. Update documentation

---

### Fixing Bugs

**Rules:**
1. Reproduce the bug first
2. Write a test (when test suite exists)
3. Fix with minimal changes
4. Verify fix
5. Update `CHANGELOG.md`

**Process:**
1. Understand the bug
2. Find root cause (likely in `timer_model.dart` or a widget's interaction with it)
3. Write failing test (when possible)
4. Implement fix
5. Verify all tests pass

---

## File-Specific Guidelines

### lib/models/timer_model.dart

**Purpose:** All timer state and business logic  
**Critical:** YES — central ChangeNotifier, core product logic

**Rules:**
- Keep all business logic here (not in widgets)
- Call `notifyListeners()` after every state mutation
- Cancel `_ticker` before starting a new one
- Don't add synchronous blocking operations

---

### lib/screens/home_screen.dart

**Purpose:** Main UI scaffold, keyboard shortcuts, wakelock  
**Critical:** HIGH — composes all widgets

**Rules:**
- Keep `_settingsOpen` bool state here (local UI state)
- Do not add business logic — delegate to `TimerModel`
- `WakelockPlus.toggle()` call must remain on every rebuild
- `KeyboardListener` handles SPACE, Ctrl+K, Ctrl+R, Ctrl+M

---

### lib/services/audio_service.dart

**Purpose:** WAV file playback via audioplayers  
**Critical:** MEDIUM — user experience only

**Rules:**
- Four `AudioPlayer` instances are created once and reused
- Call `init()` in `main()` before `runApp()`
- `playAlarm(bool isFocus, ...)` — `isFocus` is the **new** mode after toggle

---

### lib/services/notification_service.dart

**Purpose:** OS notification via flutter_local_notifications  
**Critical:** LOW — fallback alert when app is backgrounded

**Rules:**
- Call `init()` in `main()` before `runApp()`
- Uses single notification ID `0` (replaces previous)
- Sound is disabled — app plays its own alarm sound

---

### lib/theme.dart

**Purpose:** Color constants and font helpers  
**Critical:** LOW — visual only

**Rules:**
- All colors go in abstract class `C`
- Use `C.focus` (amber) for focus mode, `C.brk` (cyan) for break mode
- Font helpers: `C.orbitron()`, `C.mono()`, `C.exo()`

---

### lib/widgets/

**Purpose:** Reusable Flutter widgets  
**Critical:** MEDIUM — UI components

**Rules:**
- Prefer `StatelessWidget` unless local animation state is needed
- Use `context.watch<TimerModel>()` to read state that causes rebuild
- Use `context.read<TimerModel>()` in callbacks (does NOT rebuild)
- No business logic in widgets — call `TimerModel` methods only

---

## Security Rules

### Offline-First Design

**Critical Rules:**
- ❌ Never add network requests to the app
- ❌ Never add external API calls or analytics
- ❌ Never store sensitive user data
- ❌ Never add dependencies with network access without justification

**Current Posture:**
- Zero network access at runtime
- No sensitive data stored
- OS sandboxed process
- All assets bundled locally

---

## Testing Rules

### Current Status: No Tests

**When Test Suite Exists:**
- Write tests before code (TDD — see `TDD_PROTOCOL.md`)
- Maintain 80% coverage
- 100% coverage for `TimerModel` business logic
- Use `mockito` for `AudioService` and `NotificationService`
- Use `fake_async` for `Timer.periodic` control

**Before Test Suite Exists:**
- Manual test thoroughly
- Test on target platform
- Document test steps

---

## Documentation Rules

### Update After Any Change

**Which Files to Update:**
- `FEATURES.md` — for new features
- `API_REFERENCE.md` — for `TimerModel` changes
- `DATA_MODELS.md` — for state model changes
- `ARCHITECTURE.md` — for architecture changes
- `SECURITY.md` — for security posture changes
- `CHANGELOG.md` — for user-facing releases
- `CODING_STANDARDS.md` — for new patterns
- `DEPENDENCIES.md` — for new packages

---

## Platform Considerations

### Cross-Platform Testing

**Platforms:** Android, iOS, Windows, macOS, Linux

**Key differences:**
- `WakelockPlus` — Android/iOS only (no-op on desktop)
- `flutter_local_notifications` — Android, iOS, Windows, Linux (macOS not configured)
- Keyboard shortcuts — desktop only (`KeyboardListener` requires window focus)
- No system tray on any platform

**Rules:**
- Test on your platform
- Consider platform differences
- Don't break platform-specific features
- Document platform limitations

---

## Performance Rules

### Maintain Performance

**Targets:**
- Cold start: <3 seconds
- Idle memory: <200 MB
- CPU: <1% idle, <5% alarm

**Rules:**
- Don't add heavy dependencies
- Don't add blocking `main()` calls
- Use `const` constructors on static widgets
- Don't call `notifyListeners()` more than necessary

---

## Common Tasks

### Adding a New TimerModel Setting

1. Add field to `TimerModel` class
2. Add setter method (call `notifyListeners()`)
3. Wire up persistence in `shared_preferences` (when implemented)
4. Add UI in `SettingsPanel` widget
5. Update `API_REFERENCE.md` and `DATA_MODELS.md`
6. Test thoroughly

### Adding a New Widget

1. Create `lib/widgets/<name>.dart`
2. Use `StatelessWidget` unless animation state needed
3. Accept data via constructor params (or `context.watch<TimerModel>()`)
4. Add to `CODEBASE_MAP.md` in agent-memory

### Adding a New Keyboard Shortcut

1. Add handler in `home_screen.dart` `KeyboardListener` block
2. Match pattern: `if (event is KeyDownEvent && ...)`
3. Update `FEATURES.md` and `UX_STANDARDS.md`
4. Note: shortcuts are NOT global — only when app window has focus

### Adding a Dependency

1. Add to `pubspec.yaml` under `dependencies` or `dev_dependencies`
2. Run `flutter pub get`
3. Update `DEPENDENCIES.md`
4. Check: does it require permissions? network? native code?

---

## Questions to Ask

### When Uncertain

**Ask Before:**
- Adding new dependencies
- Adding any network access (breaks offline design)
- Breaking existing features
- Changing `TimerModel` public API

**Don't Ask:**
- How to implement simple Dart features (read code first)
- Code style questions (read `CODING_STANDARDS.md`)
- File locations (read `CODEBASE_MAP.md` in agent-memory)

---

## Post-Change Checklist

### Before Marking Task Complete

**Code Quality:**
- [ ] Code follows `CODING_STANDARDS.md` (Dart conventions)
- [ ] No `print()` statements (use `debugPrint()` only in dev)
- [ ] No commented-out code
- [ ] `const` constructors used where applicable

**Security:**
- [ ] No new network access added
- [ ] No sensitive data exposed
- [ ] Offline posture maintained

**Functionality:**
- [ ] Feature works as expected
- [ ] No existing features broken
- [ ] Tested on target platform

**Documentation:**
- [ ] Relevant `/memory/` docs updated
- [ ] `CHANGELOG.md` updated (if user-facing)

---

## Summary

**Your Role:** Product engineer maintaining an existing, production-ready Flutter application

**Key Principles:**
- Respect Provider (ChangeNotifier) architecture
- Keep business logic in `TimerModel`
- Maintain offline-first posture
- Follow Dart/Flutter patterns
- Update documentation after every change

**Critical Rules:**
- Never add network access
- Never break existing features
- Never add unnecessary dependencies
- Always follow `CODING_STANDARDS.md`
- Always update `/memory/` docs

**Project Context:** Small, well-architected, offline-first Flutter app. Improve incrementally.
