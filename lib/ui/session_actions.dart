import 'dart:math' show max;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../background/notifications.dart';
import '../data/app_database.dart';
import '../providers.dart';
import '../reading/reading_session_provider.dart';
import 'reading_actions.dart';
import 'series_actions.dart' show confirmDialog;

Future<void> _offerExactAlarms(BuildContext context) async {
  if (await exactAlarmsAllowed() || !context.mounted) return;
  final open = await confirmDialog(
    context,
    title: 'Allow exact alarms',
    message:
    'Without this, Android can delay the check-in alarm by several minutes when the phone is idle. '
        'On the next page, switch on "Alarms & reminders" for Bookmark, then come back.',
    yes: 'Open settings',
  );
  if (open) await openExactAlarmSettings();
}

Future<void> startSession(
    BuildContext context,
    WidgetRef ref,
    MediaItem item,
    ) async {
  final notifier = ref.read(readingSessionProvider.notifier);
  final current = ref.read(readingSessionProvider).session;
  final messenger = ScaffoldMessenger.of(context);

  if (current != null && current.itemId == item.id) return;

  if (current != null) {
    final other = await ref.read(databaseProvider).watchItem(current.itemId).first;
    if (other != null && other.status == Status.inProgress) {
      messenger.showSnackBar(SnackBar(
        content: Text(
          'A session for "${current.title}" is already running. Stop it first.',
        ),
      ));
      return;
    }
    await notifier.end();
  }

  await _offerExactAlarms(context);
  final exact = await exactAlarmsAllowed();
  await notifier.start(item);

  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(
        exact
            ? 'Session started. Check-in alarms will be on time.'
            : 'Session started. Exact alarms are off, so check-ins may arrive late.',
      ),
    ));
}

Future<void> stopSession(
    BuildContext context,
    WidgetRef ref,
    MediaItem item,
    ) async {
  final s = ref.read(readingSessionProvider).session;
  if (s == null || s.itemId != item.id) return;

  final minutes = max(1, minutesBetween(s.startedAt, DateTime.now()));
  final saved = await updateProgressFlow(
    context,
    ref,
    item,
    fixedMinutes: minutes,
  );
  if (saved) await ref.read(readingSessionProvider.notifier).end();
}