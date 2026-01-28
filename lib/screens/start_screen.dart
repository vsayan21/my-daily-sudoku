import 'package:flutter/material.dart';

import '../models/difficulty_option.dart';
import '../widgets/difficulty_card.dart';

class StartScreen extends StatelessWidget {
  const StartScreen({super.key});

  List<DifficultyOption> _buildOptions() {
    return const [
      DifficultyOption(
        title: 'Einfach',
        subtitle: 'Leichtes tägliches Sudoku',
        icon: Icons.wb_sunny_outlined,
      ),
      DifficultyOption(
        title: 'Mittel',
        subtitle: 'Ausgewogenes tägliches Sudoku',
        icon: Icons.auto_graph,
      ),
      DifficultyOption(
        title: 'Schwer',
        subtitle: 'Herausforderndes tägliches Sudoku',
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
                      Text(
                        'Jeden Tag ein neues Rätsel für alle.',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: colorScheme.onSurfaceVariant),
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
