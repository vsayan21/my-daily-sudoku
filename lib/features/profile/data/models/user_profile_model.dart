import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.userId,
    required super.displayName,
    super.avatarPath,
    super.countryCode,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['userId'] as String? ?? '',
      displayName:
          json['displayName'] as String? ?? UserProfile.defaultDisplayName,
      avatarPath: json['avatarPath'] as String?,
      countryCode: json['countryCode'] as String?,
    );
  }

  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      userId: profile.userId,
      displayName: profile.displayName,
      avatarPath: profile.avatarPath,
      countryCode: profile.countryCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'avatarPath': avatarPath,
      'countryCode': countryCode,
    };
  }
}
