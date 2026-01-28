import '../entities/sudoku_board.dart';

/// Detects conflicting Sudoku cells in rows, columns, and boxes.
class SudokuConflictChecker {
  /// Returns the set of conflicting positions for the given values.
  Set<SudokuPosition> findConflicts(List<List<int>> values) {
    final conflicts = <SudokuPosition>{};

    void addConflicts(Map<int, List<SudokuPosition>> buckets) {
      for (final entry in buckets.entries) {
        if (entry.key == 0) {
          continue;
        }
        if (entry.value.length > 1) {
          conflicts.addAll(entry.value);
        }
      }
    }

    for (var row = 0; row < 9; row++) {
      final buckets = <int, List<SudokuPosition>>{};
      for (var col = 0; col < 9; col++) {
        final value = values[row][col];
        buckets.putIfAbsent(value, () => []).add((row: row, col: col));
      }
      addConflicts(buckets);
    }

    for (var col = 0; col < 9; col++) {
      final buckets = <int, List<SudokuPosition>>{};
      for (var row = 0; row < 9; row++) {
        final value = values[row][col];
        buckets.putIfAbsent(value, () => []).add((row: row, col: col));
      }
      addConflicts(buckets);
    }

    for (var boxRow = 0; boxRow < 3; boxRow++) {
      for (var boxCol = 0; boxCol < 3; boxCol++) {
        final buckets = <int, List<SudokuPosition>>{};
        for (var row = boxRow * 3; row < boxRow * 3 + 3; row++) {
          for (var col = boxCol * 3; col < boxCol * 3 + 3; col++) {
            final value = values[row][col];
            buckets.putIfAbsent(value, () => []).add((row: row, col: col));
          }
        }
        addConflicts(buckets);
      }
    }

    return conflicts;
  }
}
