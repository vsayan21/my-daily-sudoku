import 'dart:ui';

import 'package:flutter/material.dart';

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
    return Row(
      children: [
        Expanded(
          child: _BestTimeTile(
            label: 'Best Easy',
            seconds: bestTimes[SudokuDifficulty.easy],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BestTimeTile(
            label: 'Best Medium',
            seconds: bestTimes[SudokuDifficulty.medium],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _BestTimeTile(
            label: 'Best Hard',
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
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              displayValue,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
