import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:focusguard/widgets/settings_panel.dart';
import 'package:focusguard/theme.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget _buildPanel({
    int focusMins = 75,
    int breakMins = 20,
    void Function({required int focusM, required int breakM})? onApply,
  }) {
    return MaterialApp(
      theme: buildTheme(),
      home: Scaffold(
        body: SettingsPanel(
          focusMins: focusMins,
          breakMins: breakMins,
          onApply: onApply ?? ({required focusM, required breakM}) {},
        ),
      ),
    );
  }

  group('SettingsPanel', () {
    // TC-W-009 — Panel shows input fields
    testWidgets('TC-W-009: settings panel shows duration input fields', (tester) async {
      await tester.pumpWidget(_buildPanel());
      await tester.pump();
      expect(find.text('Focus Duration'), findsOneWidget);
      expect(find.text('Break Duration'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    // TC-W-010 — Apply updates model
    testWidgets('TC-W-010: entering new duration and tapping Apply fires callback', (tester) async {
      int appliedFocus = 0;
      await tester.pumpWidget(_buildPanel(
        onApply: ({required focusM, required breakM}) => appliedFocus = focusM,
      ));
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, '50');
      await tester.tap(find.text('APPLY & RESET'));
      await tester.pump();
      expect(appliedFocus, 50);
    });

    // TC-W-011 — Non-numeric input is rejected (FilteringTextInputFormatter)
    testWidgets('TC-W-011: non-numeric characters are filtered out', (tester) async {
      int appliedFocus = 0;
      await tester.pumpWidget(_buildPanel(
        onApply: ({required focusM, required breakM}) => appliedFocus = focusM,
      ));
      await tester.pump();
      // FilteringTextInputFormatter.digitsOnly strips 'abc' to ''
      // empty parse falls back to default 75
      await tester.enterText(find.byType(TextField).first, 'abc');
      await tester.tap(find.text('APPLY & RESET'));
      await tester.pump();
      expect(appliedFocus, 75); // default fallback
    });

    testWidgets('TC-W-011b: out-of-range value is clamped and reflected back', (tester) async {
      int appliedFocus = 0;
      await tester.pumpWidget(_buildPanel(
        onApply: ({required focusM, required breakM}) => appliedFocus = focusM,
      ));
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, '999');
      await tester.tap(find.text('APPLY & RESET'));
      await tester.pump();
      expect(appliedFocus, 240); // clamped to max
      // Controller text should be updated to '240'
      final ctrl = tester
          .widget<TextField>(find.byType(TextField).first)
          .controller!;
      expect(ctrl.text, '240');
    });
  });
}
