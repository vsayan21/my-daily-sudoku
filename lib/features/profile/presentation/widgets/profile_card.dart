import 'package:flutter/material.dart';
import 'package:my_daily_sudoku/l10n/app_localizations.dart';

import '../../domain/entities/user_profile.dart';
import '../../../../shared/presentation/widgets/system_avatar.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.profile,
    required this.onEditName,
    required this.onEditCountry,
  });

  final UserProfile profile;
  final VoidCallback onEditName;
  final VoidCallback onEditCountry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final loc = AppLocalizations.of(context)!;
    final flag = _flagEmoji(profile.countryCode);
    final countryLabel =
        profile.countryCode == null ? loc.profileCountryUnset : profile.countryCode!;

    return Card(
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SystemAvatar(
                  userId: profile.userId,
                  displayName: profile.displayName,
                  size: 80,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              profile.displayName,
                              style: textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            onPressed: onEditName,
                            icon: const Icon(Icons.edit_rounded, size: 18),
                            tooltip: loc.profileEditNameTooltip,
                            visualDensity: VisualDensity.compact,
                          ),
                          IconButton(
                            onPressed: onEditCountry,
                            icon: const Icon(Icons.public_rounded, size: 18),
                            tooltip: loc.profileEditCountryTooltip,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: colorScheme.outlineVariant,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (flag != null) ...[
                              Text(flag, style: textTheme.bodyMedium),
                              const SizedBox(width: 6),
                            ],
                                Text(
                                  countryLabel,
                                  style: textTheme.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String? _flagEmoji(String? code) {
    if (code == null) {
      return null;
    }
    final trimmed = code.trim().toUpperCase();
    if (!RegExp(r'^[A-Z]{2}$').hasMatch(trimmed)) {
      return null;
    }
    final base = 0x1F1E6;
    final chars = trimmed.codeUnits
        .map((unit) => base + (unit - 65))
        .toList(growable: false);
    return String.fromCharCodes(chars);
  }
}
