import 'dart:math' as math;
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
    final achievedGold = medal == Medal.gold;
    final deltaSeconds = math.max(0, elapsedSeconds - goldSeconds);
    final deltaLabel = _formatDelta(deltaSeconds);

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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: BoxDecoration(
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
            Center(
              child: Text(
                achievedGold ? 'Gold achieved' : '$deltaLabel to Gold',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: achievedGold ? scheme.tertiary : scheme.onSurface,
                  fontWeight: FontWeight.w600,
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
}
