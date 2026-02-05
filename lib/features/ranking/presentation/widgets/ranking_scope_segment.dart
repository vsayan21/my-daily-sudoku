import 'package:flutter/material.dart';
import 'package:my_daily_sudoku/l10n/app_localizations.dart';

import 'ranking_types.dart';

class RankingScopeSegment extends StatelessWidget {
  const RankingScopeSegment({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final RankingScope value;
  final ValueChanged<RankingScope> onChanged;
  static const double _segmentHeight = 40;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return SegmentedButton<RankingScope>(
      segments: [
        ButtonSegment(
          value: RankingScope.global,
          icon: const Icon(Icons.public_rounded),
          label: Text(loc.rankingScopeGlobal),
        ),
        ButtonSegment(
          value: RankingScope.local,
          icon: const Icon(Icons.place_rounded),
          label: Text(loc.rankingScopeLocal),
        ),
        const ButtonSegment(
          value: RankingScope.friends,
          icon: Icon(Icons.group_rounded),
          label: Text('Friends'),
        ),
      ],
      expandedInsets: EdgeInsets.zero,
      selected: {value},
      onSelectionChanged: (selection) {
        final next = selection.first;
        if (next == RankingScope.friends) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Coming soon')),
          );
          return;
        }
        onChanged(next);
      },
      style: ButtonStyle(
        visualDensity: VisualDensity.compact,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
        minimumSize: WidgetStateProperty.all(
          const Size(0, _segmentHeight),
        ),
      ),
    );
  }
}
