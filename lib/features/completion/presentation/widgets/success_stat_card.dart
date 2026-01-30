import 'dart:ui';

import 'package:flutter/material.dart';

class SuccessStatCard extends StatelessWidget {
  const SuccessStatCard({
    super.key,
    required this.elapsedLabel,
    required this.hintsUsed,
    required this.pausesCount,
  });

  final String elapsedLabel;
  final int hintsUsed;
  final int pausesCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            _StatRow(
              label: 'Time',
              value: elapsedLabel,
              valueStyle: theme.textTheme.titleLarge?.copyWith(
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 12),
            _StatRow(label: 'Hints used', value: hintsUsed.toString()),
            const SizedBox(height: 12),
            _StatRow(label: 'Pauses', value: pausesCount.toString()),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.label,
    required this.value,
    this.valueStyle,
  });

  final String label;
  final String value;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: valueStyle ?? theme.textTheme.titleMedium,
        ),
      ],
    );
  }
}
