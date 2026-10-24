import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'background/background_worker.dart';
import 'background/notifications.dart';
import 'router.dart';
import 'settings/accent_provider.dart';
import 'settings/theme_provider.dart';

/// The notification payload is the series' database id.
void openSeriesFromPayload(String? payload) {
  final id = int.tryParse(payload ?? '');
  if (id == null) return;
  appRouter.push('/item/$id');
}

Future<void> main() async {
  // Needed before using any plugin (workmanager) before runApp.
  WidgetsFlutterBinding.ensureInitialized();

  await initNotifications(onTap: openSeriesFromPayload);
  await requestNotificationPermission();

  // Registers the daily episode check with Android. Safe on every launch.
  await initBackgroundWork();

  // Set when a notification tap started the app from closed.
  final launchPayload = await notificationLaunchPayload();

  runApp(const ProviderScope(child: BookmarkApp()));

  if (launchPayload != null) {
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => openSeriesFromPayload(launchPayload),
    );
  }
}

class BookmarkApp extends ConsumerWidget {
  const BookmarkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final seed = ref.watch(accentProvider).color;

    return MaterialApp.router(
      title: 'Bookmark',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: seed, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: seed,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      themeMode: themeMode,
      routerConfig: appRouter,
    );
  }
}