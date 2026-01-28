import 'package:flutter/foundation.dart';

import '../../domain/entities/sudoku_board.dart';
import '../../domain/logic/sudoku_conflict_checker.dart';

/// Controller for Sudoku play interactions.
class SudokuPlayController extends ChangeNotifier {
  /// Creates a controller with the given board.
  SudokuPlayController({
    required SudokuBoard board,
  })  : _board = board,
        _conflicts = SudokuConflictChecker().findConflicts(board.currentValues);

  SudokuBoard _board;
  SudokuPosition? _selectedCell;
  Set<SudokuPosition> _conflicts;

  /// Current Sudoku board state.
  SudokuBoard get board => _board;

  /// Currently selected cell position.
  SudokuPosition? get selectedCell => _selectedCell;

  /// Cells that are currently in conflict.
  Set<SudokuPosition> get conflicts => _conflicts;

  /// Selects a cell by row and column.
  void selectCell(int row, int col) {
    _selectedCell = (row: row, col: col);
    notifyListeners();
  }

  /// Inputs a value into the selected cell.
  void inputValue(int value) {
    final selection = _selectedCell;
    if (selection == null) {
      return;
    }
    if (!_board.isEditable(selection.row, selection.col)) {
      return;
    }
    _board = _board.setValue(selection.row, selection.col, value);
    _recomputeConflicts();
    notifyListeners();
  }

  /// Clears the selected cell.
  void erase() => inputValue(0);

  void _recomputeConflicts() {
    _conflicts = SudokuConflictChecker().findConflicts(_board.currentValues);
  }
}
