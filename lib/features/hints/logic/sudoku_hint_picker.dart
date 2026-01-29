import '../../sudoku_play/domain/entities/sudoku_board.dart';

/// A picked hint cell.
class HintPick {
  /// Creates a hint pick.
  const HintPick({
    required this.row,
    required this.col,
    required this.value,
  });

  /// Row index.
  final int row;

  /// Column index.
  final int col;

  /// Value to fill.
  final int value;
}

/// Picks a suitable cell to fill with a hint.
class SudokuHintPicker {
  /// Returns the selected empty cell if valid, otherwise first empty cell.
  HintPick? pickTarget({
    required SudokuBoard board,
    required String solution,
    SudokuPosition? selected,
  }) {
    if (selected != null) {
      if (board.currentValues[selected.row][selected.col] == 0 &&
          board.initialValues[selected.row][selected.col] == 0) {
        final index = selected.row * 9 + selected.col;
        final value = int.tryParse(solution[index]) ?? 0;
        if (value != 0) {
          return HintPick(
            row: selected.row,
            col: selected.col,
            value: value,
          );
        }
      }
    }
    for (var row = 0; row < 9; row++) {
      for (var col = 0; col < 9; col++) {
        if (board.currentValues[row][col] != 0) {
          continue;
        }
        if (board.initialValues[row][col] != 0) {
          continue;
        }
        final index = row * 9 + col;
        final value = int.tryParse(solution[index]) ?? 0;
        if (value == 0) {
          return null;
        }
        return HintPick(row: row, col: col, value: value);
      }
    }
    return null;
  }
}
