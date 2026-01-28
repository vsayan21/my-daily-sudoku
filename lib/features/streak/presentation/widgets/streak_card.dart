import 'package:flutter/material.dart';
import 'package:my_daily_sudoku/l10n/app_localizations.dart';

import '../../domain/streak_state.dart';
import 'streak_header.dart';

class StreakCard extends StatelessWidget {
  const StreakCard({
    super.key,
    required this.state,
  });

  final StreakState state;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
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
                    title: '${state.streakCount} ${loc.streakTitle}',
                    subtitle: state.todaySolved
                        ? loc.streakSubtitleSolved
                        : loc.streakSubtitleOpen,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
