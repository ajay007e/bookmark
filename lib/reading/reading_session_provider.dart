import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../background/notifications.dart';
import '../data/app_database.dart';
import '../providers.dart';

const checkInEvery = Duration(seconds: 30);
const answerWithin = Duration(seconds: 15);

const _sessionKey = 'readingSession';
const _pendingKey = 'readingPendingUpdate';

int minutesBetween(DateTime from, DateTime to) =>
    (to.difference(from).inSeconds / 60).round();

class ReadingSession {
  const ReadingSession({
    required this.itemId,
    required this.title,
    required this.startedAt,
    required this.lastConfirmedAt,
  });

  final int itemId;
  final String title;
  final DateTime startedAt;
  final DateTime lastConfirmedAt;

  DateTime get checkInAt => lastConfirmedAt.add(checkInEvery);
  DateTime get deadline => checkInAt.add(answerWithin);

  ReadingSession confirmedAt(DateTime time) => ReadingSession(
    itemId: itemId,
    title: title,
    startedAt: startedAt,
    lastConfirmedAt: time,
  );

  String encode() => jsonEncode({
    'itemId': itemId,
    'title': title,
    'startedAt': startedAt.millisecondsSinceEpoch,
    'lastConfirmedAt': lastConfirmedAt.millisecondsSinceEpoch,
  });

  static ReadingSession? decode(String? raw) {
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return ReadingSession(
        itemId: m['itemId'] as int,
        title: m['title'] as String,
        startedAt: DateTime.fromMillisecondsSinceEpoch(m['startedAt'] as int),
        lastConfirmedAt:
        DateTime.fromMillisecondsSinceEpoch(m['lastConfirmedAt'] as int),
      );
    } catch (_) {
      return null;
    }
  }
}

class PendingUpdate {
  const PendingUpdate({
    required this.itemId,
    required this.title,
    required this.minutes,
  });

  final int itemId;
  final String title;
  final int minutes;

  String encode() => jsonEncode({
    'itemId': itemId,
    'title': title,
    'minutes': minutes,
  });

  static PendingUpdate? decode(String? raw) {
    if (raw == null) return null;
    try {
      final m = jsonDecode(raw) as Map<String, dynamic>;
      return PendingUpdate(
        itemId: m['itemId'] as int,
        title: m['title'] as String,
        minutes: m['minutes'] as int,
      );
    } catch (_) {
      return null;
    }
  }
}

class ReadingSessionState {
  const ReadingSessionState({
    this.session,
    this.checkInDue = false,
    this.pending,
  });

  final ReadingSession? session;
  final bool checkInDue;
  final PendingUpdate? pending;
}

class ReadingSessionNotifier extends Notifier<ReadingSessionState> {
  final _prefs = SharedPreferencesAsync();
  Timer? _timer;

  @override
  ReadingSessionState build() {
    final lifecycle = AppLifecycleListener(onResume: _resync);
    ref.onDispose(() {
      _timer?.cancel();
      lifecycle.dispose();
    });
    _load();
    return const ReadingSessionState();
  }

  Future<void> _load() async {
    final saved = ReadingSession.decode(await _prefs.getString(_sessionKey));
    final pending = PendingUpdate.decode(await _prefs.getString(_pendingKey));
    state = ReadingSessionState(session: saved, pending: pending);
    if (saved == null) return;
    await _resync();
  }

  Future<void> _resync() async {
    final s = state.session;
    if (s != null) {
      await showSessionNotification(
        itemId: s.itemId,
        title: s.title,
        startedAt: s.startedAt,
      );
      await scheduleCheckIn(
        title: s.title,
        at: s.checkInAt,
        deadline: s.deadline,
      );
    }
    await _check();
  }

  void _arm() {
    _timer?.cancel();
    _timer = null;
    final s = state.session;
    if (s == null) return;
    final target = state.checkInDue ? s.deadline : s.checkInAt;
    var wait = target.difference(DateTime.now());
    if (wait < const Duration(milliseconds: 200)) {
      wait = const Duration(milliseconds: 200);
    }
    _timer = Timer(wait, _check);
  }

  Future<bool> _stillReading(int itemId) async {
    final item = await ref.read(databaseProvider).watchItem(itemId).first;
    return item != null && item.status == Status.inProgress;
  }

  Future<void> _check() async {
    final s = state.session;
    if (s == null) return;
    final now = DateTime.now();

    if (!now.isBefore(s.deadline)) {
      await autoStop();
      return;
    }

    if (!now.isBefore(s.checkInAt) && !state.checkInDue) {
      debugPrint(
        '[Session] check-in due ${now.difference(s.checkInAt).inMilliseconds} ms '
            'after its scheduled time',
      );
      final reading = await _stillReading(s.itemId);
      final current = state.session;
      if (current == null || current.itemId != s.itemId) return;
      if (!reading) {
        await end();
        return;
      }
      state = ReadingSessionState(
        session: current,
        checkInDue: true,
        pending: state.pending,
      );
    }
    _arm();
  }

  Future<void> start(MediaItem item) async {
    final now = DateTime.now();
    final s = ReadingSession(
      itemId: item.id,
      title: item.title,
      startedAt: now,
      lastConfirmedAt: now,
    );
    state = ReadingSessionState(session: s, pending: state.pending);
    await _prefs.setString(_sessionKey, s.encode());
    _arm();
    await showSessionNotification(
      itemId: s.itemId,
      title: s.title,
      startedAt: s.startedAt,
    );
    await scheduleCheckIn(title: s.title, at: s.checkInAt, deadline: s.deadline);
  }

  Future<void> confirm() async {
    final s = state.session;
    if (s == null) return;
    final next = s.confirmedAt(DateTime.now());
    state = ReadingSessionState(session: next, pending: state.pending);
    await _prefs.setString(_sessionKey, next.encode());
    _arm();
    await scheduleCheckIn(
      title: next.title,
      at: next.checkInAt,
      deadline: next.deadline,
    );
  }

  Future<void> autoStop() async {
    final s = state.session;
    if (s == null) return;
    final pending = PendingUpdate(
      itemId: s.itemId,
      title: s.title,
      minutes: minutesBetween(s.startedAt, s.lastConfirmedAt),
    );
    _timer?.cancel();
    _timer = null;
    state = ReadingSessionState(pending: pending);
    await _prefs.remove(_sessionKey);
    await _prefs.setString(_pendingKey, pending.encode());
    await cancelSessionNotification();
    await cancelCheckInAlert();
  }

  Future<void> clearPending() async {
    state = ReadingSessionState(
      session: state.session,
      checkInDue: state.checkInDue,
    );
    await _prefs.remove(_pendingKey);
  }

  Future<void> end() async {
    _timer?.cancel();
    _timer = null;
    state = ReadingSessionState(pending: state.pending);
    await _prefs.remove(_sessionKey);
    await cancelSessionNotification();
    await cancelCheckIn();
  }
}

final readingSessionProvider =
NotifierProvider<ReadingSessionNotifier, ReadingSessionState>(
  ReadingSessionNotifier.new,
);