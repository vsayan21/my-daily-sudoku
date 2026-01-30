import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../../domain/repositories/active_game_repository.dart';

class ResetActiveGameFor {
  const ResetActiveGameFor({required ActiveGameRepository repository})
      : _repository = repository;

  final ActiveGameRepository _repository;

  Future<void> execute({
    required String dateKey,
    required SudokuDifficulty difficulty,
  }) async {
    final session = await _repository.load();
    if (session == null) {
      return;
    }
    if (session.dateKey != dateKey || session.difficulty != difficulty) {
      return;
    }
    await _repository.clear();
  }
}
