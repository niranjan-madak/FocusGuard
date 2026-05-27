import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:focusguard/widgets/progress_ring.dart';
import 'package:focusguard/theme.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ProgressRing', () {
    // TC-W-001 — Renders without errors
    testWidgets('TC-W-001: renders arc without throwing', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: buildTheme(),
        home: const Scaffold(
          body: Center(
            child: ProgressRing(progress: 0.5, isFocus: true, timeStr: '37:30'),
          ),
        ),
      ));
      expect(find.byType(ProgressRing), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    // TC-W-002 — Focus mode label
    testWidgets('TC-W-002: focus mode shows FOCUS SESSION label', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: buildTheme(),
        home: const Scaffold(
          body: Center(
            child: ProgressRing(progress: 0.5, isFocus: true, timeStr: '37:30'),
          ),
        ),
      ));
      expect(find.text('FOCUS SESSION'), findsOneWidget);
    });

    // TC-W-003 — Break mode label
    testWidgets('TC-W-003: break mode shows BREAK TIME label', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: buildTheme(),
        home: const Scaffold(
          body: Center(
            child: ProgressRing(progress: 0.3, isFocus: false, timeStr: '10:00'),
          ),
        ),
      ));
      expect(find.text('BREAK TIME'), findsOneWidget);
    });
  });
}
