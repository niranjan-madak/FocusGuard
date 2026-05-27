import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:focusguard/widgets/timeline_dots.dart';
import 'package:focusguard/theme.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('TimelineDots', () {
    // TC-W-008 — Dot count matches session history length
    testWidgets('TC-W-008: renders one dot per history entry', (tester) async {
      const history = ['focus', 'break', 'focus', 'break'];
      await tester.pumpWidget(MaterialApp(
        theme: buildTheme(),
        home: const Scaffold(
          body: TimelineDots(history: history, running: false, isFocus: true),
        ),
      ));
      await tester.pump();
      // Wrap widget holds exactly history.length children (no pulsing dot when running=false)
      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.children.length, history.length);
    });

    testWidgets('TC-W-008b: adds pulsing dot when running=true', (tester) async {
      const history = ['focus', 'break'];
      await tester.pumpWidget(MaterialApp(
        theme: buildTheme(),
        home: const Scaffold(
          body: TimelineDots(history: history, running: true, isFocus: true),
        ),
      ));
      await tester.pump();
      final wrap = tester.widget<Wrap>(find.byType(Wrap));
      expect(wrap.children.length, history.length + 1); // +1 pulsing dot
    });
  });
}
