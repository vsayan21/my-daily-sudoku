import 'package:flutter/material.dart';

import '../../domain/streak_state.dart';
import 'streak_action_button.dart';
import 'streak_header.dart';
import 'streak_week_dots.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({
    super.key,
    required this.state,
    required this.onSolveToday,
  });

  final StreakState state;
  final VoidCallback? onSolveToday;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: StreakHeader(
                    title: '${state.streakCount} Day Streak',
                    subtitle: state.todaySolved
                        ? 'Done for today'
                        : 'Solve today to keep your streak',
                  ),
                ),
                const SizedBox(width: 12),
                StreakActionButton(
                  onPressed: onSolveToday,
                ),
              ],
            ),
            const SizedBox(height: 20),
            StreakWeekDots(
              todaySolved: state.todaySolved,
            ),
          ],
        ),
      ),
    );
  }
}
