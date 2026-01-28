import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme();

  ThemeData theme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF2B6CB0),
      ),
      useMaterial3: true,
    );
  }
}
