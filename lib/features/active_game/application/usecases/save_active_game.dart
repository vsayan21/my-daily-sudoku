import '../../domain/entities/active_game_session.dart';
import '../../domain/repositories/active_game_repository.dart';

class SaveActiveGame {
  const SaveActiveGame({required ActiveGameRepository repository})
      : _repository = repository;

  final ActiveGameRepository _repository;

  Future<void> execute(ActiveGameSession session) {
    return _repository.save(session);
  }
}
