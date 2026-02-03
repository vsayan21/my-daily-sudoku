class UserProfile {
  const UserProfile({
    required this.userId,
    required this.displayName,
    this.avatarPath,
  });

  static const defaultDisplayName = 'Player';

  final String userId;
  final String displayName;
  final String? avatarPath;

  UserProfile copyWith({
    String? userId,
    String? displayName,
    String? avatarPath,
  }) {
    return UserProfile(
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      avatarPath: avatarPath ?? this.avatarPath,
    );
  }

  String get shortId {
    if (userId.isEmpty) {
      return '0000';
    }
    final start = userId.length >= 4 ? userId.length - 4 : 0;
    return userId.substring(start).toUpperCase();
  }
}
