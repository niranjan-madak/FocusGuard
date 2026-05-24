# BUSINESS_LOGIC — FocusGuard

Document the core business logic and important invariants.

## Purpose
FocusGuard is a single-user, offline productivity timer. Its behaviour is deterministic and concerned with elapsed time, session boundaries and notifying the user.

## Core concepts
- Focus session: configurable minutes (default 75)
- Break session: configurable minutes (default 20)
- Sessions alternate focus <-> break
- Auto-start: when enabled, the next session begins automatically after a small delay
- Alarms: generated using Web Audio API; repeated configurable times
- Session history: an in-memory array of 'focus'|'break' entries

## Important invariants
- secsLeft must always be an integer >= 0 and <= configured session length in seconds
- When a focus session is running, totalFocusSecs increments each second
- sessionsCompleted increments only when a focus session finishes
- cycles is computed as the number of completed breaks in history
- When `update-config` is invoked, main process accepts focus/break mins and updates the shared state

## Edge cases handled
- Rate-limiting for rapid clicks prevents duplicate operations
- AudioContext failure gracefully degrades (no crash)
- If `autoStart` is false, the session ends in a paused `running=false` state and waits for user
- App prevents navigation, new windows and network access via CSP

## Suggested tests (high level)
- Starting and pausing a timer advances/halts secondsLeft
- Completing a focus session increments sessionsCompleted and toggles isFocus
- Applying settings updates CONFIG and resets correctly
- Skip session forces a session end and toggles isFocus
- Audio alarms are scheduled according to `alarmReps` (mock AudioContext)
- IPC `timer-state-update` carries required fields and main updates tray accordingly

## Persistence
Currently there is no disk persistence. If session persistence is added, ensure migrations and backward compatibility.

