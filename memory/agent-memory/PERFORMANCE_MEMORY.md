# PERFORMANCE_MEMORY — FocusGuard

Updated: 2026-05-25. Framework: Flutter/Dart.

## Baseline

- **Memory footprint:** Typical Flutter app ~80–150 MB (Flutter runtime + Dart VM)
- **CPU:** Minimal — `Timer.periodic(1s)` with O(1) tick logic; near-zero when idle
- **Disk (installed):** ~50–80 MB depending on platform (Flutter runtime + assets)

## Hot Paths

- `Timer.periodic(1s, _tick)` — one integer decrement + optional audio trigger; trivially cheap
- `notifyListeners()` on every tick → widget rebuild — keep widget `build()` methods fast
- `WakelockPlus.toggle()` called on every `HomeScreen` rebuild — idempotent, no cost if state unchanged
- `ProgressRing` `CustomPaint` repaints on every tick — `_RingPainter.shouldRepaint()` correctly guards unnecessary repaints

## Optimization Notes

- `ProgressRing` uses `shouldRepaint()` — only repaints when `progress` or `isFocus` changes. Good.
- `_StatusBadge` uses `AnimationController` for pulse animation — runs at 60fps regardless of timer state. Acceptable for this UI.
- `AudioPlayer` instances are created once and reused — no repeated init cost per sound play.
- Four `AudioPlayer` instances in memory at all times — acceptable (~few MB total).

## Wakelock

`WakelockPlus.toggle(enable: running && !paused && isFocus)` is called on every rebuild. This is safe — `wakelock_plus` is idempotent for same state. No performance concern.

## Potential Issues at Scale

- **Session history list:** `history` grows unboundedly during a session. If a user runs thousands of sessions without reset, `TimelineDots` will render thousands of dots. Consider capping at ~100 visible dots with a summary count if this becomes an issue.
- **`Future.delayed` for auto-start:** One pending future per session end. Not an issue, but ensure `dispose()` cancels the ticker — the auto-start guard (`!running`) prevents stale futures from starting the timer after disposal.

## Performance Tests to Add

1. **Unit:** Verify tick logic is O(1) — no allocations inside `_tick()`
2. **Unit:** Simulate 10,000 ticks with fake timers — assert no memory growth in `history` beyond session count
3. **Widget:** `ProgressRing` repaints only when `progress` changes (check `shouldRepaint`)

## Power Considerations

- Wakelock is active only during `running && !paused && isFocus` — screen sleeps during breaks and when paused, conserving battery.
- `AudioPlayer` does not hold audio resources between plays — only active during playback.

## No Metrics / No Telemetry

The app has no performance monitoring at runtime. Add Sentry or similar (opt-in) if runtime crashes or ANRs become a support issue.
