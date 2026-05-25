# DATA_MODELS — FocusGuard

Framework: Flutter/Dart. Updated 2026-05-25.

FocusGuard has **no database** and **no persistent storage currently**. All state is in-memory in `TimerModel` and resets on app restart.

---

## TimerModel State

**Location:** `lib/models/timer_model.dart`

```dart
class TimerModel extends ChangeNotifier {
  int focusMins = 75;
  int breakMins = 20;

  bool running = false;
  bool paused  = false;
  bool isFocus = true;
  late int secsLeft;           // = focusMins * 60 on init

  int sessionsCompleted = 0;
  int totalFocusSecs    = 0;
  int cycles            = 0;
  List<String> history  = [];  // 'focus' | 'break'

  bool alarmActive  = false;
  bool soundEnabled = true;
  bool autoStart    = true;
  double volume     = 0.7;
}
```

### Field Constraints

| Field | Min | Max | Default |
|-------|-----|-----|---------|
| `focusMins` | 1 | 240 | 75 |
| `breakMins` | 1 | 120 | 20 |
| `volume` | 0.0 | 1.0 | 0.7 |
| `secsLeft` | 0 | `totalSecs` | `focusMins * 60` |

### Invariants

1. `secsLeft >= 0` always
2. `secsLeft` only decrements when `running && !paused`
3. `totalFocusSecs` increments only during `isFocus && running && !paused`
4. `sessionsCompleted` increments only on focus session end (natural or skip)
5. `cycles` = count of `'break'` entries in `history`
6. `alarmActive` only set to `true` in `_onSessionEnd()`, reset only by `dismissAlarm()` or `reset()`

---

## Session History

`history` is a `List<String>` of session types in completion order:

```dart
// Example after 2 focus + 1 break:
['focus', 'focus', 'break']
```

**Elements:** `'focus'` or `'break'`

**Visual mapping (TimelineDots widget):**
- `'focus'` → amber dot
- `'break'` → cyan dot
- Current active session → pulsing dot (not in history yet)

**Limitations:**
- Not persisted across restarts
- No timestamps
- No duration per session
- Can grow unboundedly during very long usage (consider capping at ~200 if needed)

---

## State Transitions

### Start Timer

```
running = true
paused  = false
Timer.periodic(1s, _tick) started
```

### Pause

```
paused = true
(Timer still active; _tick() returns early)
```

### Resume

```
paused = false
```

### Tick → Session End (secsLeft reaches 0)

```
_ticker cancelled
running = false
history.add(isFocus ? 'focus' : 'break')
if (isFocus): sessionsCompleted++
cycles = history.where('break').length
isFocus = !isFocus
secsLeft = new session length
alarmActive = true
```

### Skip

```
Same as session end but:
- No alarmActive = true
- No alarm sound
- No notification
```

### Reset

```
running = false
paused  = false
isFocus = true
secsLeft = focusMins * 60
sessionsCompleted = 0
totalFocusSecs = 0
cycles = 0
history = []
alarmActive = false
```

### Apply Settings

```
focusMins = focusM
breakMins = breakM
→ reset()
```

---

## Future Persistence Schema (shared_preferences)

When wired, these keys should be persisted:

| Key | Type | When to save |
|-----|------|-------------|
| `focusMins` | `int` | On `applySettings()` |
| `breakMins` | `int` | On `applySettings()` |
| `soundEnabled` | `bool` | On `toggleSound()` |
| `autoStart` | `bool` | On `setAutoStart()` |
| `volume` | `double` | On `setVolume()` |

Session history and timer state (`running`, `paused`, `secsLeft`) should **not** be persisted — timer always starts fresh.

---

## Audio Assets

Not model data, but referenced by `AudioService`:

| Asset | Type | Purpose |
|-------|------|---------|
| `assets/sounds/focus_alarm.wav` | WAV | Break ending → focus |
| `assets/sounds/break_alarm.wav` | WAV | Focus ending → break |
| `assets/sounds/click.wav` | WAV | UI interaction |
| `assets/sounds/tick.wav` | WAV | Countdown tick |

---

## No Database, No External State

There is no:
- SQLite / Hive / Isar database
- Cloud state or sync
- File-based persistence (yet)
- Server-side data

The only planned persistence is `shared_preferences` for user settings (5 keys, all primitives).
