# STATE_AND_FLOW — FocusGuard

This document describes runtime state, flows and IPC interactions.

## Runtime state (summary)
- running: boolean — timer is active
- paused: boolean — timer paused
- isFocus: boolean — true when in focus session
- secsLeft: integer — seconds remaining in current session
- sessionsCompleted: integer — number of completed focus sessions
- totalFocusSecs: integer — accumulated focus seconds
- cycles: integer — number of completed break sessions
- history: array('focus'|'break') — sequence of finished sessions
- alarmActive: boolean — whether alarm banner is visible
- volume: float 0..1
- soundEnabled: boolean
- autoStart: boolean

## Primary flows

1) App start
- main.js creates BrowserWindow with preload.js
- renderer.js init -> updateDisplay() -> sends `timer-state-update` to main

2) Start timer
- User triggers `startTimer()` -> state.running = true, tickInterval set to 1s
- Every tick: secsLeft--, totalFocusSecs++ (if focus), playTick() maybe
- Renderer sends periodic `timer-state-update` to main for tray updates

3) Session end
- When secsLeft hits 0 -> onSessionEnd()
  - stop tick interval, push to history, toggle isFocus, set secsLeft to new session length
  - playAlarm(), showAlarmBanner(), send `session-alarm` and `window-flash` IPC
  - updateDisplay(); if autoStart -> schedule startTimer after a short delay

4) Skip session
- User confirms -> skipSession() replicates session completion logic synchronously and resets running state

5) Reset
- User confirms -> resetTimer() clears intervals, clears history, resets counters and display

6) Settings change
- applySettings() updates CONFIG (renderer) and sends `update-config` to main
- main updates its local timerState.focusMins / breakMins for tray rendering

## IPC contract summary
- `timer-state-update` (renderer→main): { running, paused, isFocus, secsLeft, sessionsCompleted, focusMins, breakMins }
- `session-alarm` (renderer→main): { newMode: 'focus'|'break', sessions: number }
- `window-flash` (renderer→main): no payload
- `update-config` (renderer→main): { focusMins, breakMins }
- `get-platform` (main handler) → string
- `show-confirm-dialog` (main handler) → boolean
- `shortcut` (main→renderer): action string

## Concurrency & safety
- Renderer uses rateLimit() to prevent rapid operations
- Preload sanitizes data — main should still defensively validate before using external data

## Observability hooks to add
- Emit an event when powerSaveBlocker start/stop for telemetry
- Add optional debug logging behind `dev` script

