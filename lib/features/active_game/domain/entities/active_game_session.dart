import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';

class ActiveGameSession {
  const ActiveGameSession({
    required this.difficulty,
    required this.dateKey,
    required this.puzzleId,
    required this.puzzle,
    required this.current,
    required this.givens,
    required this.elapsedSeconds,
    required this.isPaused,
    required this.lastUpdatedEpochMs,
  });

  final SudokuDifficulty difficulty;
  final String dateKey;
  final String? puzzleId;
  final String puzzle;
  final String current;
  final String givens;
  final int elapsedSeconds;
  final bool isPaused;
  final int lastUpdatedEpochMs;

  ActiveGameSession copyWith({
    SudokuDifficulty? difficulty,
    String? dateKey,
    String? puzzleId,
    String? puzzle,
    String? current,
    String? givens,
    int? elapsedSeconds,
    bool? isPaused,
    int? lastUpdatedEpochMs,
  }) {
    return ActiveGameSession(
      difficulty: difficulty ?? this.difficulty,
      dateKey: dateKey ?? this.dateKey,
      puzzleId: puzzleId ?? this.puzzleId,
      puzzle: puzzle ?? this.puzzle,
      current: current ?? this.current,
      givens: givens ?? this.givens,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isPaused: isPaused ?? this.isPaused,
      lastUpdatedEpochMs: lastUpdatedEpochMs ?? this.lastUpdatedEpochMs,
    );
  }
}
