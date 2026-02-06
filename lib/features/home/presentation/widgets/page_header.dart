import 'package:flutter/material.dart';

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.onSettingsPressed,
  });

  final String title;
  final VoidCallback? onSettingsPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        if (onSettingsPressed != null)
          IconButton(
            onPressed: onSettingsPressed,
            icon: const Icon(Icons.settings_rounded),
            tooltip: 'Settings',
          ),
      ],
    );
  }
}
