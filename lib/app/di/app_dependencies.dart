import 'package:shared_preferences/shared_preferences.dart';

import '../../features/firebase/firebase_sync_service.dart';
import '../../features/active_game/data/datasources/active_game_local_datasource.dart';
import '../../features/active_game/data/repositories/active_game_repository_impl.dart';
import '../../features/active_game/domain/repositories/active_game_repository.dart';
import '../../features/daily_sudoku/application/usecases/get_today_sudoku.dart';
import '../../features/daily_sudoku/data/datasources/sudoku_assets_datasource.dart';
import '../../features/daily_sudoku/data/repositories/daily_sudoku_repository_impl.dart';
import '../../features/daily_sudoku/domain/repositories/daily_sudoku_repository.dart';
import '../../features/profile/data/datasources/user_profile_local_datasource.dart';
import '../../features/profile/data/services/firebase_profile_service.dart';
import '../../features/statistics/data/datasources/statistics_local_datasource.dart';

class AppDependencies {
  AppDependencies({SharedPreferences? sharedPreferences})
      : _sharedPreferences = sharedPreferences;

  SharedPreferences? _sharedPreferences;
  FirebaseProfileService? _firebaseProfileService;
  FirebaseSyncService? _firebaseSyncService;

  Future<SharedPreferences> get sharedPreferences async {
    _sharedPreferences ??= await SharedPreferences.getInstance();
    return _sharedPreferences!;
  }

  FirebaseProfileService get firebaseProfileService {
    _firebaseProfileService ??= FirebaseProfileService();
    return _firebaseProfileService!;
  }

  Future<FirebaseSyncService> get firebaseSyncService async {
    _firebaseSyncService ??= FirebaseSyncService(
      profileService: firebaseProfileService,
      profileLocalDataSource: UserProfileLocalDataSource(
        await sharedPreferences,
      ),
      statisticsLocalDataSource: StatisticsLocalDataSource(
        await sharedPreferences,
      ),
    );
    return _firebaseSyncService!;
  }

  DailySudokuRepository get dailySudokuRepository => DailySudokuRepositoryImpl(
        dataSource: SudokuAssetsDataSource(),
      );

  GetTodaySudoku get todaySudokuUseCase => GetTodaySudoku(
        repository: dailySudokuRepository,
      );

  Future<ActiveGameRepository> get activeGameRepository async {
    return ActiveGameRepositoryImpl(
      dataSource: ActiveGameLocalDataSource(await sharedPreferences),
    );
  }
}
