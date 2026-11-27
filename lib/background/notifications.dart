import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

final _plugin = FlutterLocalNotificationsPlugin();

const _checkInId = 900000001;
const _stoppedId = 900000002;
const _sessionId = 900000003;

const stopActionId = 'stop_session';
const _alarmChannelId = 'reading_alarm_v4';
const _alarmUri = UriAndroidNotificationSound('content://settings/system/alarm_alert');

const _oldChannels = [
  'reading_checkin_alarm',
  'reading_checkin_alarm_v2',
  'reading_alarm_v3',
];
const _oldSounds = ['alarm', 'notification', 'silent'];
const _oldVibrations = ['off', 'gentle', 'standard', 'strong'];

const _stoppedDetails = NotificationDetails(
  android: AndroidNotificationDetails(
    'reading_session',
    'Reading sessions',
    channelDescription: 'Tells you when a reading session stopped',
    importance: Importance.high,
    priority: Priority.high,
  ),
);

final _alarmChannel = AndroidNotificationChannel(
  _alarmChannelId,
  'Reading alarm',
  description: 'Rings like an alarm when a reading session asks if you are still reading',
  importance: Importance.max,
  playSound: true,
  sound: _alarmUri,
  audioAttributesUsage: AudioAttributesUsage.alarm,
  enableVibration: true,
  vibrationPattern: Int64List.fromList([0, 800, 400, 800, 400, 800, 400, 800]),
);

NotificationDetails _alarmDetails(DateTime at, DateTime deadline) {
  return NotificationDetails(
    android: AndroidNotificationDetails(
      _alarmChannelId,
      'Reading alarm',
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      sound: _alarmUri,
      playSound: true,
      enableVibration: true,
      vibrationPattern: Int64List.fromList([0, 800, 400, 800, 400, 800, 400, 800]),
      additionalFlags: Int32List.fromList(<int>[4]),
      fullScreenIntent: true,
      visibility: NotificationVisibility.public,
      ongoing: true,
      autoCancel: true,
      timeoutAfter: deadline.difference(at).inMilliseconds,
      showWhen: true,
      when: deadline.millisecondsSinceEpoch,
      usesChronometer: true,
      chronometerCountDown: true,
    ),
  );
}

String? _payloadOf(NotificationResponse response) =>
    response.actionId == stopActionId ? 'stop' : response.payload;

Future<void> initNotifications({void Function(String? payload)? onTap}) async {
  tzdata.initializeTimeZones();
  const settings = InitializationSettings(
    android: AndroidInitializationSettings('@mipmap/ic_launcher'),
  );
  await _plugin.initialize(
    settings: settings,
    onDidReceiveNotificationResponse: (response) =>
        onTap?.call(_payloadOf(response)),
  );

  final android = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  try {
    await android?.createNotificationChannel(_alarmChannel);
    final old = [
      ..._oldChannels,
      for (final s in _oldSounds)
        for (final v in _oldVibrations) 'reading_alarm_${s}_$v',
    ];
    for (final id in old) {
      await android?.deleteNotificationChannel(channelId: id);
    }
  } catch (e) {
    debugPrint('[Session] channel setup failed: $e');
  }
}

Future<String?> notificationLaunchPayload() async {
  final details = await _plugin.getNotificationAppLaunchDetails();
  if (details == null || !details.didNotificationLaunchApp) return null;
  final response = details.notificationResponse;
  return response == null ? null : _payloadOf(response);
}

Future<void> requestNotificationPermission() async {
  await _plugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
}

Future<bool> exactAlarmsAllowed() async {
  final android = _plugin.resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>();
  try {
    return await android?.canScheduleExactNotifications() ?? false;
  } catch (_) {
    return false;
  }
}

Future<void> openExactAlarmSettings() async {
  try {
    await _plugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestExactAlarmsPermission();
  } catch (_) {}
}

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

Future<void> showNewEpisodes({
  required int id,
  required String title,
  required String body,
  String? imageUrl,
}) async {
  final picture = await _download(imageUrl);

  final details = AndroidNotificationDetails(
    'new_episodes',
    'New episodes',
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

Future<void> showSessionNotification({
  required int itemId,
  required String title,
  required DateTime startedAt,
}) async {
  try {
    await _plugin.show(
      id: _sessionId,
      title: 'Reading session',
      body: title,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'reading_timer',
          'Reading timer',
          channelDescription: 'Shows the running time of a reading session',
          importance: Importance.low,
          priority: Priority.low,
          ongoing: true,
          autoCancel: false,
          onlyAlertOnce: true,
          showWhen: true,
          when: startedAt.millisecondsSinceEpoch,
          usesChronometer: true,
          visibility: NotificationVisibility.public,
          actions: const [
            AndroidNotificationAction(
              stopActionId,
              'Stop',
              showsUserInterface: true,
              cancelNotification: false,
            ),
          ],
        ),
      ),
      payload: '$itemId',
    );
  } catch (_) {}
}

Future<void> cancelSessionNotification() async {
  try {
    await _plugin.cancel(id: _sessionId);
  } catch (_) {}
}

Future<void> scheduleCheckIn({
  required String title,
  required DateTime at,
  required DateTime deadline,
}) async {
  final exact = await exactAlarmsAllowed();
  final mode = exact
      ? AndroidScheduleMode.alarmClock
      : AndroidScheduleMode.inexactAllowWhileIdle;
  final soon = DateTime.now().add(const Duration(seconds: 2));
  debugPrint('[Session] check-in alarm set for $at, exact allowed: $exact, mode: $mode');

  try {
    if (at.isAfter(soon)) {
      await _plugin.zonedSchedule(
        id: _checkInId,
        title: 'Still reading?',
        body: 'Answer before the countdown ends or "$title" stops.',
        scheduledDate: tz.TZDateTime.from(at, tz.UTC),
        notificationDetails: _alarmDetails(at, deadline),
        androidScheduleMode: mode,
        payload: 'checkin',
      );
    }
    if (deadline.isAfter(soon)) {
      await _plugin.zonedSchedule(
        id: _stoppedId,
        title: 'Reading session stopped',
        body: '"$title" had no answer. Open Bookmark to update your progress.',
        scheduledDate: tz.TZDateTime.from(deadline, tz.UTC),
        notificationDetails: _stoppedDetails,
        androidScheduleMode: mode,
        payload: 'checkin',
      );
    }
  } catch (e) {
    debugPrint('[Session] could not schedule the check-in: $e');
  }
}

Future<void> cancelCheckInAlert() async {
  try {
    await _plugin.cancel(id: _checkInId);
  } catch (_) {}
}

Future<void> cancelCheckIn() async {
  try {
    await _plugin.cancel(id: _checkInId);
    await _plugin.cancel(id: _stoppedId);
  } catch (_) {}
}