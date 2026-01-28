import '../../domain/repositories/active_game_repository.dart';

class ClearActiveGame {
  const ClearActiveGame({required ActiveGameRepository repository})
      : _repository = repository;

  final ActiveGameRepository _repository;

  Future<void> execute() {
    return _repository.clear();
  }
}
