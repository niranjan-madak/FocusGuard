# TESTING_MEMORY — FocusGuard

Guidance for adding tests (TDD-first approach) and a test plan for existing code.

## Testing goals
- Increase overall confidence and prevent regressions
- Achieve at least 80% coverage for business logic; 100% for timer core
- Run fast unit tests locally and in CI

## Recommended frameworks
- Unit + integration: Vitest or Jest (Vitest is fast and integrates well with ESM; either is fine)
- DOM / component testing: JSDOM (built into Jest/Vitest) for renderer logic
- E2E: Playwright for full-app workflows (optional — can automate packaged app)

## Test boundaries
- Unit tests: pure functions, timer tick, session transitions, settings apply
- Integration tests: IPC flows between renderer and mocked main (via mocking contextBridge or via a small test harness), Audio scheduling (mock AudioContext), powerSaveBlocker integration (mock electron powerSaveBlocker)
- E2E: Launch the app in CI or locally and test critical flows: start->complete session, skip, reset, settings apply (use Playwright or Spectron-like tool)

## Suggested test files (examples)
- tests/renderer/timer.test.js — start/pause/tick behavior
- tests/renderer/settings.test.js — applySettings and update-config IPC
- tests/preload/ipc.test.js — ensure only allowed channels work and sanitize is used
- tests/main/tray.test.js — validate `timer-state-update` handling updates tray menu titles (mock Tray)

## Mocking suggestions
- Mock `window.AudioContext` to assert playTone scheduling without playing audio
- Mock `window.focusAPI` object to intercept sends/invokes during renderer tests
- Mock electron APIs in main tests (Tray, Notification, powerSaveBlocker) with simple stubs

## CI integration
- Run unit tests on push and PRs
- Block merges if coverage falls below thresholds
- Add `test` and `test:watch` scripts to package.json

## Starter test example (pseudocode)
// renderer/timer.test.js
// Arrange: load renderer.js in JSDOM, stub timers
// Act: call startTimer(), advance timers, assert secsLeft decreased and totalFocusSecs incremented
// Assert: after secsLeft reaches 0, sessionsCompleted increments and isFocus toggles


