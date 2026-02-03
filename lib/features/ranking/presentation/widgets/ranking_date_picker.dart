import 'package:flutter/material.dart';

class RankingDatePicker extends StatelessWidget {
  const RankingDatePicker({
    super.key,
    required this.selectedDateKey,
    required this.availableDateKeys,
    required this.labelBuilder,
    required this.onChanged,
  });

  final String selectedDateKey;
  final List<String> availableDateKeys;
  final String Function(String dateKey) labelBuilder;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedDateKey,
            borderRadius: BorderRadius.circular(12),
            items: availableDateKeys
                .map(
                  (dateKey) => DropdownMenuItem<String>(
                    value: dateKey,
                    child: Text(labelBuilder(dateKey)),
                  ),
                )
                .toList(),
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
        ),
      ),
    );
  }
}
