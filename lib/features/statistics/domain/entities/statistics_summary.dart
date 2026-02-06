import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';

class StatisticsSummary {
  const StatisticsSummary({
    required this.completedCount,
    this.completedByDifficulty = const {},
    required this.bestTimesSeconds,
    required this.averageTimeSeconds,
    required this.totalHints,
    required this.totalMoves,
    required this.totalUndo,
    required this.goldMedals,
    required this.silverMedals,
    required this.bronzeMedals,
  });

  final int completedCount;
  final Map<SudokuDifficulty, int> completedByDifficulty;
  final Map<SudokuDifficulty, int?> bestTimesSeconds;
  final double? averageTimeSeconds;
  final int totalHints;
  final int totalMoves;
  final int totalUndo;
  final int goldMedals;
  final int silverMedals;
  final int bronzeMedals;
}
