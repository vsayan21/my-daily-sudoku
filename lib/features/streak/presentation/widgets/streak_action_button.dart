import 'package:flutter/material.dart';

class StreakActionButton extends StatelessWidget {
  const StreakActionButton({
    super.key,
    required this.onPressed,
    this.label = 'Solve today',
  });

  final VoidCallback? onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
      ),
      child: Text(label),
    );
  }
}
