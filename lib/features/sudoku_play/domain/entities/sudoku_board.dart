import 'sudoku_cell.dart';

/// Identifies a Sudoku cell by row and column.
typedef SudokuPosition = ({int row, int col});

/// Represents a 9x9 Sudoku board with initial and current values.
class SudokuBoard {
  /// Creates a Sudoku board from initial values and optional current values.
  SudokuBoard({
    required List<List<int>> initialValues,
    List<List<int>>? currentValues,
  })  : initialValues = _copyGrid(initialValues),
        currentValues = _copyGrid(currentValues ?? initialValues) {
    if (initialValues.length != 9 || initialValues.any((row) => row.length != 9)) {
      throw ArgumentError('Sudoku board must be 9x9.');
    }
  }

  /// The original puzzle values.
  final List<List<int>> initialValues;

  /// The current editable values.
  final List<List<int>> currentValues;

  /// Returns the cell at the given position.
  SudokuCell cellAt(int row, int col) {
    final value = currentValues[row][col];
    final isGiven = initialValues[row][col] != 0;
    return SudokuCell(value: value, isGiven: isGiven);
  }

  /// Returns true when a cell is editable.
  bool isEditable(int row, int col) => initialValues[row][col] == 0;

  /// Returns a new board with the updated value.
  SudokuBoard setValue(int row, int col, int value) {
    final updated = _copyGrid(currentValues);
    updated[row][col] = value;
    return SudokuBoard(initialValues: initialValues, currentValues: updated);
  }

  static List<List<int>> _copyGrid(List<List<int>> source) {
    return source.map((row) => List<int>.from(row)).toList();
  }
}
