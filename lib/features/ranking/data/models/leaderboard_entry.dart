class LeaderboardEntry {
  const LeaderboardEntry({
    required this.displayName,
    required this.elapsedSeconds,
  });

  final String displayName;
  final int elapsedSeconds;

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      displayName: json['displayName'] as String? ?? 'Player',
      elapsedSeconds: json['elapsedSeconds'] as int? ?? 0,
    );
  }
}
