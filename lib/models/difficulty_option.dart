import 'package:flutter/material.dart';

class DifficultyOption {
  const DifficultyOption({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.icon,
    required this.focusTag,
  });

  final String title;
  final String subtitle;
  final Color accentColor;
  final IconData icon;
  final String focusTag;
}
