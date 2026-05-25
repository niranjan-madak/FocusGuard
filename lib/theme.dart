import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class C {
  static const bg      = Color(0xFF05070F);
  static const bg2     = Color(0xFF0B0F1E);
  static const bg3     = Color(0xFF111827);
  static const surface = Color(0xFF141C2E);
  static const border  = Color(0xFF1E2D47);
  static const border2 = Color(0xFF2A3F5F);
  static const focus   = Color(0xFFF59E0B);
  static const focDim  = Color(0xFF7C4F0A);
  static const focGlow = Color(0x38F59E0B);
  static const brk     = Color(0xFF06D6A0);
  static const brkDim  = Color(0xFF065947);
  static const brkGlow = Color(0x2E06D6A0);
  static const text    = Color(0xFFE8EAF0);
  static const text2   = Color(0xFF8899B4);
  static const text3   = Color(0xFF4A5A70);
  static const danger  = Color(0xFFEF4444);
  static const dangerDim = Color(0xFF7F1D1D);
  static const ring    = Color(0xFF1A2438);

  static Color mc(bool isFocus) => isFocus ? focus : brk;
  static Color md(bool isFocus) => isFocus ? focDim : brkDim;
  static Color mg(bool isFocus) => isFocus ? focGlow : brkGlow;
}

ThemeData buildTheme() => ThemeData(
  scaffoldBackgroundColor: C.bg,
  colorScheme: const ColorScheme.dark(
    surface: C.surface,
    primary: C.focus,
    onSurface: C.text,
  ),
  textTheme: GoogleFonts.exo2TextTheme(
    ThemeData.dark().textTheme,
  ).apply(bodyColor: C.text, displayColor: C.text),
  useMaterial3: true,
);

TextStyle orbitron(double size, FontWeight weight, Color color) =>
    GoogleFonts.orbitron(fontSize: size, fontWeight: weight, color: color, letterSpacing: size * 0.05);

TextStyle mono(double size, Color color) =>
    GoogleFonts.shareTechMono(fontSize: size, color: color, letterSpacing: size * 0.06);

TextStyle exo(double size, FontWeight weight, Color color, {double? spacing}) =>
    GoogleFonts.exo2(fontSize: size, fontWeight: weight, color: color, letterSpacing: spacing);
