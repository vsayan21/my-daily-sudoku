import 'package:flutter/material.dart';
import 'package:my_daily_sudoku/l10n/app_localizations.dart';

import '../../../daily_sudoku/domain/entities/sudoku_difficulty.dart';
import '../../application/statistics_view_model.dart';

class BestTimesRow extends StatelessWidget {
  const BestTimesRow({
    super.key,
    required this.bestTimes,
  });

  final Map<SudokuDifficulty, int?> bestTimes;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: _BestTimeTile(
            label: loc.difficultyEasy,
            seconds: bestTimes[SudokuDifficulty.easy],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BestTimeTile(
            label: loc.difficultyMedium,
            seconds: bestTimes[SudokuDifficulty.medium],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BestTimeTile(
            label: loc.difficultyHard,
            seconds: bestTimes[SudokuDifficulty.hard],
          ),
        ),
      ],
    );
  }
}

class _BestTimeTile extends StatelessWidget {
  const _BestTimeTile({
    required this.label,
    required this.seconds,
  });

  final String label;
  final int? seconds;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayValue =
        seconds == null ? '—' : StatisticsViewModel.formatDuration(seconds!);
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
            ),
            const SizedBox(height: 10),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.96, end: 1),
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeOutBack,
              builder: (context, scale, child) {
                return Transform.scale(scale: scale, child: child);
              },
              child: Text(
                displayValue,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: colorScheme.onSurface,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
