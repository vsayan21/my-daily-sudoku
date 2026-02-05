import 'package:flutter/material.dart';

class SystemAvatar extends StatelessWidget {
  const SystemAvatar({
    super.key,
    required this.userId,
    this.displayName,
    this.size = 40,
  });

  final String userId;
  final String? displayName;
  final double size;

  @override
  Widget build(BuildContext context) {
    final color = _colorForUser(userId);
    final initials = _initialsForName(displayName);
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: color,
      child: initials == null
          ? Icon(
              Icons.person_rounded,
              color: Colors.white,
              size: size * 0.5,
            )
          : Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: size * 0.36,
              ),
            ),
    );
  }

  Color _colorForUser(String value) {
    final hash = value.isEmpty ? 0 : value.hashCode;
    final hue = (hash.abs() % 360).toDouble();
    return HSLColor.fromAHSL(1, hue, 0.45, 0.55).toColor();
  }

  String? _initialsForName(String? name) {
    if (name == null) {
      return null;
    }
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return null;
    }
    final parts = trimmed.split(RegExp(r'\s+'));
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final second =
        parts.length > 1 && parts[1].isNotEmpty ? parts[1][0] : '';
    final initials = (first + second).toUpperCase();
    return initials.isEmpty ? null : initials;
  }
}
