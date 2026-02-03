import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<UserProfile> loadUserProfile();

  Future<void> saveUserProfile(UserProfile profile);
}
