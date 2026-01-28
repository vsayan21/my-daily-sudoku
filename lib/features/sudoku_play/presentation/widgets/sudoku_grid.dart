import 'package:flutter/material.dart';

import '../../domain/entities/sudoku_board.dart';
import 'sudoku_cell_widget.dart';

/// Displays a 9x9 Sudoku grid.
class SudokuGrid extends StatelessWidget {
  /// Creates a Sudoku grid widget.
  const SudokuGrid({
    super.key,
    required this.board,
    required this.selectedCell,
    required this.conflicts,
    required this.onCellTap,
  });

  /// Current Sudoku board.
  final SudokuBoard board;

  /// Selected cell position.
  final SudokuPosition? selectedCell;

  /// Positions that are in conflict.
  final Set<SudokuPosition> conflicts;

  /// Called when a cell is tapped.
  final void Function(int row, int col) onCellTap;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final cellSize = constraints.maxWidth / 9;
          return Column(
            children: List.generate(9, (row) {
              return Row(
                children: List.generate(9, (col) {
                  final cell = board.cellAt(row, col);
                  final isSelected =
                      selectedCell?.row == row && selectedCell?.col == col;
                  final isHighlighted = selectedCell != null &&
                      (selectedCell!.row == row || selectedCell!.col == col);
                  final isConflict = conflicts.contains((row: row, col: col));
                  return SizedBox(
                    width: cellSize,
                    height: cellSize,
                    child: SudokuCellWidget(
                      value: cell.value,
                      isGiven: cell.isGiven,
                      isSelected: isSelected,
                      isHighlighted: isHighlighted,
                      isConflict: isConflict,
                      border: _cellBorder(context, row, col),
                      onTap: () => onCellTap(row, col),
                    ),
                  );
                }),
              );
            }),
          );
        },
      ),
    );
  }

  Border _cellBorder(BuildContext context, int row, int col) {
    const thin = 0.4;
    const thick = 2.0;
    final color = Theme.of(context).colorScheme.outlineVariant;

    return Border(
      top: BorderSide(
        color: color,
        width: row % 3 == 0 ? thick : thin,
      ),
      left: BorderSide(
        color: color,
        width: col % 3 == 0 ? thick : thin,
      ),
      right: BorderSide(
        color: color,
        width: col == 8 ? thick : thin,
      ),
      bottom: BorderSide(
        color: color,
        width: row == 8 ? thick : thin,
      ),
    );
  }
}
