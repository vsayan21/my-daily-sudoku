import 'sudoku_cell.dart';

/// Identifies a Sudoku cell by row and column.
typedef SudokuPosition = ({int row, int col});

/// Represents a 9x9 Sudoku board with initial and current values.
class SudokuBoard {
  /// Creates a Sudoku board from initial values and optional current values.
  SudokuBoard({
    required List<List<int>> initialValues,
    List<List<int?>>? currentValues,
    List<List<Set<int>>>? notes,
  })  : initialValues = _copyGrid(initialValues),
        currentValues = _copyNullableGrid(
          currentValues ?? _toNullableGrid(initialValues),
        ),
        notes = _copyNotesGrid(
          notes ?? _emptyNotesGrid(),
        ) {
    if (initialValues.length != 9 || initialValues.any((row) => row.length != 9)) {
      throw ArgumentError('Sudoku board must be 9x9.');
    }
  }

  /// The original puzzle values.
  final List<List<int>> initialValues;

  /// The current editable values.
  final List<List<int?>> currentValues;

  /// Manual notes for each cell.
  final List<List<Set<int>>> notes;

  /// Returns current values as integers with 0 for empty.
  List<List<int>> get currentValuesAsInts {
    return List.generate(9, (row) {
      return List.generate(
        9,
        (col) => currentValues[row][col] ?? 0,
      );
    });
  }

  /// Returns the cell at the given position.
  SudokuCell cellAt(int row, int col) {
    final value = currentValues[row][col];
    final isGiven = initialValues[row][col] != 0;
    return SudokuCell(
      value: value,
      notes: Set<int>.from(notes[row][col]),
      isGiven: isGiven,
    );
  }

  /// Returns true when a cell is editable.
  bool isEditable(int row, int col) => initialValues[row][col] == 0;

  /// Returns a new board with the updated value.
  SudokuBoard setCell({
    required int row,
    required int col,
    required int? value,
    required Set<int> notes,
  }) {
    final updatedValues = _copyNullableGrid(currentValues);
    updatedValues[row][col] = value;
    final updatedNotes = _copyNotesGrid(this.notes);
    updatedNotes[row][col] = Set<int>.from(notes);
    return SudokuBoard(
      initialValues: initialValues,
      currentValues: updatedValues,
      notes: updatedNotes,
    );
  }

  static List<List<int>> _copyGrid(List<List<int>> source) {
    return source.map((row) => List<int>.from(row)).toList();
  }

  static List<List<int?>> _copyNullableGrid(List<List<int?>> source) {
    return source.map((row) => List<int?>.from(row)).toList();
  }

  static List<List<int?>> _toNullableGrid(List<List<int>> source) {
    return source
        .map((row) => row.map((cell) => cell == 0 ? null : cell).toList())
        .toList();
  }

  static List<List<Set<int>>> _copyNotesGrid(List<List<Set<int>>> source) {
    return source
        .map((row) => row.map((notes) => Set<int>.from(notes)).toList())
        .toList();
  }

  static List<List<Set<int>>> _emptyNotesGrid() {
    return List.generate(9, (_) => List.generate(9, (_) => <int>{}));
  }
}
