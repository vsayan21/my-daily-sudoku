import 'package:flutter/material.dart';
import 'package:my_daily_sudoku/l10n/app_localizations.dart';

import '../../domain/entities/daily_sudoku.dart';

/// Debug preview showing puzzle ID and first row.
class DailySudokuDebugPreview extends StatelessWidget {
  final DailySudoku sudoku;

  /// Creates the debug preview widget.
  const DailySudokuDebugPreview({
    super.key,
    required this.sudoku,
  });

  String get _firstRow {
    if (sudoku.puzzle.length < 9) {
      return sudoku.puzzle;
    }
    return sudoku.puzzle.substring(0, 9);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;
    final monoStyle = textTheme.bodyMedium?.copyWith(
      fontFamily: 'RobotoMono',
      letterSpacing: 1.2,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(loc.debugPuzzleId(sudoku.id), style: textTheme.bodyMedium),
        const SizedBox(height: 4),
        Text(loc.debugRowLabel(_firstRow), style: monoStyle),
      ],
    );
  }
}
