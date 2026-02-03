import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';

class UpdateDisplayName {
  UpdateDisplayName({required UserProfileRepository repository})
      : _repository = repository;

  final UserProfileRepository _repository;

  Future<UserProfile> execute({
    required UserProfile profile,
    required String displayName,
  }) async {
    final trimmed = displayName.trim();
    final normalized = trimmed.isEmpty
        ? UserProfile.defaultDisplayName
        : trimmed;
    final bounded = normalized.length > 24
        ? normalized.substring(0, 24)
        : normalized;
    final updated = profile.copyWith(displayName: bounded);
    await _repository.saveUserProfile(updated);
    return updated;
  }
}
