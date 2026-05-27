import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:focusguard/widgets/stats_bar.dart';
import 'package:focusguard/theme.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('StatsBar', () {
    // TC-W-006 — Displays session count
    testWidgets('TC-W-006: renders correct session count', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: buildTheme(),
        home: const Scaffold(
          body: StatsBar(sessions: 3, focusTime: '0h 0m', cycles: 0, isFocus: true),
        ),
      ));
      expect(find.text('3'), findsOneWidget);
    });

    // TC-W-007 — Displays cycle count
    testWidgets('TC-W-007: renders correct cycle count', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: buildTheme(),
        home: const Scaffold(
          body: StatsBar(sessions: 0, focusTime: '1h 5m', cycles: 2, isFocus: true),
        ),
      ));
      expect(find.text('2'), findsOneWidget);
    });
  });
}
