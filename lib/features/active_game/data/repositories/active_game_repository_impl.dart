import '../../domain/entities/active_game_session.dart';
import '../../domain/repositories/active_game_repository.dart';
import '../datasources/active_game_local_datasource.dart';
import '../models/active_game_session_model.dart';

class ActiveGameRepositoryImpl implements ActiveGameRepository {
  const ActiveGameRepositoryImpl({required ActiveGameLocalDataSource dataSource})
      : _dataSource = dataSource;

  final ActiveGameLocalDataSource _dataSource;

  @override
  Future<ActiveGameSession?> load() async {
    return _dataSource.fetchSession();
  }

  @override
  Future<void> save(ActiveGameSession session) {
    return _dataSource.persistSession(ActiveGameSessionModel.fromEntity(session));
  }

  @override
  Future<void> clear() {
    return _dataSource.clearSession();
  }
}
