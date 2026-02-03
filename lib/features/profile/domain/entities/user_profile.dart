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
    final sanitized = userId.replaceAll('-', '');
    final padded = sanitized.padRight(8, '0');
    final short = padded.substring(0, 8).toUpperCase();
    return '${short.substring(0, 4)}-${short.substring(4, 8)}';
  }
}
