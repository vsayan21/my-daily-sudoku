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
      ],
      selected: {value},
      onSelectionChanged: (selection) => onChanged(selection.first),
    );
  }
}
