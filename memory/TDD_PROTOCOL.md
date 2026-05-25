# TDD_PROTOCOL — FocusGuard

Framework: Flutter/Dart. Updated 2026-05-25.

## TDD Status

**Current Status:** Not Implemented  
**Test Coverage:** 0%  
**Test Framework:** `flutter_test` (SDK — available, not yet used)

**Note:** This document outlines the TDD protocol to be implemented when tests are added.

---

## TDD Philosophy

FocusGuard follows Test-Driven Development principles:

**Core Rule:** No production code exists without a failing test that demanded it.

**Cycle:** Red → Green → Refactor

1. **Red:** Write a failing test
2. **Green:** Write minimum code to pass
3. **Refactor:** Clean without breaking tests

---

## TDD Workflow

### For New Features

1. **Understand** the feature requirement completely
2. **Design tests** — List all behaviors:
   - Happy path
   - Edge cases (empty, max, boundary)
   - Error cases (invalid input, service failure)
3. **Write first test** — Pick simplest case, write failing test
4. **Run** — Confirm it fails (Red): `flutter test`
5. **Code** — Write minimum code to pass (Green)
6. **Refactor** — Clean without breaking tests
7. **Repeat** — Next test case
8. **Document** — Update TESTING.md and this file

---

### For Bug Fixes

**Never fix a bug before writing a test:**

1. **Reproduce** — Understand exactly how to trigger the bug
2. **Write test** — Write failing test that fails BECAUSE of the bug
3. **Fix** — Write minimum code to make test pass
4. **Verify** — All tests pass including new regression test
5. **Commit** — Regression test stays permanently

**This bug will never silently return.**

---

## Test Structure

### Directory Structure

```
test/
├── models/
│   └── timer_model_test.dart
├── widgets/
│   ├── progress_ring_test.dart
│   ├── stats_bar_test.dart
│   ├── timeline_dots_test.dart
│   ├── alarm_banner_test.dart
│   └── settings_panel_test.dart
└── integration/
    └── timer_flow_test.dart
```

---

## Test Levels

### Unit Tests

**Purpose:** Test `TimerModel` state transitions and business logic in isolation

**What to Test:**
- State machine transitions (start, pause, resume, skip, reset)
- Timer tick logic
- Session end logic (alarm, history, counters)
- Derived getters (`progress`, `timeStr`, `statusText`)
- Edge cases (secsLeft == 0, secsLeft == 1)

**Tools:** `flutter_test` + `mockito` (mock AudioService and NotificationService) + `fake_async` (control Timer.periodic without real time)

**Example:**
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:focusguard/models/timer_model.dart';

class MockAudio extends Mock implements AudioService {}
class MockNotif extends Mock implements NotificationService {}

void main() {
  late TimerModel model;

  setUp(() {
    model = TimerModel(audio: MockAudio(), notif: MockNotif());
  });

  tearDown(() => model.dispose());

  test('initial secsLeft equals focusMins * 60', () {
    expect(model.secsLeft, equals(model.focusMins * 60));
  });

  test('toggleStartStop sets running to true', () {
    model.toggleStartStop();
    expect(model.running, isTrue);
    expect(model.paused, isFalse);
  });

  test('reset clears all state', () async {
    model.toggleStartStop();
    await model.reset();
    expect(model.running, isFalse);
    expect(model.sessionsCompleted, equals(0));
    expect(model.history, isEmpty);
    expect(model.isFocus, isTrue);
  });
}
```

---

### Widget Tests

**Purpose:** Test Flutter widget rendering and user interaction

**What to Test:**
- Widget renders correctly with given model state
- Button taps call correct methods on `TimerModel`
- Conditional widgets appear/disappear correctly

**Tools:** `flutter_test` + `WidgetTester` + `Provider` for injecting `TimerModel`

**Example:**
```dart
testWidgets('start button changes to PAUSE after tap', (tester) async {
  final model = TimerModel(audio: MockAudio(), notif: MockNotif());

  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: model,
      child: const MaterialApp(home: HomeScreen()),
    ),
  );

  expect(find.text('START'), findsOneWidget);
  await tester.tap(find.text('START'));
  await tester.pump();
  expect(find.text('PAUSE'), findsOneWidget);
});
```

---

### Integration Tests

**Purpose:** Test full timer flows on device/emulator

**File:** `test/integration/timer_flow_test.dart`

**What to Test:**
- Start timer → wait for tick → verify `secsLeft` decremented
- Complete session (with fast durations) → verify `history` updated

**Tools:** `integration_test` package (Flutter's official E2E framework)

---

## Test Naming

### Describe Behavior, Not Implementation

**✅ Good (Dart):**
```dart
test('secsLeft decrements by 1 on each tick when running', () { ... });
test('skip records session in history without triggering alarm', () { ... });
test('reset clears all counters and history', () { ... });
```

**❌ Bad:**
```dart
test('test timer');
test('model test');
test('it works');
```

### AAA Pattern

**Arrange-Act-Assert:**

```dart
test('progress returns 0.5 at halfway through session', () {
  // Arrange
  final model = TimerModel(audio: MockAudio(), notif: MockNotif());
  model.toggleStartStop(); // running

  // Act — manually set secsLeft to halfway
  // (test via fake_async advancing timer)

  // Assert
  expect(model.progress, closeTo(0.5, 0.01));
});
```

---

## Test Coverage Goals

### Minimum Coverage

- **Overall:** ≥ 80%
- **`TimerModel` business logic:** 100%

### Critical Paths to Test

1. Timer state machine (start → tick → session end)
2. Session transitions (focus → break → focus)
3. Pause / resume
4. Skip (no alarm)
5. Reset (all state cleared)
6. `applySettings` (updates durations + reset)
7. Sound controls (`toggleSound`, `setVolume`)

### Coverage Tools

```bash
flutter test --coverage
# View: genhtml coverage/lcov.info -o coverage/html
```

---

## CI/CD Integration

### Pipeline Gates

**Unit Tests:**
- MUST pass → PR cannot merge if any fail

**Coverage Threshold:**
- MUST meet 80% → block merge if below
- `TimerModel` MUST be 100%

### GitHub Actions Example

```yaml
name: Test

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      - run: flutter pub get
      - run: flutter test --coverage
