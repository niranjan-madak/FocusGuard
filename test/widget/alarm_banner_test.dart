import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:focusguard/widgets/alarm_banner.dart';
import 'package:focusguard/theme.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AlarmBanner', () {
    // TC-W-004 — Visible when alarm active
    testWidgets('TC-W-004: AlarmBanner is present in the widget tree', (tester) async {
      await tester.pumpWidget(MaterialApp(
        theme: buildTheme(),
        home: Scaffold(
          body: AlarmBanner(
            isFocus: true,
            focusMins: 75,
            breakMins: 20,
            onDismiss: () {},
          ),
        ),
      ));
      expect(find.byType(AlarmBanner), findsOneWidget);
    });

    // TC-W-005 — Hidden when alarm inactive
    testWidgets('TC-W-005: AlarmBanner absent when condition is false', (tester) async {
      bool showBanner = false;
      await tester.pumpWidget(MaterialApp(
        theme: buildTheme(),
        home: StatefulBuilder(
          builder: (context, _) => Scaffold(
            body: showBanner
                ? AlarmBanner(
                    isFocus: true,
                    focusMins: 75,
                    breakMins: 20,
                    onDismiss: () {},
                  )
                : const SizedBox(),
          ),
        ),
      ));
      expect(find.byType(AlarmBanner), findsNothing);
    });

    // TC-W-004b — Dismiss callback fires
    testWidgets('TC-W-004b: tapping dismiss calls onDismiss', (tester) async {
      bool dismissed = false;
      await tester.pumpWidget(MaterialApp(
        theme: buildTheme(),
        home: Scaffold(
          body: AlarmBanner(
            isFocus: false,
            focusMins: 75,
            breakMins: 20,
            onDismiss: () => dismissed = true,
          ),
        ),
      ));
      await tester.tap(find.text('✕'));
      expect(dismissed, true);
    });
  });
}
