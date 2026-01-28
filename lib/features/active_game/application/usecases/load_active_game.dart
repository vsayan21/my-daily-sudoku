import '../../../daily_sudoku/shared/daily_key.dart';
import '../../domain/entities/active_game_session.dart';
import '../../domain/repositories/active_game_repository.dart';

class LoadActiveGame {
  const LoadActiveGame({
    required ActiveGameRepository repository,
    DateTime Function()? nowProvider,
  })  : _repository = repository,
        _nowProvider = nowProvider ?? DateTime.now;

  final ActiveGameRepository _repository;
  final DateTime Function() _nowProvider;

  Future<ActiveGameSession?> execute() async {
    final session = await _repository.load();
    if (session == null) {
      return null;
    }
    final todayKey = buildDailyKey(now: _nowProvider());
    if (session.dateKey != todayKey) {
      await _repository.clear();
      return null;
    }
    return session;
  }
}
