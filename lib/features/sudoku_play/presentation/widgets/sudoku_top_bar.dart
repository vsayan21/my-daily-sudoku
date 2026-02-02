import 'package:flutter/material.dart';
import 'package:my_daily_sudoku/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';

/// Top bar for the Sudoku play screen.
class SudokuTopBar extends StatelessWidget {
  /// Creates a Sudoku top bar.
  const SudokuTopBar({
    super.key,
    required this.difficulty,
    required this.dailyKey,
    required this.onBack,
    required this.isPaused,
    required this.onPauseToggle,
  });

  /// Selected difficulty.
  final SudokuDifficulty difficulty;

  /// Daily key in YYYY-MM-DD format.
  final String dailyKey;

  /// Callback for back navigation.
  final VoidCallback onBack;

  /// Whether the game is paused.
  final bool isPaused;

  /// Callback for pause/resume toggle.
  final VoidCallback onPauseToggle;

  static const double _horizontalPadding = 16;
  static const double _verticalPadding = 12;
  static const double _iconSpacing = 8;

  String _localizedDate(BuildContext context, AppLocalizations loc) {
    final localeTag =
        WidgetsBinding.instance.platformDispatcher.locale.toLanguageTag();
    final parsedDate = DateTime.tryParse(dailyKey);
    if (parsedDate == null) {
      return dailyKey;
    }
    return DateFormat.yMd(localeTag.isEmpty ? null : localeTag)
        .format(parsedDate);
  }

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
    final dateLabel = _localizedDate(context, loc);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: _horizontalPadding,
        vertical: _verticalPadding,
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back),
            tooltip: loc.cancel,
          ),
          const SizedBox(width: _iconSpacing),
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
                  dateLabel,
                  style: textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onPauseToggle,
            icon: Icon(isPaused ? Icons.play_arrow : Icons.pause),
            tooltip: isPaused ? loc.resume : loc.pause,
          ),
        ],
      ),
    );
  }
}
