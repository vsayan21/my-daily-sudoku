import 'package:uuid/uuid.dart';

import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_local_datasource.dart';
import '../models/user_profile_model.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  UserProfileRepositoryImpl({
    required UserProfileLocalDataSource dataSource,
    Uuid? uuidGenerator,
  })  : _dataSource = dataSource,
        _uuidGenerator = uuidGenerator ?? const Uuid();

  final UserProfileLocalDataSource _dataSource;
  final Uuid _uuidGenerator;

  @override
  Future<UserProfile> loadUserProfile() async {
    final stored = _dataSource.loadProfile();
    if (stored != null && stored.userId.isNotEmpty) {
      return stored;
    }
    final profile = UserProfileModel(
      userId: _uuidGenerator.v4(),
      displayName: UserProfile.defaultDisplayName,
      avatarPath: null,
    );
    await _dataSource.saveProfile(profile);
    return profile;
  }

  @override
  Future<void> saveUserProfile(UserProfile profile) async {
    await _dataSource.saveProfile(UserProfileModel.fromEntity(profile));
  }
}
