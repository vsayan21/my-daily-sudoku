import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  String _localizedDifficulty(AppLocalizations loc) {
    switch (difficulty) {
      case SudokuDifficulty.easy:
        return loc.difficultyEasy;
      case SudokuDifficulty.medium:
        return loc.difficultyMedium;
      case SudokuDifficulty.hard:
        return loc.difficultyHard;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;
    final difficultyLabel = _localizedDifficulty(loc);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            tooltip: loc.cancel,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$difficultyLabel ${loc.sudoku}',
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
