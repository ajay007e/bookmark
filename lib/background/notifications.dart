import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final _plugin = FlutterLocalNotificationsPlugin();

/// Call in main() and in the worker. Each isolate needs its own setup.
/// [onTap] is called with the payload when a notification is tapped while
/// the app is running. Only pass it from the app, not from the worker.
Future<void> initNotifications({void Function(String? payload)? onTap}) async {
  const settings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );
  await _plugin.initialize(
    settings: settings,
    onDidReceiveNotificationResponse: (response) => onTap?.call(response.payload),
  );
}

/// If the app was closed and a notification tap started it, returns that
/// notification's payload. Otherwise null.
Future<String?> notificationLaunchPayload() async {
  final details = await _plugin.getNotificationAppLaunchDetails();
  if (details == null || !details.didNotificationLaunchApp) return null;
  return details.notificationResponse?.payload;
}

/// Asks for the Android 13+ notification permission (shows a system dialog
/// the first time). Call from the app only, never from the worker.
Future<void> requestNotificationPermission() async {
  await _plugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
}

/// Downloads an image so it can be attached to a notification.
/// Returns null on any failure: the notification is then shown without it.
Future<ByteArrayAndroidBitmap?> _download(String? url) async {
  if (url == null) return null;
  try {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 10),
    ));
    final res = await dio.get<List<int>>(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    final data = res.data;
    if (data == null || data.isEmpty) return null;
    return ByteArrayAndroidBitmap(Uint8List.fromList(data));
  } catch (_) {
    return null;
  }
}

/// [id] is the series id, so a second notification for the same series
/// replaces the first instead of stacking. The same id is the payload, so
/// a tap knows which series page to open.
/// [imageUrl] is a wide picture shown when the notification is expanded.
Future<void> showNewEpisodes({
  required int id,
  required String title,
  required String body,
  String? imageUrl,
}) async {
  final picture = await _download(imageUrl);

  final details = AndroidNotificationDetails(
    'new_episodes', // channel id
    'New episodes', // name shown in Android's notification settings
    channelDescription: 'Tells you when a series you follow has a new episode',
    importance: Importance.defaultImportance,
    styleInformation: picture == null
        ? BigTextStyleInformation(body)
        : BigPictureStyleInformation(
      picture,
      contentTitle: title,
      summaryText: body,
    ),
  );

  await _plugin.show(
    id: id,
    title: title,
    body: body,
    notificationDetails: NotificationDetails(android: details),
    payload: '$id',
  );
}