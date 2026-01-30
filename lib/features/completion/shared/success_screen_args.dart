import '../../daily_sudoku/domain/entities/sudoku_difficulty.dart';

class SuccessScreenArgs {
  const SuccessScreenArgs({
    required this.dateKey,
    required this.difficulty,
    required this.elapsedSeconds,
    required this.hintsUsed,
    required this.pausesCount,
    required this.streakCount,
  });

  final String dateKey;
  final SudokuDifficulty difficulty;
  final int elapsedSeconds;
  final int hintsUsed;
  final int pausesCount;
  final int streakCount;
}
