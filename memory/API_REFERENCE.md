# API_REFERENCE — FocusGuard

Framework: Flutter/Dart. Updated 2026-05-25.

There is no IPC, no HTTP API, and no external service. This document covers the **internal Dart API** — the public interface of `TimerModel` and the two services.

---

## TimerModel Public API

**Location:** `lib/models/timer_model.dart`
**Type:** `ChangeNotifier` (Provider)
**Access:** `context.watch<TimerModel>()` / `context.read<TimerModel>()`

### State Fields (Read-Only from Widgets)

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `focusMins` | `int` | `75` | Focus session duration (minutes) |
| `breakMins` | `int` | `20` | Break session duration (minutes) |
| `running` | `bool` | `false` | Timer is actively counting |
| `paused` | `bool` | `false` | Timer is paused (tick frozen) |
| `isFocus` | `bool` | `true` | Current session is focus (vs break) |
| `secsLeft` | `int` | `4500` | Seconds remaining in current session |
| `sessionsCompleted` | `int` | `0` | Completed focus sessions |
| `totalFocusSecs` | `int` | `0` | Total seconds spent in focus |
| `cycles` | `int` | `0` | Completed break sessions |
| `history` | `List<String>` | `[]` | Sequence of `'focus'` / `'break'` |
| `alarmActive` | `bool` | `false` | Alarm banner is showing |
| `soundEnabled` | `bool` | `true` | Sound effects on/off |
| `autoStart` | `bool` | `true` | Auto-start next session on alarm |
| `volume` | `double` | `0.7` | Audio volume 0.0–1.0 |

### Derived Getters

| Getter | Return type | Computation |
|--------|-------------|-------------|
| `totalSecs` | `int` | `(isFocus ? focusMins : breakMins) * 60` |
| `progress` | `double` | `secsLeft / totalSecs` (0.0–1.0) |
| `timeStr` | `String` | `MM:SS` formatted string |
| `focusTimeStr` | `String` | `Xh Ym` formatted string |
| `statusText` | `String` | `READY` / `FOCUSING` / `ON BREAK` / `PAUSED` |

### Control Methods

| Method | Signature | Description |
|--------|-----------|-------------|
| `toggleStartStop` | `void toggleStartStop()` | Start → Pause → Resume cycle |
| `skip` | `void skip()` | End current session (no alarm) |
| `reset` | `Future<void> reset()` | Full reset — all state to defaults |
| `dismissAlarm` | `void dismissAlarm()` | Hide alarm banner |
| `applySettings` | `void applySettings({required int focusM, required int breakM})` | Update durations + reset |
| `toggleSound` | `void toggleSound()` | Toggle `soundEnabled` |
| `setVolume` | `void setVolume(double v)` | Set `volume` (0.0–1.0) |
| `setAutoStart` | `void setAutoStart(bool v)` | Set `autoStart` |

---

## AudioService API

**Location:** `lib/services/audio_service.dart`
**Instantiation:** Created once in `main()`, injected into `TimerModel`

| Method | Signature | Sound file | Triggered when |
|--------|-----------|-----------|----------------|
| `init` | `Future<void> init()` | — | App start — sets audio context |
| `playAlarm` | `Future<void> playAlarm(bool isFocus, double volume)` | `focus_alarm.wav` or `break_alarm.wav` | Session ends naturally |
| `playClick` | `Future<void> playClick(double volume)` | `click.wav` | Any button/control interaction |
| `playTick` | `Future<void> playTick(double volume)` | `tick.wav` | Last 10 seconds of a session |
| `dispose` | `void dispose()` | — | App shutdown |

**Note on `playAlarm` parameter:** `isFocus` is the **new** mode (after toggling). The alarm played is the one appropriate for the **just-ended** session.

---

## NotificationService API

**Location:** `lib/services/notification_service.dart`
**Instantiation:** Created once in `main()`, injected into `TimerModel`

| Method | Signature | Description |
|--------|-----------|-------------|
| `init` | `Future<void> init()` | Initialize for all platforms (Android, iOS, Linux, Windows) |
| `show` | `Future<void> show(String title, String body)` | Show high-priority OS notification |

**Notification settings:**
- ID: `0` (single notification, replaces previous)
- Android: channel `focusguard_timer`, importance high, sound disabled
- iOS/macOS: `presentSound: false`
- Windows: `WindowsNotificationDetails()`

---

## Sound Assets

Located in `assets/sounds/` (declared in `pubspec.yaml`):

| File | Content |
|------|---------|
| `focus_alarm.wav` | Alarm sound played when break ends → focus starts |
| `break_alarm.wav` | Alarm sound played when focus ends → break starts |
| `click.wav` | Short UI click feedback |
| `tick.wav` | Countdown tick (last 10 seconds) |

---

## No External API

FocusGuard makes zero external network requests. There is no:
- REST API
- GraphQL API
- WebSocket
- Push notification server
- Analytics endpoint
- Update server

All functionality is local. The only "external" surfaces are:
- OS notification system (via `flutter_local_notifications`)
- Screen wakelock (via `wakelock_plus`)
- Audio hardware (via `audioplayers`)
