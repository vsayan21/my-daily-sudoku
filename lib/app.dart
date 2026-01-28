import 'package:flutter/material.dart';

import 'screens/start_screen.dart';

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Daily Sudoku',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2B6CB0),
        ),
        useMaterial3: true,
      ),
      home: const StartScreen(),
    );
  }
}