```

---

## Forbidden in Tests

### ❌ Real Audio Playback

Mock `AudioService` — never play real sounds in tests.

### ❌ Real OS Notifications

Mock `NotificationService` — never show real notifications.

### ❌ Real `Timer.periodic` Delays

Use `fake_async` package to control time — never `await Future.delayed` in tests.

### ❌ Tests That Pass Locally but Fail in CI

Ensure tests are deterministic and environment-independent.

---

## Good Test Anatomy

### Example (TimerModel — Dart)

```dart
group('TimerModel state transitions', () {
  late TimerModel model;
  late MockAudio audio;
  late MockNotif notif;

  setUp(() {
    audio = MockAudio();
    notif = MockNotif();
    model = TimerModel(audio: audio, notif: notif);
  });

  tearDown(() => model.dispose());

  test('pause freezes secsLeft', () {
    model.toggleStartStop(); // running
    final secsBefore = model.secsLeft;
    model.toggleStartStop(); // paused

    expect(model.paused, isTrue);
    expect(model.secsLeft, equals(secsBefore));
  });

  test('skip records history without setting alarmActive', () {
    model.toggleStartStop();
    model.skip();

    expect(model.history, isNotEmpty);
    expect(model.alarmActive, isFalse);
  });
});
```

---

## Test Data

### Default State Reference

```dart
// Initial state for a fresh TimerModel
// secsLeft = 75 * 60 = 4500
// isFocus = true
// running = false
// paused = false
// sessionsCompleted = 0
// totalFocusSecs = 0
// cycles = 0
// history = []
// alarmActive = false
// volume = 0.7
// soundEnabled = true
// autoStart = true
```

---

## Test Speed

### Target Performance

- Unit tests: <100ms each (no real Timer, use fake_async)
- Widget tests: <500ms each
- Integration tests: <10s each (device-dependent)

---

## TDD Checklist

### Before Writing Code

- [ ] Test written for the behavior
- [ ] Test is failing (Red): `flutter test`
- [ ] Test describes behavior, not implementation

### After Writing Code

- [ ] Test passes (Green): `flutter test`
- [ ] No other tests broken
- [ ] Code is minimal (no over-engineering)
- [ ] Code is refactored (clean)
- [ ] All tests still pass

### Before Committing

- [ ] All tests pass: `flutter test`
- [ ] Coverage threshold met: `flutter test --coverage`
- [ ] No flaky tests
- [ ] Tests are fast (no real delays)

---

## Current Status

### Tests

- ❌ No unit tests
- ❌ No widget tests
- ❌ No integration tests

### Test Infrastructure

- ✅ `flutter_test` available (Flutter SDK dev dep)
- ❌ `mockito` not yet added to `pubspec.yaml`
- ❌ `fake_async` not yet added to `pubspec.yaml`
- ❌ No CI/CD integration

### Coverage

- **Overall:** 0%
- **Business Logic:** 0%

---

## Next Steps

### Priority 1: Add Test Dependencies

```yaml
# pubspec.yaml dev_dependencies
dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.4
  fake_async: ^1.3.1
  build_runner: ^2.4.9  # required by mockito code gen
```

### Priority 2: Write Unit Tests

1. `test/models/timer_model_test.dart` — **Highest priority**
2. Cover all state transitions
3. Use `fake_async` for tick timing
4. Use `mockito` for AudioService and NotificationService

### Priority 3: Write Widget Tests

1. `test/widgets/progress_ring_test.dart`
2. `test/widgets/settings_panel_test.dart`
3. `test/widgets/alarm_banner_test.dart`

### Priority 4: CI/CD Integration

1. Set up GitHub Actions
2. Run `flutter test --coverage` on every push
3. Add coverage gates

---

## Summary

**TDD Status:** Not implemented (0% coverage)

**Protocol:** Red → Green → Refactor cycle for all new code

**Goals:**
- 80% overall coverage
- 100% `TimerModel` business logic coverage
- All critical state transitions tested

**Next Steps:**
1. Add `mockito` + `fake_async` to dev_dependencies
2. Write unit tests for `TimerModel`
3. Write widget tests for key widgets
4. Configure GitHub Actions CI

**TDD Philosophy:** No production code without a failing test. Tests are first-class citizens.
