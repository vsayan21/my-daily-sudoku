import 'dart:io';

import 'package:flutter/material.dart';

import '../../domain/entities/user_profile.dart';

class ProfileCard extends StatelessWidget {
  const ProfileCard({
    super.key,
    required this.profile,
    required this.onEditName,
    required this.onPickAvatar,
  });

  final UserProfile profile;
  final VoidCallback onEditName;
  final VoidCallback onPickAvatar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final avatarFile = profile.avatarPath == null
        ? null
        : File(profile.avatarPath!);
    final avatarExists = avatarFile != null && avatarFile.existsSync();

    return Card(
      color: colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: onPickAvatar,
              borderRadius: BorderRadius.circular(32),
              child: CircleAvatar(
                radius: 32,
                backgroundColor: colorScheme.primaryContainer,
                backgroundImage: avatarExists ? FileImage(avatarFile!) : null,
                child: avatarExists
                    ? null
                    : Icon(
                        Icons.person_rounded,
                        size: 32,
                        color: colorScheme.onPrimaryContainer,
                      ),
              ),
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
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: onEditName,
                        icon: const Icon(Icons.edit_rounded),
                        tooltip: 'Edit name',
                      ),
                    ],
                  ),
                  Text(
                    'ID: ${profile.shortId}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
