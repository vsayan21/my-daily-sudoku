import 'package:flutter/material.dart';

import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';

/// Top bar for the Sudoku play screen.
class SudokuTopBar extends StatelessWidget {
  /// Creates a Sudoku top bar.
  const SudokuTopBar({
    super.key,
    required this.difficulty,
    required this.puzzleId,
    required this.dailyKey,
    required this.onBack,
  });

  /// Selected difficulty.
  final SudokuDifficulty difficulty;

  /// Current puzzle identifier.
  final String puzzleId;

  /// Daily key in YYYY-MM-DD format.
  final String dailyKey;

  /// Callback for back navigation.
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${difficulty.label} Sudoku',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '$dailyKey • $puzzleId',
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
