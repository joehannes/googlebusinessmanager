import 'package:flutter/material.dart';

const _indigo = Color(0xFF4F46E5);
const _teal = Color(0xFF14B8A6);

/// Amber used to flag unverified AI price estimations.
const aiEstimateColor = Color(0xFFF59E0B);
const aiEstimateBackground = Color(0x33F59E0B);

ThemeData _base(Brightness brightness) {
  final scheme = ColorScheme.fromSeed(
    seedColor: _indigo,
    brightness: brightness,
    primary: brightness == Brightness.light ? _indigo : const Color(0xFF818CF8),
    secondary: _teal,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor:
        brightness == Brightness.light ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
    appBarTheme: AppBarTheme(
      backgroundColor:
          brightness == Brightness.light ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A),
      foregroundColor:
          brightness == Brightness.light ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      elevation: 0,
      centerTitle: false,
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16))),
    ),
    inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}

final ThemeData appTheme = _base(Brightness.light);
final ThemeData appDarkTheme = _base(Brightness.dark);
