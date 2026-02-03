import 'package:flutter/material.dart';

import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';

class DifficultySegment extends StatelessWidget {
  const DifficultySegment({
    super.key,
    required this.selected,
    required this.easyLabel,
    required this.mediumLabel,
    required this.hardLabel,
    required this.onSelectionChanged,
  });

  final SudokuDifficulty selected;
  final String easyLabel;
  final String mediumLabel;
  final String hardLabel;
  final ValueChanged<SudokuDifficulty> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<SudokuDifficulty>(
      segments: [
        ButtonSegment(
          value: SudokuDifficulty.easy,
          label: Text(easyLabel),
        ),
        ButtonSegment(
          value: SudokuDifficulty.medium,
          label: Text(mediumLabel),
        ),
        ButtonSegment(
          value: SudokuDifficulty.hard,
          label: Text(hardLabel),
        ),
      ],
      selected: <SudokuDifficulty>{selected},
      onSelectionChanged: (selection) {
        if (selection.isNotEmpty) {
          onSelectionChanged(selection.first);
        }
      },
    );
  }
}
