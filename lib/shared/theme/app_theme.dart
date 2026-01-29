import 'package:flutter/material.dart';

class AppTheme {
  static const Color seedColor = Color(0xFF3A5BA0);

  static final ThemeData lightTheme = _buildTheme(Brightness.light);
  static final ThemeData darkTheme = _buildTheme(Brightness.dark);

  static ThemeData _buildTheme(Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );

    final isDark = brightness == Brightness.dark;
    final scaffoldBackgroundColor = isDark
        ? const Color(0xFF0D0F14)
        : const Color(0xFFF5F7FB);

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      shadowColor: colorScheme.shadow,
    );
  }
}
