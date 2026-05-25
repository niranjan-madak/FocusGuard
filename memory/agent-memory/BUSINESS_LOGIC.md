# BUSINESS_LOGIC — FocusGuard

Updated: 2026-05-25. Framework: Flutter/Dart.

## Purpose

FocusGuard is a single-user, offline productivity timer. Its behaviour is deterministic — concerned with elapsed time, session boundaries, and notifying the user. All business logic lives in `lib/models/timer_model.dart` (`TimerModel`).

## Core Concepts

- **Focus session:** configurable minutes (default 75); user actively working
- **Break session:** configurable minutes (default 20); user resting
- **Sessions alternate** focus ↔ break automatically or on user demand
- **Auto-start:** when enabled, next session begins after a short delay (3.2s for focus, 4.0s for break)
- **Alarms:** WAV files via `AudioService`; last 10 seconds play a tick sound
- **Session history:** in-memory `List<String>` of `'focus'` | `'break'` entries

## Important Invariants

1. `secsLeft` is always `>= 0` and `<= (isFocus ? focusMins : breakMins) * 60`
2. `secsLeft` only decrements when `running == true && paused == false`
3. `totalFocusSecs` increments each second only during active focus (`isFocus && running && !paused`)
4. `sessionsCompleted` increments only when a **focus** session ends naturally or is skipped
5. `cycles` = count of `'break'` entries in `history` (completed break count)
6. `alarmActive` is set to `true` only in `_onSessionEnd()`, cleared only by `dismissAlarm()` or `reset()`
7. `_ticker` is always cancelled before `reset()` or `skip()` to prevent stale ticks
8. `autoStart` Future.delayed checks `!running && autoStart` before calling `_start()` — safe if user manually starts first

## Key Business Rules

- Skip does **not** trigger alarm or notification — it's a user-initiated silent transition
- Skip **does** call `_recordSession()` — the skipped session is counted in history
- `applySettings()` always triggers `reset()` — changing durations starts fresh
- Volume and soundEnabled are independent — muting (`toggleSound`) does not reset volume
- `_tick()` returns early if `!running || paused` — the periodic `Timer` is not cancelled on pause (efficiency: only one timer ever)

## Edge Cases

- If `autoStart` is false, session ends with `running=false`, `paused=false`, `alarmActive=true` — waits for user
- If user manually starts during the `autoStart` delay, the `Future.delayed` callback skips `_start()` (guard: `!running`)
- `playTick()` is called at `secsLeft <= 10 && secsLeft > 0` — not at exactly 0 (that triggers alarm instead)
- `playAlarm(isFocus, volume)` is called with the **new** `isFocus` value (after toggling) — alarm type corresponds to the session that just ended

## No IPC / No Multi-process

All business logic is in a single `TimerModel` instance in the Flutter single-process. There is no equivalent of Electron IPC, no `timer-state-update` messages, no tray state sync.

## Persistence

Currently no disk persistence — state resets on restart. `shared_preferences` dependency is declared and ready to wire for:
- `focusMins`, `breakMins` (settings persistence)
- `soundEnabled`, `autoStart`, `volume` (option persistence)

When adding: save on every `applySettings()` / `toggleSound()` / `setVolume()` / `setAutoStart()` call.

## Suggested Tests (Priority Order)

1. `TimerModel._tick()` decrements `secsLeft` correctly when running and not paused
2. `TimerModel._tick()` does nothing when paused
3. `TimerModel._onSessionEnd()` toggles `isFocus`, increments `sessionsCompleted` on focus end
4. `TimerModel._onSessionEnd()` does NOT increment `sessionsCompleted` on break end
5. `TimerModel.skip()` records session in history without alarm
6. `TimerModel.reset()` clears all counters and history
7. `TimerModel.applySettings()` updates durations and triggers reset
8. `TimerModel.progress` returns 0.0 when `secsLeft == 0`
