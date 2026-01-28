import 'package:flutter/material.dart';

import '../models/difficulty_option.dart';
import '../widgets/difficulty_card.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  List<DifficultyOption> _buildOptions() {
    return const [
      DifficultyOption(
        title: 'Einfach',
        subtitle: 'Sanfter Start mit klaren Hinweisen.',
        accentColor: Color(0xFF38A169),
        icon: Icons.wb_sunny_outlined,
        focusTag: '1 tägliches Rätsel',
      ),
      DifficultyOption(
        title: 'Mittel',
        subtitle: 'Für den täglichen Flow, ausgewogen.',
        accentColor: Color(0xFFDD6B20),
        icon: Icons.auto_graph,
        focusTag: '1 tägliches Rätsel',
      ),
      DifficultyOption(
        title: 'Schwer',
        subtitle: 'Knifflig für echte Sudoku-Fans.',
        accentColor: Color(0xFF805AD5),
        icon: Icons.bolt_outlined,
        focusTag: '1 tägliches Rätsel',
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
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
                        'Starte mit deinem täglichen Sudoku',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Jeden Tag steht für alle Nutzer ein einfaches, '
                        'mittleres und schweres Rätsel bereit.',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 24),
                      Expanded(
                        child: Column(
                          children: options
                              .map(
                                (option) => Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: DifficultyCard(
                                    option: option,
                                    onPressed: () {},
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_fire_department_outlined,
                              color: colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Dein Fortschritt zählt täglich neu. '
                                'Bleib dran und halte deine Serie!',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
