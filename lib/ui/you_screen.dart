import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/backup_service.dart';
import '../providers.dart';
import '../settings/app_info_provider.dart';
import '../settings/daily_check_provider.dart';
import '../settings/region_provider.dart';
import '../settings/theme_provider.dart';
import 'import_flow.dart';
import 'widgets/accent_picker.dart';
import 'widgets/app_nav_bar.dart';
import 'widgets/premium_app_bar.dart';
import 'widgets/region_sheet.dart';
import 'widgets/settings_section.dart';
import 'widgets/stats_card.dart';

/// The You tab: stats on top, then grouped settings.
class YouScreen extends ConsumerWidget {
  const YouScreen({super.key});

  void _showCredits(BuildContext context) {
    final text = Theme.of(context).textTheme;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Credits and data sources', style: text.titleLarge),
              const SizedBox(height: 16),
              Text(
                'Movie and series data: this product uses the TMDB API but is not '
                    'endorsed or certified by TMDB.',
                style: text.bodyMedium,
              ),
              const SizedBox(height: 12),
              Text('Streaming data by JustWatch, via TMDB.', style: text.bodyMedium),
              const SizedBox(height: 12),
              Text('Book data: Open Library.', style: text.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  /// Writes the backup file and opens the share sheet.
  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await exportBackup(ref.read(databaseProvider));
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not export your data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final dailyCheck = ref.watch(dailyCheckProvider).asData?.value ?? true;
    final region = ref.watch(regionProvider).asData?.value ?? defaultRegion;
    final version = ref.watch(appVersionProvider).asData?.value ?? '';

    return Scaffold(
      appBar: const PremiumAppBar(title: 'You'),
      body: ListView(
        padding: EdgeInsets.only(bottom: navBarClearance(context) + 8),
        children: [
          const StatsCard(),

          SettingsSection(
            title: 'Appearance',
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Theme', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemeMode>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            icon: Icon(Icons.brightness_auto_outlined),
                            label: Text('System'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            icon: Icon(Icons.light_mode_outlined),
                            label: Text('Light'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            icon: Icon(Icons.dark_mode_outlined),
                            label: Text('Dark'),
                          ),
                        ],
                        selected: {mode},
                        onSelectionChanged: (s) =>
                            ref.read(themeModeProvider.notifier).set(s.first),
                      ),
                    ),
                  ],
                ),
              ),
              const AccentPicker(),
            ],
          ),

          SettingsSection(
            title: 'New episodes',
            children: [
              SettingsTile(
                icon: Icons.notifications_active_outlined,
                title: 'Daily check',
                subtitle: dailyCheck
                    ? 'On: checks about once a day'
                    : 'Off: no new-episode notifications',
                trailing: Switch(
                  value: dailyCheck,
                  onChanged: (v) =>
                      ref.read(dailyCheckProvider.notifier).set(v),
                ),
                onTap: () =>
                    ref.read(dailyCheckProvider.notifier).set(!dailyCheck),
              ),
            ],
          ),

          SettingsSection(
            title: 'Streaming',
            children: [
              SettingsTile(
                icon: Icons.public,
                title: 'Region',
                subtitle: '${regionName(region)} ($region)',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => showRegionSheet(context, ref),
              ),
            ],
          ),

          SettingsSection(
            title: 'Backup and data',
            children: [
              SettingsTile(
                icon: Icons.file_upload_outlined,
                title: 'Export to JSON',
                subtitle: 'Save everything, including watch history',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _export(context, ref),
              ),
              SettingsTile(
                icon: Icons.file_download_outlined,
                title: 'Import from JSON',
                subtitle: 'Restore from a backup file',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => importBackupFlow(context, ref),
              ),
            ],
          ),

          SettingsSection(
            title: 'About',
            children: [
              SettingsTile(
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: version.isEmpty ? '...' : version,
              ),
              SettingsTile(
                icon: Icons.favorite_outline,
                title: 'Credits and data sources',
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _showCredits(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}