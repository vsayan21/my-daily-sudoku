import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../../../medals/domain/medal.dart';
import '../../../medals/domain/medal_rules.dart';

class TimeResultCard extends StatelessWidget {
  const TimeResultCard({
    super.key,
    required this.difficulty,
    required this.elapsedSeconds,
    required this.medal,
  });

  final SudokuDifficulty difficulty;
  final int elapsedSeconds;
  final Medal medal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final goldSeconds = _goldThresholdSeconds(difficulty);
    final timeLabel = _formatSeconds(elapsedSeconds);
    final goldLabel = _formatSeconds(goldSeconds);
    final achievedGold = medal == Medal.gold;
    final deltaSeconds = math.max(0, elapsedSeconds - goldSeconds);
    final deltaLabel = _formatDelta(deltaSeconds);

    final badgeBackground = _badgeBackground(scheme, medal);
    final badgeForeground = _badgeForeground(scheme, medal);

    final progressMax = math.max(goldSeconds * 2, 1);
    final progressValue = math.min(elapsedSeconds, progressMax) / progressMax;

    return Card(
      elevation: 1,
      color: scheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  'Time',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: badgeBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.emoji_events_rounded,
                        size: 14,
                        color: badgeForeground,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        formatMedalLabel(medal),
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: badgeForeground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
                color: scheme.primaryContainer.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.emoji_events_rounded,
                    size: 34,
                    color: _medalColor(scheme, medal),
                  ),
                  const SizedBox(width: 14),
                  Text(
                    timeLabel,
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: scheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Text(
                  'Gold: ≤ $goldLabel',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const Spacer(),
                Text(
                  achievedGold ? 'Gold achieved' : '$deltaLabel to Gold',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: achievedGold
                        ? scheme.tertiary
                        : scheme.onSurfaceVariant,
                    fontWeight: achievedGold ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progressValue,
                minHeight: 6,
                backgroundColor:
                    scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _medalColor(scheme, medal).withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _goldThresholdSeconds(SudokuDifficulty difficulty) {
    switch (difficulty) {
      case SudokuDifficulty.easy:
        return MedalRules.easyGoldSeconds;
      case SudokuDifficulty.medium:
        return MedalRules.mediumGoldSeconds;
      case SudokuDifficulty.hard:
        return MedalRules.hardGoldSeconds;
    }
  }

  String _formatSeconds(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final remaining = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$remaining';
  }

  String _formatDelta(int secondsOver) {
    final minutes = (secondsOver ~/ 60).toString().padLeft(2, '0');
    final remaining = (secondsOver % 60).toString().padLeft(2, '0');
    return '+$minutes:$remaining';
  }

  Color _medalColor(ColorScheme scheme, Medal medal) {
    switch (medal) {
      case Medal.gold:
        return scheme.tertiary;
      case Medal.silver:
        return scheme.secondary;
      case Medal.bronze:
        return scheme.primary;
    }
  }

  Color _badgeBackground(ColorScheme scheme, Medal medal) {
    switch (medal) {
      case Medal.gold:
        return scheme.tertiaryContainer.withValues(alpha: 0.7);
      case Medal.silver:
        return scheme.secondaryContainer.withValues(alpha: 0.7);
      case Medal.bronze:
        return scheme.primaryContainer.withValues(alpha: 0.7);
    }
  }

  Color _badgeForeground(ColorScheme scheme, Medal medal) {
    switch (medal) {
      case Medal.gold:
        return scheme.onTertiaryContainer;
      case Medal.silver:
        return scheme.onSecondaryContainer;
      case Medal.bronze:
        return scheme.onPrimaryContainer;
    }
  }
}
