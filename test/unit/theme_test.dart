import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:focusguard/theme.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Theme helpers', () {
    // TC-U-018 — Font helpers return valid TextStyle
    // Uses testWidgets so the FakeAsync zone captures the async font-load error that
    // GoogleFonts fires when allowRuntimeFetching=false and fonts aren't in test assets.
    testWidgets('TC-U-018: orbitron, mono, exo return non-null TextStyle',
        (tester) async {
      // Suppress "font not found in assets" errors — fonts are only bundled in
      // production builds; we only need to verify the TextStyle objects are created.
      final originalHandler = FlutterError.onError;
      FlutterError.onError = (details) {
        if (details.exception.toString().contains('GoogleFonts')) return;
        originalHandler?.call(details);
      };
      addTearDown(() => FlutterError.onError = originalHandler);

      final orb = orbitron(14, FontWeight.w600, C.focus);
      expect(orb, isA<TextStyle>());
      expect(orb.fontFamily, isNotNull);

      final m = mono(12, C.text2);
      expect(m, isA<TextStyle>());
      expect(m.fontFamily, isNotNull);

      final e = exo(13, FontWeight.w400, C.text);
      expect(e, isA<TextStyle>());
      expect(e.fontFamily, isNotNull);

      await tester.pumpAndSettle(); // drain async font-loading futures
    });

    // TC-U-019 — Color constants are non-null
    test('TC-U-019: all color constants in C are non-null Color values', () {
      for (final color in [
        C.bg, C.bg2, C.bg3, C.surface, C.border, C.border2,
        C.focus, C.focDim, C.focGlow, C.brk, C.brkDim, C.brkGlow,
        C.text, C.text2, C.text3, C.danger, C.dangerDim, C.ring,
      ]) {
        expect(color, isA<Color>());
      }
      expect(C.mc(true), equals(C.focus));
      expect(C.mc(false), equals(C.brk));
    });
  });
}
