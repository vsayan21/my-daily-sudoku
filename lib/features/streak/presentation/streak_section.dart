import 'package:flutter/material.dart';

import '../application/usecases/get_streak_summary.dart';
import '../domain/streak_state.dart';
import 'widgets/streak_card.dart';

class StreakSection extends StatelessWidget {
  const StreakSection({
    super.key,
    required this.summary,
  });

  final StreakSummary summary;

  @override
  Widget build(BuildContext context) {
    return StreakCard(
      state: StreakState(
        streakCount: summary.currentStreak,
        todaySolved: summary.todaySolved,
        lastSolvedDate: summary.lastCompletedDateKey,
      ),
    );
  }
}
