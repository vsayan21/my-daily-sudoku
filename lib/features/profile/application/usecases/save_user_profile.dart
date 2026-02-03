import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';

class SaveUserProfile {
  SaveUserProfile({required UserProfileRepository repository})
      : _repository = repository;

  final UserProfileRepository _repository;

  Future<void> execute(UserProfile profile) {
    return _repository.saveUserProfile(profile);
  }
}
