import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../../../medals/domain/medal.dart';

class DifficultyTileState {
  const DifficultyTileState({
    required this.difficulty,
    required this.isSolvedToday,
    this.timeLabel,
    this.medal,
  });

  final SudokuDifficulty difficulty;
  final bool isSolvedToday;
  final String? timeLabel;
  final Medal? medal;
}
