import 'package:flutter/material.dart';
import 'package:my_daily_sudoku/l10n/app_localizations.dart';

import '../../../medals/domain/medal.dart';

class TimeWithMedal extends StatelessWidget {
  const TimeWithMedal({
    super.key,
    required this.medal,
    required this.timeLabel,
  });

  final Medal medal;
  final String timeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loc = AppLocalizations.of(context)!;
    final colorScheme = theme.colorScheme;
    final medalColor = _medalColor(colorScheme, medal);
    final timeStyle = theme.textTheme.displaySmall?.copyWith(
      fontWeight: FontWeight.w700,
      fontFeatures: const [FontFeature.tabularFigures()],
      color: colorScheme.onSurface,
    );

    return Semantics(
      label: _semanticLabel(loc),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.25),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.emoji_events_rounded,
              size: 34,
              color: medalColor,
            ),
          ),
          const SizedBox(width: 12),
          Text(timeLabel, style: timeStyle),
        ],
      ),
    );
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

  String _semanticLabel(AppLocalizations loc) {
    final medalLabel = _medalLabel(loc);
    final parts = timeLabel.split(':');
    final minutes = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final seconds = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return loc.timeWithMedalSemantics(
      medalLabel,
      minutes,
      seconds,
    );
  }

  String _medalLabel(AppLocalizations loc) {
    switch (medal) {
      case Medal.gold:
        return loc.medalGold;
      case Medal.silver:
        return loc.medalSilver;
      case Medal.bronze:
        return loc.medalBronze;
    }
  }
}
