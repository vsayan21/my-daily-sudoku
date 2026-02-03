import 'package:flutter/material.dart';
import 'package:my_daily_sudoku/l10n/app_localizations.dart';

class BottomNavigation extends StatelessWidget {
  const BottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onDestinationSelected,
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          label: loc.navigationHome,
        ),
        NavigationDestination(
          icon: const Icon(Icons.bar_chart_outlined),
          selectedIcon: const Icon(Icons.bar_chart),
          label: loc.navigationStatistics,
        ),
        NavigationDestination(
          icon: const Icon(Icons.leaderboard_outlined),
          selectedIcon: const Icon(Icons.leaderboard_rounded),
          label: loc.navigationProfile,
        ),
      ],
    );
  }
}
