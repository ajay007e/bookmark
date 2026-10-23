import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'background/background_worker.dart';
import 'background/notifications.dart';
import 'router.dart';

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

class BookmarkApp extends StatelessWidget {
  const BookmarkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Bookmark',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      darkTheme: ThemeData(
        colorSchemeSeed: Colors.teal,
        brightness: Brightness.dark,
        useMaterial3: true,
      ),
      routerConfig: appRouter,
    );
  }
}