import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../statistics/shared/statistics_keys.dart';
import '../../../streak/streak_keys.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String? _versionLabel;

  static const String _legalUrl = 'https://www.polyapps.ch';

  @override
  void initState() {
    super.initState();
    _loadVersionLabel();
  }

  Future<void> _openLink(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!context.mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.settingsLinkFailed),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }


  Future<void> _resetStatistics(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    final confirmed = await _confirmAction(
      context,
      title: loc.settingsResetStatsTitle,
      message: loc.settingsResetStatsMessage,
      actionLabel: loc.settingsResetStatsAction,
    );
    if (confirmed != true) {
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StatisticsKeys.recordsV1);
    await prefs.remove(StatisticsKeys.recordsV2);
    await prefs.remove(StatisticsKeys.aggregates);
    await prefs.remove(StreakKeys.streakCount);
    await prefs.remove(StreakKeys.streakLongest);
    await prefs.remove(StreakKeys.todaySolved);
    await prefs.remove(StreakKeys.lastSolvedDate);
    await prefs.remove(StreakKeys.lastCompletedDateKey);
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(loc.settingsResetStatsDone),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _loadVersionLabel() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (!mounted) {
        return;
      }
      setState(() {
        _versionLabel = 'Version ${info.version}';
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _versionLabel = 'Version —';
      });
    }
  }

  Future<bool?> _confirmAction(
    BuildContext context, {
    required String title,
    required String message,
    required String actionLabel,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(actionLabel),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.settingsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            loc.settingsData,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.restart_alt_rounded),
                  title: Text(loc.settingsResetStats),
                  onTap: () => _resetStatistics(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            loc.settingsLegal,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 8),
          Card(
            elevation: 0,
            color: colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.privacy_tip_outlined),
                  title: Text(loc.settingsPrivacy),
                  trailing: const Icon(Icons.open_in_new_rounded),
                  onTap: () => _openLink(context, _legalUrl),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded),
                  title: Text(loc.settingsImprint),
                  trailing: const Icon(Icons.open_in_new_rounded),
                  onTap: () => _openLink(context, _legalUrl),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.center,
            child: Text(
              _versionLabel ?? 'Version —',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
