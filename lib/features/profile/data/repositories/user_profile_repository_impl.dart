import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_local_datasource.dart';
import '../models/user_profile_model.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  UserProfileRepositoryImpl({
    required UserProfileLocalDataSource dataSource,
    required Future<String> Function() userIdProvider,
    required String Function(String uid) defaultNameBuilder,
  })  : _dataSource = dataSource,
        _userIdProvider = userIdProvider,
        _defaultNameBuilder = defaultNameBuilder;

  final UserProfileLocalDataSource _dataSource;
  final Future<String> Function() _userIdProvider;
  final String Function(String uid) _defaultNameBuilder;

  @override
  Future<UserProfile> loadUserProfile() async {
    final stored = _dataSource.loadProfile();
    final uid = await _userIdProvider();
    if (stored != null &&
        stored.userId == uid &&
        stored.displayName.trim().isNotEmpty) {
      return stored;
    }
    final fallbackName = _defaultNameBuilder(uid);
    final displayName = stored == null || stored.displayName.trim().isEmpty
        ? fallbackName
        : stored.displayName;
    final profile = UserProfileModel(
      userId: uid,
      displayName: displayName,
      avatarPath: stored?.avatarPath,
      countryCode: stored?.countryCode,
    );
    await _dataSource.saveProfile(profile);
    return profile;
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    await _dataSource.saveProfile(UserProfileModel.fromEntity(profile));
  }
}
