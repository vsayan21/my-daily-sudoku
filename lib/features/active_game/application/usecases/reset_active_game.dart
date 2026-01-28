import '../../domain/entities/active_game_session.dart';
import '../../domain/repositories/active_game_repository.dart';

class ResetActiveGame {
  const ResetActiveGame({
    required ActiveGameRepository repository,
    DateTime Function()? nowProvider,
  })  : _repository = repository,
        _nowProvider = nowProvider ?? DateTime.now;

  final ActiveGameRepository _repository;
  final DateTime Function() _nowProvider;

  Future<ActiveGameSession> execute(ActiveGameSession session) async {
    final refreshed = session.copyWith(
      current: session.puzzle,
      elapsedSeconds: 0,
      isPaused: false,
      lastUpdatedEpochMs: _nowProvider().millisecondsSinceEpoch,
    );
    await _repository.save(refreshed);
    return refreshed;
  }
}
