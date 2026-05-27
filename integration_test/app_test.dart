// Integration tests — require a connected device or emulator.
// Run with: flutter test integration_test/app_test.dart
// These tests are NOT included in the standard flutter test --coverage run.
//
// TC-I-001 through TC-I-004

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';
import 'package:focusguard/models/timer_model.dart';
import 'package:focusguard/screens/home_screen.dart';
import 'package:focusguard/services/audio_service.dart';
import 'package:focusguard/services/notification_service.dart';
import 'package:focusguard/theme.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late AudioService audio;
  late NotificationService notif;
  late TimerModel model;

  setUp(() async {
    audio = AudioService();
    notif = NotificationService();
    await audio.init();
    await notif.init();
    model = TimerModel(audio: audio, notif: notif);
  });

  tearDown(() {
    model.dispose();
    audio.dispose();
  });

  Widget buildApp() => ChangeNotifierProvider<TimerModel>.value(
        value: model,
        child: MaterialApp(theme: buildTheme(), home: const HomeScreen()),
      );

  // TC-I-001 — Full focus-to-break cycle
  testWidgets('TC-I-001: focus session end triggers break + alarm', (tester) async {
    model.applySettings(focusM: 1, breakM: 1); // 1 min for speed
    model.autoStart = false;
    await tester.pumpWidget(buildApp());

    // Start timer
    await tester.tap(find.byKey(const ValueKey('start_stop_button')));
    await tester.pump();

    // Wait for 1-minute session to complete (with generous timeout)
    await tester.pumpAndSettle(const Duration(minutes: 2));

    expect(model.isFocus, false);
    expect(model.alarmActive, true);
    expect(model.sessionsCompleted, 1);
  });

  // TC-I-002 — Pause / resume preserves remaining time
  testWidgets('TC-I-002: pause then resume does not corrupt remaining time', (tester) async {
    model.applySettings(focusM: 5, breakM: 1);
    model.autoStart = false;
    await tester.pumpWidget(buildApp());

    await tester.tap(find.byKey(const ValueKey('start_stop_button')));
    await tester.pump(const Duration(seconds: 5));

    final secsAtPause = model.secsLeft;
    await tester.tap(find.byKey(const ValueKey('start_stop_button'))); // pause
    await tester.pump(const Duration(seconds: 3));
    expect(model.secsLeft, secsAtPause); // time frozen

    await tester.tap(find.byKey(const ValueKey('start_stop_button'))); // resume
    await tester.pump(const Duration(seconds: 2));
    expect(model.secsLeft, lessThan(secsAtPause)); // countdown resumed
  });

  // TC-I-003 — Auto-start next session
  testWidgets('TC-I-003: auto-start begins next session automatically', (tester) async {
    model.applySettings(focusM: 1, breakM: 1);
    model.autoStart = true;
    await tester.pumpWidget(buildApp());

    await tester.tap(find.byKey(const ValueKey('start_stop_button')));
    await tester.pump();

    // Wait for focus to complete and auto-start delay
    await tester.pumpAndSettle(const Duration(minutes: 2));

    // Break session should have started automatically
    expect(model.isFocus, false);
    expect(model.running, true);
  });

  // TC-I-004 — Settings persist within session
  testWidgets('TC-I-004: custom duration set in settings applies to next session', (tester) async {
    await tester.pumpWidget(buildApp());

    // Set focus to 2 minutes via settings
    model.applySettings(focusM: 2, breakM: 1);
    await tester.pump();

    // Start timer
    await tester.tap(find.byKey(const ValueKey('start_stop_button')));
    await tester.pump();

    expect(model.secsLeft, 2 * 60);
    expect(model.focusMins, 2);
  });
}
