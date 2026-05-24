# PERFORMANCE_MEMORY — FocusGuard

Performance notes, baseline measurements and optimization ideas.

## Baseline
- Typical memory footprint: ~80-150 MB (Electron runtime included)
- CPU: minimal (1s tick) — near-zero when idle
- Disk: installed size ~80-120 MB

## Hot paths
- setInterval tick every 1s — cheap but should not run heavy computations
- DOM updates on every tick — keep them minimal (update only changed elements)
- Alarm audio generation uses Web Audio API — occurs rarely (session end) and is lightweight

## Optimization suggestions
- Throttle display updates: if rendering expensive DOM operations, update UI every N seconds where possible
- Use requestAnimationFrame for animations (if any heavy animations are added)
- Keep audio generation lazy (create AudioContext only on first use) — already implemented
- For very long session histories, cap in-memory history or virtualize rendering of timeline dots

## Power considerations
- Power save blocker is enabled only during focus sessions; ensure it is stopped whenever not needed to conserve battery

## Monitoring
- Add lightweight telemetry (opt-in) to track app memory/CPU in the wild (respect privacy)
- Run automated performance smoke tests in CI for new releases (memory + CPU during a 2-minute simulated run)

## Performance tests to add
- Unit test: verify tick cost is O(1) and no memory leaks after thousands of ticks (simulate with mocked timers)
- Integration test: start app headless and confirm memory stabilizes after 2 minutes


