# TESTING — FocusGuard

Framework: Flutter/Dart. Updated 2026-05-25.

## Current Status

**Test Coverage:** 0%
**Test Framework:** `flutter_test` (SDK — available, not yet used)
**Status:** ❌ No tests written

---

## Testing Strategy

### Framework

- **Unit + widget tests:** `flutter_test` (already a dev dependency via Flutter SDK)
- **Mocking:** `mockito` package (add when tests are written)
- **Fake async:** `fake_async` package (control `Timer.periodic` without real time)
- **Integration tests:** `integration_test` package (Flutter's official E2E framework)

### Test Levels

| Level | Tool | Target |
|-------|------|--------|
| Unit | `flutter_test` | `TimerModel` state transitions |
| Widget | `flutter_test` + `WidgetTester` | Key widget rendering and interaction |
| Integration | `integration_test` | Full timer flow on device/emulator |

---

## Unit Test Plan (TimerModel)

Priority: **HIGH** — write these first.

**Test file:** `test/models/timer_model_test.dart`

| Test | Expected outcome |
|------|-----------------|
| Initial state | `secsLeft == focusMins * 60`, `isFocus == true`, `running == false` |
| `_tick()` when running | `secsLeft` decrements by 1 |
| `_tick()` when paused | `secsLeft` unchanged |
| `_tick()` at secsLeft == 1 → 0 | `_onSessionEnd()` fires |
| `_onSessionEnd()` after focus | `isFocus` false, `sessionsCompleted` += 1, `alarmActive` true |
| `_onSessionEnd()` after break | `isFocus` true, `sessionsCompleted` unchanged, `cycles` incremented |
| `skip()` | Records session in history, toggles `isFocus`, no `alarmActive` |
| `reset()` | All counters, history, `alarmActive` cleared; `isFocus = true` |
| `applySettings(focusM, breakM)` | Updates durations, triggers reset |
| `progress` getter | 1.0 at start, 0.0 at secsLeft == 0 |
| `statusText` getter | Correct label for each state |
| `toggleSound()` | Flips `soundEnabled` |
| `setVolume(0.5)` | `volume == 0.5` |
| `setAutoStart(false)` | `autoStart == false` |
| autoStart Future.delayed guard | Does not call `_start()` if already `running` |

### Starter Test

```dart
// test/models/timer_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:focusguard/models/timer_model.dart';
import 'package:focusguard/services/audio_service.dart';
import 'package:focusguard/services/notification_service.dart';

class MockAudio extends Mock implements AudioService {}
class MockNotif extends Mock implements NotificationService {}

void main() {
  late TimerModel model;
  late MockAudio audio;
  late MockNotif notif;

  setUp(() {
    audio = MockAudio();
    notif = MockNotif();
    model = TimerModel(audio: audio, notif: notif);
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

## Widget Test Plan

Priority: **MEDIUM** — write after unit tests pass.

**Test file:** `test/widgets/<widget>_test.dart`

| Widget | Key scenarios |
|--------|--------------|
| `ProgressRing` | Renders arc at `progress=1.0` and `progress=0.0`; shows correct `timeStr` |
| `StatsBar` | Displays passed `sessions`, `focusTime`, `cycles` values |
| `TimelineDots` | Renders amber dots for `'focus'`, cyan for `'break'` |
| `SettingsPanel` | Calls `onApply` with validated values; rejects out-of-range input |
| `AlarmBanner` | Visible content and calls `onDismiss` on tap |

---

## Integration Test Plan

Priority: **LOW** — write after widget tests.

**Test file:** `test/integration/timer_flow_test.dart`

- Start timer → wait for tick → verify `secsLeft` decremented
- Complete full session (use fake fast durations) → verify `history` updated, notification shown

---

## Coverage Goals

- **Overall:** ≥ 80%
- **`TimerModel` business logic:** 100%

---

## Running Tests

```bash
# All unit and widget tests
flutter test

# With coverage
flutter test --coverage
# View: genhtml coverage/lcov.info -o coverage/html && open coverage/html/index.html

# Single test file
flutter test test/models/timer_model_test.dart

# Integration tests (requires device/emulator)
flutter test integration_test/
```

---

## CI Integration (Future)

```yaml
# .github/workflows/test.yml
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

## Current Gaps — Priority Order

1. **HIGH:** Unit tests for `TimerModel` — write `test/models/timer_model_test.dart`
2. **HIGH:** Add `mockito` and `fake_async` to dev_dependencies in `pubspec.yaml`
3. **MEDIUM:** Widget tests for `ProgressRing`, `SettingsPanel`, `AlarmBanner`
4. **LOW:** Integration test for full timer flow
5. **LOW:** CI pipeline running `flutter test` on push

---

## Summary

FocusGuard has **zero test coverage**. First priority: write unit tests for `TimerModel` using `flutter_test` + `mockito` + `fake_async`. The model is the most critical component and has the highest regression risk.

**Testing philosophy:** Test behaviour, not implementation. Focus on `TimerModel` state transitions first — they are the core product logic.
