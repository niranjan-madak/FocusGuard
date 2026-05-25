# CODING_STANDARDS — FocusGuard

Framework: Flutter/Dart. Standards updated 2026-05-25.

---

## Dart / Flutter Style

FocusGuard follows the official [Dart style guide](https://dart.dev/effective-dart/style) enforced by `flutter_lints`.

### Naming Conventions

| Element | Style | Example |
|---------|-------|---------|
| Classes, enums, typedefs | UpperCamelCase | `TimerModel`, `AudioService` |
| Variables, parameters, functions | lowerCamelCase | `secsLeft`, `toggleStartStop()` |
| Constants | lowerCamelCase | `focusMins`, `defaultVolume` |
| Private members | `_` prefix | `_ticker`, `_start()` |
| Files | snake_case | `timer_model.dart`, `audio_service.dart` |
| Packages | snake_case | `focusguard` |

### Indentation

2 spaces (Dart default). Enforced by `dart format`.

### Line Length

80 characters (Dart default). Enforced by `dart format`.

### Trailing commas

Add trailing commas on multi-line argument lists and widget trees — enables cleaner diffs and auto-formatting.

```dart
// ✅ Good
Column(
  children: [
    ProgressRing(...),
    StatsBar(...),
  ],
)
```

---

## Widget Architecture

### Stateless vs Stateful

Prefer `StatelessWidget`. Only use `StatefulWidget` when local widget state is required (e.g., animation controllers, `_settingsOpen` toggle).

```dart
// ✅ Good: stateless, reads from Provider
class StatsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final m = context.watch<TimerModel>();
    // ...
  }
}

// ✅ Acceptable: stateful only for animation controller
class _StatusBadge extends StatefulWidget { ... }
```

### Business Logic

Business logic belongs in `TimerModel`, **not** in widgets or screens.

```dart
// ✅ Good: logic in model
onTap: m.toggleStartStop,

// ❌ Bad: logic in widget
onTap: () {
  if (!m.running) { m.running = true; ... }
}
```

### Provider Access

Use `context.watch<T>()` for reactive reads (rebuilds on change). Use `context.read<T>()` for one-time reads (e.g., in callbacks, where rebuild is not needed).

```dart
// ✅ Reactive read in build()
final m = context.watch<TimerModel>();

// ✅ One-time read in callback
onTap: () => context.read<TimerModel>().skip(),
```

---

## File Organization

Each file has a single responsibility:

```
lib/
├── main.dart                    # Entry point only — no business logic
├── theme.dart                   # Colors + font helpers only
├── models/timer_model.dart      # All timer state + logic
├── services/audio_service.dart  # Audio only
├── services/notification_service.dart  # Notifications only
├── screens/home_screen.dart     # Main UI + keyboard handler
└── widgets/                     # One widget per file
```

### File Length

Keep files under 300 lines. Split by responsibility if exceeded.

---

## Comments

Write comments only when the **why** is non-obvious. Do not describe what the code does (the code does that).

```dart
// ✅ Good — explains a non-obvious constraint
// playAlarm is called with the NEW isFocus value (after toggling),
// so the alarm type matches the session that just ended.
if (soundEnabled) audio.playAlarm(isFocus, volume);

// ❌ Bad — describes what the code obviously does
// Decrement secsLeft by 1
secsLeft--;
```

---

## Error Handling

- Dart is null-safe — use `?` and `!` correctly; avoid `!` unless null is truly impossible
- Services (`AudioService`, `NotificationService`) should not throw — catch internally and degrade gracefully
- Do not rethrow exceptions from audio/notification failures; log and continue

```dart
// ✅ Good
try {
  await p.play(AssetSource(path));
} catch (e) {
  debugPrint('Audio play failed: $e');
}
```

---

## State Management Rules

1. All timer state is in `TimerModel` — never duplicate in widgets
2. Always call `notifyListeners()` after mutating state
3. Never mutate `TimerModel` state from outside `TimerModel`
4. `dispose()` must cancel `_ticker` — already implemented

---

## Formatting

Run before committing:

```bash
dart format lib/
flutter analyze
```

`flutter analyze` runs `flutter_lints` rules from `analysis_options.yaml`.

---

## Git Standards

### Commit Messages

Conventional Commits format:

```
feat(timer): add tick sound in last 10 seconds
fix(audio): dispose players on app exit
docs(memory): sync docs to Flutter rewrite
```

Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`

### Branch Naming

`<type>/<description>`

```
feature/settings-persistence
fix/wakelock-on-break
docs/update-memory-docs
```

---

## Code Review Checklist

- [ ] No business logic in widgets
- [ ] `notifyListeners()` called after every state mutation in `TimerModel`
- [ ] `_ticker` cancelled before any reset/skip
- [ ] Audio/notification errors caught and logged, not thrown
- [ ] New widgets use `StatelessWidget` unless local state is genuinely needed
- [ ] `context.watch` in `build()`, `context.read` in callbacks
- [ ] Trailing commas on multi-line widget trees
- [ ] `dart format` applied
- [ ] `flutter analyze` passes with zero warnings

---

## Summary

**Key principles:**
- Dart naming and formatting conventions enforced by tooling
- Business logic in `TimerModel`, not in widgets
- Stateless widgets by default
- Provider: watch in build, read in callbacks
- Comments explain why, not what
