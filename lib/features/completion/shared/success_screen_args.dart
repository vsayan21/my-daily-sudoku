import '../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../../medals/domain/medal.dart';

class SuccessScreenArgs {
  const SuccessScreenArgs({
    required this.dateKey,
    required this.difficulty,
    required this.elapsedSeconds,
    required this.hintsUsed,
    required this.movesCount,
    required this.undoCount,
    required this.medal,
    required this.streakCount,
  });

  final String dateKey;
  final SudokuDifficulty difficulty;
  final int elapsedSeconds;
  final int hintsUsed;
  final int movesCount;
  final int undoCount;
  final Medal medal;
  final int streakCount;
}
