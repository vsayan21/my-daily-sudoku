import '../../data/services/firebase_profile_service.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/exceptions/username_taken_exception.dart';
import '../../domain/repositories/user_profile_repository.dart';

class UpdateDisplayName {
  UpdateDisplayName({
    required UserProfileRepository repository,
    required FirebaseProfileService firebaseProfileService,
  })  : _repository = repository,
        _firebaseProfileService = firebaseProfileService;

  final UserProfileRepository _repository;
  final FirebaseProfileService _firebaseProfileService;

  Future<UserProfile> execute({
    required UserProfile profile,
    required String displayName,
  }) async {
    final normalized = _firebaseProfileService.normalizeDisplayName(displayName);
    final bounded = normalized.length > 24
        ? normalized.substring(0, 24)
        : normalized;
    final candidate = bounded.isEmpty
        ? _firebaseProfileService.defaultDisplayNameForUid(profile.userId)
        : bounded;
    if (!_firebaseProfileService.isValidDisplayName(candidate)) {
      return profile;
    }
    final previousLower = _firebaseProfileService
        .normalizeDisplayName(profile.displayName)
        .toLowerCase();
    try {
      final reservedName = await _firebaseProfileService.reserveDisplayName(
        uid: profile.userId,
        displayName: candidate,
        previousDisplayNameLower: previousLower,
      );
      final updated = profile.copyWith(displayName: reservedName);
      await _repository.saveUserProfile(updated);
      return updated;
    } on UsernameTakenException {
      rethrow;
    }
  }
}
