import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Centralise la configuration du thème de l'application Violette.
class AppTheme {
  static final ThemeData themeData = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF6A1B9A),
      onPrimary: Color(0xFFFFFFFF),
      primaryContainer: Color(0xFFE1BEE7),
      onPrimaryContainer: Color(0xFF311B92),
      secondary: Color(0xFFEC407A),
      onSecondary: Color(0xFFFFFFFF),
      secondaryContainer: Color(0xFFF8BBD0),
      onSecondaryContainer: Color(0xFF880E4F),
      tertiary: Color(0xFF1A237E),
      onTertiary: Color(0xFFFFFFFF),
      error: Color(0xFFEF5350),
      onError: Color(0xFFFFFFFF),
      background: Color(0xFF121212),
      onBackground: Color(0xFFE0E0E0),
      surface: Color(0xFF1E1E1E),
      onSurface: Color(0xFFE0E0E0),
      onSurfaceVariant: Color(0xFFBDBDBD),
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.playfairDisplay(fontSize: 57, fontWeight: FontWeight.w400),
      headlineMedium: GoogleFonts.playfairDisplay(fontSize: 28, fontWeight: FontWeight.w400),
      titleLarge: GoogleFonts.roboto(fontSize: 22, fontWeight: FontWeight.w500),
      bodyLarge: GoogleFonts.roboto(fontSize: 16, fontWeight: FontWeight.w400),
      bodyMedium: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w400),
      labelLarge: GoogleFonts.roboto(fontSize: 14, fontWeight: FontWeight.w500, letterSpacing: 1.25),
    ),
  );
}
