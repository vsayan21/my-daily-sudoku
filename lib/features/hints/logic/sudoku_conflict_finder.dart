import '../../sudoku_play/domain/entities/sudoku_board.dart';

/// Finds conflicts in a Sudoku grid.
class SudokuConflictFinder {
  /// Returns a set of positions that violate Sudoku rules.
  Set<SudokuPosition> findConflicts(List<List<int>> grid) {
    final conflicts = <SudokuPosition>{};

    for (var row = 0; row < 9; row++) {
      _collectDuplicates(
        positions: List.generate(
          9,
          (col) => (row: row, col: col),
        ),
        values: List.generate(9, (col) => grid[row][col]),
        conflicts: conflicts,
      );
    }

    for (var col = 0; col < 9; col++) {
      _collectDuplicates(
        positions: List.generate(
          9,
          (row) => (row: row, col: col),
        ),
        values: List.generate(9, (row) => grid[row][col]),
        conflicts: conflicts,
      );
    }

    for (var boxRow = 0; boxRow < 3; boxRow++) {
      for (var boxCol = 0; boxCol < 3; boxCol++) {
        final positions = <SudokuPosition>[];
        final values = <int>[];
        for (var row = boxRow * 3; row < boxRow * 3 + 3; row++) {
          for (var col = boxCol * 3; col < boxCol * 3 + 3; col++) {
            positions.add((row: row, col: col));
            values.add(grid[row][col]);
          }
        }
        _collectDuplicates(
          positions: positions,
          values: values,
          conflicts: conflicts,
        );
      }
    }

    return conflicts;
  }

  void _collectDuplicates({
    required List<SudokuPosition> positions,
    required List<int> values,
    required Set<SudokuPosition> conflicts,
  }) {
    final valueMap = <int, List<SudokuPosition>>{};
    for (var index = 0; index < values.length; index++) {
      final value = values[index];
      if (value == 0) {
        continue;
      }
      valueMap.putIfAbsent(value, () => []).add(positions[index]);
    }
    for (final entry in valueMap.entries) {
      if (entry.value.length > 1) {
        conflicts.addAll(entry.value);
      }
    }
  }
}
