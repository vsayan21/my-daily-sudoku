import 'package:flutter/material.dart';

class StatTilesRow extends StatelessWidget {
  const StatTilesRow({
    super.key,
    required this.hintsUsed,
    required this.pausesCount,
  });

  final int hintsUsed;
  final int pausesCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatTile(
            icon: Icons.lightbulb_outline_rounded,
            label: 'Hints used',
            value: hintsUsed.toString(),
            usePrimaryContainer: true,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatTile(
            icon: Icons.pause_rounded,
            label: 'Pauses',
            value: pausesCount.toString(),
            usePrimaryContainer: false,
          ),
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.usePrimaryContainer,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool usePrimaryContainer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final backgroundColor = usePrimaryContainer
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainer;
    final foregroundColor = usePrimaryContainer
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: foregroundColor),
          const SizedBox(height: 8),
          Text(
            label,
            style: theme.textTheme.labelMedium?.copyWith(
              color: foregroundColor.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }
}
