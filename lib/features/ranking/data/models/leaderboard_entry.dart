class LeaderboardEntry {
  const LeaderboardEntry({
    required this.displayName,
    required this.elapsedSeconds,
    required this.countryCode,
    required this.medal,
  });

  final String displayName;
  final int elapsedSeconds;
  final String countryCode;
  final String medal;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      displayName: json['displayName'] as String? ?? 'Player',
      elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
      countryCode: (json['countryCode'] as String? ?? '').toUpperCase(),
      medal: (json['medal'] as String? ?? '').toLowerCase(),
    );
  }
}
