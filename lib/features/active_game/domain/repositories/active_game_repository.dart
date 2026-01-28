import '../entities/active_game_session.dart';

abstract class ActiveGameRepository {
  Future<ActiveGameSession?> load();

  Future<void> save(ActiveGameSession session);

  Future<void> clear();
}
