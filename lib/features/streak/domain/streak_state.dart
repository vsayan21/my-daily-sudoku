class StreakState {
  const StreakState({
    required this.streakCount,
    required this.todaySolved,
    this.lastSolvedDate,
  });

  final int streakCount;
  final bool todaySolved;
  final String? lastSolvedDate;
}
