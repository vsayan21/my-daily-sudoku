import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:my_daily_sudoku/l10n/app_localizations.dart';

class ActiveGameCard extends StatelessWidget {
  const ActiveGameCard({
    super.key,
    required this.difficultyLabel,
    required this.dateKey,
    required this.elapsedSeconds,
    required this.isPaused,
    required this.onContinue,
    required this.onReset,
  });

  final String difficultyLabel;
  final String dateKey;
  final int elapsedSeconds;
  final bool isPaused;
  final VoidCallback onContinue;
  final VoidCallback onReset;

  static const double _cornerRadius = 20;

  String _formatElapsed() {
    final minutes = (elapsedSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (elapsedSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;
    final statusLabel = isPaused
        ? loc.activeGameStatusPaused(_formatElapsed())
        : loc.activeGameStatusInProgress;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(_cornerRadius),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  loc.activeGameContinueTitle,
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  statusLabel,
                  style: textTheme.labelMedium?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (!isPaused) ...[
                const SizedBox(width: 12),
                Text(
                  _formatElapsed(),
                  style: textTheme.titleMedium?.copyWith(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '$difficultyLabel • $dateKey',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 14),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  onPressed: onContinue,
                  style: FilledButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(loc.activeGameContinue),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: onReset,
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(loc.activeGameReset),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
