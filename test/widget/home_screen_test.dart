import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:focusguard/models/timer_model.dart';
import 'package:focusguard/screens/home_screen.dart';
import 'package:focusguard/theme.dart';
import '../helpers/fakes.dart';

TimerModel _model() => TimerModel(
      audio: FakeAudioService(),
      notif: FakeNotificationService(),
    );

// Suppress unhandled platform channel calls (WakelockPlus).
// Pigeon-generated toggle() returns void → encode a [null] list with StandardMessageCodec.
void _stubPlatformChannels() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  const codec = StandardMessageCodec();
  for (final name in [
    'wakelock_plus',
    'dev.flutter.pigeon.wakelock_plus_platform_interface.WakelockPlusApi.toggle',
    'dev.flutter.pigeon.WakelockPlusPlatformInterface.WakelockPlusApi.toggle',
    'plugins.flutter.io/wakelock_plus',
  ]) {
    messenger.setMockMessageHandler(
      name,
      (_) async => codec.encodeMessage(<Object?>[null]),
    );
  }
}

Future<void> _pump(WidgetTester tester, TimerModel model) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<TimerModel>.value(
      value: model,
      child: MaterialApp(
        theme: buildTheme(),
        home: const HomeScreen(),
      ),
    ),
  );
  await tester.pump();
}

// Keyboard tests run in desktop layout; use a wide viewport to avoid overflow
// in the controls row that occurs at the 800px default test size.
Future<void> _pumpWide(WidgetTester tester, TimerModel model) async {
  tester.view.physicalSize = const Size(1200, 900);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await _pump(tester, model);
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(_stubPlatformChannels);

  group('HomeScreen — keyboard shortcuts', () {
    // TC-W-012 — Space starts timer
    testWidgets('TC-W-012: Space key starts the timer', (tester) async {
      final m = _model();
      await _pumpWide(tester, m);
      expect(m.running, false);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(m.running, true);
      m.dispose(); // cancel Timer.periodic before framework invariant check
    });

    // TC-W-013 — Space pauses running timer
    testWidgets('TC-W-013: Space key pauses a running timer', (tester) async {
      final m = _model();
      await _pumpWide(tester, m);
      m.toggleStartStop(); // start via model
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.space);
      await tester.pump();
      expect(m.paused, true);
      m.dispose();
    });

    // TC-W-014 — Ctrl+K skips session
    testWidgets('TC-W-014: Ctrl+K skips the current session', (tester) async {
      final m = _model();
      m.autoStart = false;
      await _pumpWide(tester, m);
      m.toggleStartStop();
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyK);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyK);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      expect(m.isFocus, false); // transitioned to break
      m.dispose();
    });

    // TC-W-015 — Ctrl+R resets timer
    testWidgets('TC-W-015: Ctrl+R resets the timer', (tester) async {
      final m = _model();
      await _pumpWide(tester, m);
      m.toggleStartStop();
      await tester.pump();
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyR);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyR);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      expect(m.running, false);
      expect(m.secsLeft, 75 * 60);
      m.dispose();
    });

    // TC-W-016 — Ctrl+M toggles sound state
    testWidgets('TC-W-016: Ctrl+M toggles sound state', (tester) async {
      final m = _model();
      await _pumpWide(tester, m);
      expect(m.soundEnabled, true);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
      await tester.sendKeyDownEvent(LogicalKeyboardKey.keyM);
      await tester.pump();
      await tester.sendKeyUpEvent(LogicalKeyboardKey.keyM);
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
      await tester.pump();
      expect(m.soundEnabled, false);
      m.dispose();
    });
  });

  group('HomeScreen — responsive layout', () {
    // TC-W-017 — Single-column layout below 800px
    testWidgets('TC-W-017: width < 800 uses single-column (mobile) layout',
        (tester) async {
      tester.view.physicalSize = const Size(799, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final m = _model();
      await _pump(tester, m);

      // Mobile layout wraps content in a ConstrainedBox(maxWidth: 440)
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is ConstrainedBox &&
              w.constraints.maxWidth == 440,
        ),
        findsOneWidget,
      );
    });

    // TC-W-018 — Two-column layout at 800px+
    testWidgets('TC-W-018: width >= 800 uses two-column (desktop) layout',
        (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final m = _model();
      await _pump(tester, m);

      // Desktop layout does NOT use the mobile ConstrainedBox(maxWidth: 440)
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is ConstrainedBox &&
              w.constraints.maxWidth == 440,
        ),
        findsNothing,
      );
    });
  });
}
