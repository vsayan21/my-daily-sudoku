import 'package:flutter/material.dart';

/// Header for the daily easy Sudoku section.
class DailySudokuHeader extends StatelessWidget {
  final String dailyKey;

  /// Creates a header displaying the daily key.
  const DailySudokuHeader({
    super.key,
    required this.dailyKey,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Easy Sudoku',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 4),
        Text(
          dailyKey,
          style: textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
