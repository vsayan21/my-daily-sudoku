import 'package:flutter/material.dart';

import '../models/difficulty_option.dart';
import '../widgets/difficulty_card.dart';
import '../widgets/streak_overview_card.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int _selectedIndex = 0;

  List<DifficultyOption> _buildOptions() {
    return const [
      DifficultyOption(
        title: 'Leicht',
        icon: Icons.wb_sunny_outlined,
      ),
      DifficultyOption(
        title: 'Mittel',
        icon: Icons.auto_graph,
      ),
      DifficultyOption(
        title: 'Schwer',
        icon: Icons.bolt_outlined,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final options = _buildOptions();
    final colorScheme = Theme.of(context).colorScheme;
    final today = DateTime.now();
    final days = List.generate(
      7,
      (index) => DateTime(
        today.year,
        today.month,
        today.day,
      ).subtract(Duration(days: 6 - index)),
    );
    final hasCompletedToday = false;
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StreakOverviewCard(
                streakCount: 12,
                hasCompletedToday: hasCompletedToday,
                days: days,
              ),
              const SizedBox(height: 24),
              Text(
                'Dein tägliches Sudoku',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                'Wähle ein Level und leg direkt los.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: options.asMap().entries.map((entry) {
                    final index = entry.key;
                    final option = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DifficultyCard(
                        option: option,
                        isSelected: _selectedIndex == index,
                        onPressed: () {
                          setState(() => _selectedIndex = index);
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {},
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text('Start'),
            ),
          ),
        ),
      ),
    );
  }
}
