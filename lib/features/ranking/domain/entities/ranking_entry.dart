class RankingEntry {
  const RankingEntry({
    required this.uid,
    required this.displayName,
    required this.displayNameLower,
    required this.elapsedSeconds,
    required this.hintsUsed,
    required this.movesCount,
    required this.undoCount,
    this.completedAt,
    this.medal,
    this.shortId,
  });

  final String uid;
  final String displayName;
  final String displayNameLower;
  final int elapsedSeconds;
  final int hintsUsed;
  final int movesCount;
  final int undoCount;
  final DateTime? completedAt;
  final String? medal;
  final String? shortId;
}
