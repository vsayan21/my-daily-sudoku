import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';

class UpdateAvatarPath {
  UpdateAvatarPath({required UserProfileRepository repository})
      : _repository = repository;

  final UserProfileRepository _repository;

  Future<UserProfile> execute({
    required UserProfile profile,
    required String? avatarPath,
  }) async {
    final updated = profile.copyWith(avatarPath: avatarPath);
    await _repository.saveUserProfile(updated);
    return updated;
  }
}
