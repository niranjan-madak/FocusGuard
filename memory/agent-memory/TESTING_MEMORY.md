# TESTING_MEMORY — FocusGuard

Updated: 2026-05-25. Framework: Flutter/Dart.

## Testing Goals

- At least 80% coverage for business logic; 100% for `TimerModel` core paths
- Fast unit tests runnable locally and in CI
- Widget tests for key UI components

## Recommended Frameworks

- **Unit tests:** `flutter_test` (already a dev dependency via Flutter SDK)
- **Widget tests:** `flutter_test` with `WidgetTester`
- **E2E / integration:** `integration_test` package (optional — Flutter's official integration test framework)
- **Mocking:** `mockito` package (add to dev_dependencies when tests are written)

## Test Boundaries

### Unit Tests (test/models/)

Test `TimerModel` in isolation, using fake/mock `AudioService` and `NotificationService`:

| Test | What to verify |
|------|----------------|
| `_tick() when running and not paused` | `secsLeft` decrements by 1 |
| `_tick() when paused` | `secsLeft` unchanged |
| `_tick() at secsLeft == 0` | `_onSessionEnd()` fires |
| `_onSessionEnd() after focus` | `isFocus` toggles to false, `sessionsCompleted` += 1 |
| `_onSessionEnd() after break` | `isFocus` toggles to true, `sessionsCompleted` unchanged |
| `_recordSession()` | Appends correct type to `history`; cycles = break count |
| `skip()` | Records session, toggles isFocus, no alarm played |
| `reset()` | All counters and history cleared, `isFocus = true` |
| `applySettings(focusM, breakM)` | Updates durations, calls reset |
| `progress getter` | Returns 0.0 at full countdown, 1.0 at start |
| `statusText getter` | Returns correct label per state |

### Widget Tests (test/widgets/)

| Widget | Key scenarios |
|--------|--------------|
| `ProgressRing` | Renders correct arc at progress=1.0 and 0.0 |
| `StatsBar` | Displays sessions/focusTime/cycles correctly |
| `TimelineDots` | Renders amber and cyan dots for history entries |
| `SettingsPanel` | Calls `onApply` with validated values |
| `AlarmBanner` | Renders and calls `onDismiss` on tap |

### Integration Tests (test/integration/)

- Start timer → wait for tick → verify secsLeft decremented
- Complete session flow (mock fast timer) → verify history updated and notification shown

## Mocking Strategy

```dart
// Mock AudioService (returns immediately, no sound)
class MockAudioService extends Mock implements AudioService {}

// Mock NotificationService
class MockNotificationService extends Mock implements NotificationService {}

// Create TimerModel with mocks
final model = TimerModel(audio: MockAudioService(), notif: MockNotificationService());
```

Use `fake_async` package to control `Timer.periodic` in unit tests without real time delays.

## CI Integration

When CI is configured:
- Run `flutter test` on every push and PR
- Block merge if any test fails
- Add coverage check: `flutter test --coverage`

## Test File Structure (when written)

```
test/
├── models/
│   └── timer_model_test.dart
├── widgets/
│   ├── progress_ring_test.dart
│   ├── stats_bar_test.dart
│   ├── timeline_dots_test.dart
│   ├── settings_panel_test.dart
│   └── alarm_banner_test.dart
└── integration/
    └── timer_flow_test.dart
```

## Starter Test Example

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
  group('TimerModel', () {
    late TimerModel model;

    setUp(() {
      model = TimerModel(audio: MockAudio(), notif: MockNotif());
    });

    test('should start with secsLeft equal to focusMins * 60', () {
      expect(model.secsLeft, equals(model.focusMins * 60));
    });

    test('should toggle isFocus when session ends', () {
      expect(model.isFocus, isTrue);
      // trigger session end...
      // expect(model.isFocus, isFalse);
    });
  });
}
```
