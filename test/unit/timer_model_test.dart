import 'package:flutter_test/flutter_test.dart';
import 'package:focusguard/models/timer_model.dart';
import '../helpers/fakes.dart';

TimerModel _model() => TimerModel(
      audio: FakeAudioService(),
      notif: FakeNotificationService(),
    );

void main() {
  group('TimerModel', () {
    // TC-U-001 — Initial state (no timer needed)
    test('TC-U-001: initialises with correct defaults', () {
      final m = _model();
      expect(m.isFocus, true);
      expect(m.running, false);
      expect(m.paused, false);
      expect(m.alarmActive, false);
      expect(m.focusMins, 75);
      expect(m.breakMins, 20);
      expect(m.sessionsCompleted, 0);
      expect(m.cycles, 0);
      expect(m.history, isEmpty);
    });

    // TC-U-002 — Start timer (uses testWidgets for fake-async time control)
    testWidgets('TC-U-002: start sets running = true', (tester) async {
      final m = _model();
      m.toggleStartStop();
      await tester.pump();
      expect(m.running, true);
      expect(m.paused, false);
      m.dispose(); // cancel Timer.periodic before framework invariant check
    });

    // TC-U-003 — Pause running timer
    testWidgets('TC-U-003: pause freezes remaining time', (tester) async {
      final m = _model();
      m.toggleStartStop(); // start
      await tester.pump(const Duration(seconds: 3));
      final secsBeforePause = m.secsLeft;
      m.toggleStartStop(); // pause
      expect(m.paused, true);
      await tester.pump(const Duration(seconds: 3)); // ticks fire but are no-ops
      expect(m.secsLeft, secsBeforePause);
      m.dispose();
    });

    // TC-U-004 — Resume paused timer
    testWidgets('TC-U-004: resume continues countdown from pause point', (tester) async {
      final m = _model();
      m.toggleStartStop(); // start
      await tester.pump(const Duration(seconds: 3));
      final secsAtPause = m.secsLeft;
      m.toggleStartStop(); // pause
      await tester.pump(const Duration(seconds: 5)); // frozen
      expect(m.secsLeft, secsAtPause);
      m.toggleStartStop(); // resume
      await tester.pump(const Duration(seconds: 2));
      expect(m.running, true);
      expect(m.paused, false);
      expect(m.secsLeft, secsAtPause - 2);
      m.dispose();
    });

    // TC-U-005 — Reset timer
    testWidgets('TC-U-005: reset returns to full duration', (tester) async {
      final m = _model();
      m.toggleStartStop();
      await tester.pump(const Duration(seconds: 5));
      await m.reset();
      await tester.pump();
      expect(m.running, false);
      expect(m.paused, false);
      expect(m.secsLeft, 75 * 60);
      expect(m.isFocus, true);
      m.dispose();
    });

    // TC-U-006 — Tick decrements remaining time
    testWidgets('TC-U-006: each second decrements secsLeft by 1', (tester) async {
      final m = _model();
      m.toggleStartStop();
      await tester.pump(const Duration(seconds: 10));
      expect(m.secsLeft, 75 * 60 - 10);
      m.dispose();
    });

    // TC-U-007 — Focus session ends → break
    testWidgets('TC-U-007: focus session end transitions to break', (tester) async {
      final m = _model();
      m.autoStart = false;
      m.secsLeft = 1;
      m.toggleStartStop();
      await tester.pump(const Duration(seconds: 2)); // tick to 0 → _onSessionEnd
      expect(m.isFocus, false);
      expect(m.alarmActive, true);
      expect(m.sessionsCompleted, 1);
      expect(m.secsLeft, 20 * 60);
      m.dispose();
    });

    // TC-U-008 — Break session ends → focus
    testWidgets('TC-U-008: break session end transitions to focus', (tester) async {
      final m = _model();
      m.autoStart = false;
      m.isFocus = false;
      m.secsLeft = 1;
      m.toggleStartStop();
      await tester.pump(const Duration(seconds: 2));
      expect(m.isFocus, true);
      expect(m.alarmActive, true);
      expect(m.cycles, 1);
      expect(m.secsLeft, 75 * 60);
      m.dispose();
    });

    // TC-U-009 — Alarm dismissal (no timer)
    test('TC-U-009: dismissAlarm clears alarmActive', () {
      final m = _model();
      m.alarmActive = true;
      m.dismissAlarm();
      expect(m.alarmActive, false);
    });

    // TC-U-010 — Mute toggle (no timer)
    test('TC-U-010: toggleSound flips soundEnabled without affecting timer state', () {
      final m = _model();
      expect(m.soundEnabled, true);
      m.toggleSound();
      expect(m.soundEnabled, false);
      m.toggleSound();
      expect(m.soundEnabled, true);
      expect(m.running, false);
      expect(m.isFocus, true);
    });

    // TC-U-011 — Auto-start enabled
    testWidgets('TC-U-011: auto-start triggers next session after delay', (tester) async {
      final m = _model();
      m.autoStart = true;
      m.secsLeft = 1;
      m.toggleStartStop();
      await tester.pump(const Duration(seconds: 2)); // session ends, delay starts
      expect(m.running, false); // not yet auto-started
      await tester.pump(const Duration(seconds: 5)); // past 4000ms delay
      expect(m.running, true);
      m.dispose();
    });

    // TC-U-012 — Auto-start disabled
    testWidgets('TC-U-012: auto-start disabled → timer stops at session end', (tester) async {
      final m = _model();
      m.autoStart = false;
      m.secsLeft = 1;
      m.toggleStartStop();
      await tester.pump(const Duration(seconds: 10));
      expect(m.running, false);
      expect(m.alarmActive, true);
      m.dispose();
    });

    // TC-U-013 — Apply custom focus duration (no timer)
    test('TC-U-013: applySettings updates focus duration and resets', () {
      final m = _model();
      m.applySettings(focusM: 45, breakM: 20);
      expect(m.focusMins, 45);
      expect(m.secsLeft, 45 * 60);
      expect(m.running, false);
    });

    // TC-U-014 — Apply custom break duration (no timer)
    test('TC-U-014: applySettings stores custom break duration', () {
      final m = _model();
      m.applySettings(focusM: 75, breakM: 10);
      expect(m.breakMins, 10);
    });

    // TC-U-015 — Session history records completed sessions (no timer)
    test('TC-U-015: completed sessions append to history in order', () {
      final m = _model();
      m.skip(); // records focus, flips to break
      m.skip(); // records break, flips to focus
      m.skip(); // records focus again
      expect(m.history.length, 3);
      expect(m.history[0], 'focus');
      expect(m.history[1], 'break');
      expect(m.history[2], 'focus');
    });

    // TC-U-016 — Skip session
    testWidgets('TC-U-016: skip ends current session and transitions mode', (tester) async {
      final m = _model();
      m.autoStart = false;
      m.toggleStartStop();
      await tester.pump(const Duration(seconds: 10));
      m.skip();
      expect(m.isFocus, false);
      expect(m.secsLeft, 20 * 60);
      expect(m.running, false);
      m.dispose();
    });

    // TC-U-017 — Cycle count (no timer)
    test('TC-U-017: cycleCount increments after one full focus+break cycle', () {
      final m = _model();
      m.skip(); // focus → break
      m.skip(); // break → focus, cycles++
      expect(m.cycles, 1);
    });
  });
}
