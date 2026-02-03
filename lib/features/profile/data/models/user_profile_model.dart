import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.userId,
    required super.displayName,
    super.avatarPath,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['userId'] as String? ?? '',
      displayName: json['displayName'] as String? ?? UserProfile.defaultDisplayName,
      avatarPath: json['avatarPath'] as String?,
    );
  }

  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      userId: profile.userId,
      displayName: profile.displayName,
      avatarPath: profile.avatarPath,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'avatarPath': avatarPath,
    };
  }
}
