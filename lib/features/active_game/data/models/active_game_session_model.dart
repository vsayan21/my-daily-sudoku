import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../../domain/entities/active_game_session.dart';

class ActiveGameSessionModel extends ActiveGameSession {
  const ActiveGameSessionModel({
    required super.difficulty,
    required super.dateKey,
    required super.puzzleId,
    required super.puzzle,
    required super.current,
    required super.givens,
    required super.elapsedSeconds,
    required super.isPaused,
    required super.lastUpdatedEpochMs,
  });

  factory ActiveGameSessionModel.fromEntity(ActiveGameSession session) {
    return ActiveGameSessionModel(
      difficulty: session.difficulty,
      dateKey: session.dateKey,
      puzzleId: session.puzzleId,
      puzzle: session.puzzle,
      current: session.current,
      givens: session.givens,
      elapsedSeconds: session.elapsedSeconds,
      isPaused: session.isPaused,
      lastUpdatedEpochMs: session.lastUpdatedEpochMs,
    );
  }

  factory ActiveGameSessionModel.fromJson(Map<String, dynamic> json) {
    final difficultyRaw = json['difficulty'] as String?;
    return ActiveGameSessionModel(
      difficulty: SudokuDifficulty.values.firstWhere(
        (value) => value.name == difficultyRaw,
        orElse: () => SudokuDifficulty.easy,
      ),
      dateKey: json['dateKey'] as String? ?? '',
      puzzleId: json['puzzleId'] as String?,
      puzzle: json['puzzle'] as String? ?? '',
      current: json['current'] as String? ?? '',
      givens: json['givens'] as String? ?? '',
      elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
      isPaused: json['isPaused'] as bool? ?? true,
      lastUpdatedEpochMs: json['lastUpdatedEpochMs'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'difficulty': difficulty.name,
      'dateKey': dateKey,
      'puzzleId': puzzleId,
      'puzzle': puzzle,
      'current': current,
      'givens': givens,
      'elapsedSeconds': elapsedSeconds,
      'isPaused': isPaused,
      'lastUpdatedEpochMs': lastUpdatedEpochMs,
    };
  }
}
