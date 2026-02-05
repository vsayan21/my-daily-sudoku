import 'package:flutter/material.dart';
import 'package:my_daily_sudoku/l10n/app_localizations.dart';

import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';

class RankingDifficultySegment extends StatelessWidget {
  const RankingDifficultySegment({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final SudokuDifficulty value;
  final ValueChanged<SudokuDifficulty> onChanged;
  static const double _segmentHeight = 40;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return SegmentedButton<SudokuDifficulty>(
      segments: [
        ButtonSegment(
          value: SudokuDifficulty.easy,
          label: Text(loc.difficultyEasy),
        ),
        ButtonSegment(
          value: SudokuDifficulty.medium,
          label: Text(loc.difficultyMedium),
        ),
        ButtonSegment(
          value: SudokuDifficulty.hard,
          label: Text(loc.difficultyHard),
        ),
      ],
      expandedInsets: EdgeInsets.zero,
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        minimumSize: WidgetStateProperty.all(
          const Size(0, _segmentHeight),
        ),
      ),
    );
  }
}
