import '../../domain/entities/user_profile.dart';

class UserProfileModel extends UserProfile {
  const UserProfileModel({
    required super.userId,
    required super.displayName,
    super.countryCode,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      userId: json['userId'] as String? ?? '',
      displayName:
          json['displayName'] as String? ?? UserProfile.defaultDisplayName,
      countryCode: json['countryCode'] as String?,
    );
  }

  factory UserProfileModel.fromEntity(UserProfile profile) {
    return UserProfileModel(
      userId: profile.userId,
      displayName: profile.displayName,
      countryCode: profile.countryCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'displayName': displayName,
      'countryCode': countryCode,
    };
  }
}
