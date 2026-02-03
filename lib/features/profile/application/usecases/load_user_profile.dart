import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';

class LoadUserProfile {
  LoadUserProfile({required UserProfileRepository repository})
      : _repository = repository;

  final UserProfileRepository _repository;

  Future<UserProfile> execute() {
    return _repository.loadUserProfile();
  }
}
