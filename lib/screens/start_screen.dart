import 'package:flutter/material.dart';

import '../models/difficulty_option.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/difficulty_card.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  int _selectedIndex = 0;
  int _currentTab = 0;

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
    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
          child: IndexedStack(
            index: _currentTab,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.grid_4x4_outlined,
                          color: colorScheme.onPrimaryContainer,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'My Daily Sudoku',
                        style: Theme.of(context)
                            .textTheme
                            .titleLarge
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ],
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
                  SizedBox(
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
                  const SizedBox(height: 16),
                ],
              ),
              _ComingSoonPanel(
                title: 'Statistik',
                colorScheme: colorScheme,
              ),
              _ComingSoonPanel(
                title: 'Profil',
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigation(
        currentIndex: _currentTab,
        onDestinationSelected: (index) {
          setState(() => _currentTab = index);
        },
      ),
    );
  }
}

class _ComingSoonPanel extends StatelessWidget {
  const _ComingSoonPanel({
    required this.title,
    required this.colorScheme,
  });

  final String title;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title\ncoming soon',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}
