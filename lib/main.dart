import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'background/background_worker.dart';
import 'background/notifications.dart';
import 'data/app_database.dart';
import 'data/reading_queries.dart';
import 'providers.dart';
import 'reading/reading_session_provider.dart';
import 'router.dart';
import 'settings/accent_provider.dart';
import 'settings/theme_provider.dart';
import 'ui/check_in_dialog.dart';
import 'ui/series_actions.dart' show confirmDialog;
import 'ui/session_actions.dart';
import 'ui/widgets/progress_sheet.dart';

WidgetRef? _appRef;

void openSeriesFromPayload(String? payload) {
  final id = int.tryParse(payload ?? '');
  if (id == null) return;
  appRouter.push('/item/$id');
}

void handleNotificationPayload(String? payload) {
  if (payload == 'stop') {
    _stopFromNotification();
    return;
  }
  openSeriesFromPayload(payload);
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initNotifications(onTap: handleNotificationPayload);
  await requestNotificationPermission();
  await initBackgroundWork();

  final launchPayload = await notificationLaunchPayload();

  runApp(const ProviderScope(child: BookmarkApp()));

  if (launchPayload != null) {
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => handleNotificationPayload(launchPayload),
    );
  }
}

bool _checkInOpen = false;
bool _pendingOpen = false;

Future<BuildContext?> _readyContext() async {
  for (var i = 0; i < 20; i++) {
    final ctx = appRouter.routerDelegate.navigatorKey.currentState?.overlay?.context;
    if (ctx != null) return ctx;
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
  return null;
}

Future<void> _stopFromNotification() async {
  ReadingSession? session;
  for (var i = 0; i < 20; i++) {
    final ref = _appRef;
    session = ref?.read(readingSessionProvider).session;
    if (session != null) break;
    await Future<void>.delayed(const Duration(milliseconds: 250));
  }
  final ref = _appRef;
  if (ref == null || session == null) return;

  final item = await ref.read(databaseProvider).watchItem(session.itemId).first;
  if (item == null) return;
  final ctx = await _readyContext();
  if (ctx == null || !ctx.mounted) return;
  await stopSession(ctx, ref, item);
}

void _onSession(
    WidgetRef ref,
    ReadingSessionState? previous,
    ReadingSessionState next,
    ) {
  final newCheckIn = next.checkInDue &&
      !(previous?.checkInDue ?? false) &&
      next.session != null;
  if (newCheckIn && !_checkInOpen) {
    _runCheckIn(ref, next.session!);
  } else if (next.pending != null && !_checkInOpen) {
    _showPending(ref);
  }
}

Future<void> _runCheckIn(WidgetRef ref, ReadingSession session) async {
  final ctx = await _readyContext();
  if (ctx == null || !ctx.mounted) return;

  _checkInOpen = true;
  bool stillReading;
  try {
    stillReading = await showCheckInDialog(
      ctx,
      session.deadline,
      session.answerWithin,
    );
  } finally {
    _checkInOpen = false;
  }
  await cancelCheckInAlert();

  final notifier = ref.read(readingSessionProvider.notifier);
  if (stillReading) {
    await notifier.confirm();
  } else {
    await notifier.autoStop();
  }
  await _showPending(ref);
}

Future<void> _showPending(WidgetRef ref) async {
  if (_pendingOpen) return;
  _pendingOpen = true;
  try {
    final notifier = ref.read(readingSessionProvider.notifier);
    final pending = ref.read(readingSessionProvider).pending;
    if (pending == null) return;

    final ctx = await _readyContext();
    if (ctx == null || !ctx.mounted) return;

    final db = ref.read(databaseProvider);
    final item = await db.watchItem(pending.itemId).first;
    if (item == null || item.status != Status.inProgress) {
      await notifier.clearPending();
      return;
    }
    if (!ctx.mounted) return;

    ProgressResult? result;
    do {
      result = await showProgressSheet(
        ctx,
        item: item,
        starting: false,
        fixedMinutes: pending.minutes >= 1 ? pending.minutes : null,
        mandatory: true,
      );
    } while (result == null && ctx.mounted);
    if (result == null) return;

    final atEnd = await db.saveProgress(
      item.id,
      unit: result.unit,
      pageCount: result.pageCount,
      value: result.value,
      minutes: result.minutes,
      readAt: pending.endedAt,
    );
    await notifier.clearPending();

    if (atEnd && ctx.mounted) {
      final finished = await confirmDialog(
        ctx,
        title: 'Finished?',
        message: 'You reached the end of "${item.title}". Mark it as read now?',
        yes: 'Mark as read',
      );
      if (finished) await db.markBookRead(item.id, counted: true);
    }
  } finally {
    _pendingOpen = false;
  }
}

class BookmarkApp extends ConsumerWidget {
  const BookmarkApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    _appRef = ref;
    final themeMode = ref.watch(themeModeProvider);
    final seed = ref.watch(accentProvider).color;

    ref.listen<ReadingSessionState>(
      readingSessionProvider,
          (previous, next) => _onSession(ref, previous, next),
    );

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