import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../settings/theme_provider.dart';
import 'widgets/accent_picker.dart';
import 'widgets/app_nav_bar.dart';
import 'widgets/premium_app_bar.dart';
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);

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

          const SettingsSection(
            title: 'New episodes',
            children: [
              SettingsTile(
                icon: Icons.notifications_active_outlined,
                title: 'Daily check',
                subtitle: 'Turn the new-episode check on or off',
                soon: true,
              ),
            ],
          ),

          const SettingsSection(
            title: 'Streaming',
            children: [
              SettingsTile(
                icon: Icons.public,
                title: 'Region',
                subtitle: 'Australia (AU). More regions later',
                soon: true,
              ),
            ],
          ),

          const SettingsSection(
            title: 'Backup and data',
            children: [
              SettingsTile(
                icon: Icons.file_upload_outlined,
                title: 'Export to JSON',
                subtitle: 'Save everything, including watch history',
                soon: true,
              ),
              SettingsTile(
                icon: Icons.file_download_outlined,
                title: 'Import from JSON',
                subtitle: 'Restore from a backup file',
                soon: true,
              ),
            ],
          ),

          SettingsSection(
            title: 'About',
            children: [
              const SettingsTile(
                icon: Icons.info_outline,
                title: 'Version',
                subtitle: '1.0.0',
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