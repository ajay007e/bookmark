import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../data/reading_queries.dart';
import '../providers.dart';
import '../reading/reading_session_provider.dart';
import 'series_actions.dart';
import 'widgets/progress_sheet.dart';

int? _suggestedPages(WidgetRef ref, MediaItem item) =>
    ref.read(bookInfoProvider(item.externalId)).maybeWhen<int?>(
      data: (i) => i.pages,
      orElse: () => null,
    );

Future<ProgressResult?> askProgress(
    BuildContext context,
    WidgetRef ref,
    MediaItem item, {
      required bool starting,
      int? fixedMinutes,
    }) =>
    showProgressSheet(
      context,
      item: item,
      starting: starting,
      suggestedPageCount: _suggestedPages(ref, item),
      fixedMinutes: fixedMinutes,
    );

Future<void> startReading(
    BuildContext context,
    WidgetRef ref,
    MediaItem item,
    ) async {
  final r = await askProgress(context, ref, item, starting: true);
  if (r == null) return;
  await ref.read(databaseProvider).saveProgress(
    item.id,
    unit: r.unit,
    pageCount: r.pageCount,
    value: r.value,
  );
}

Future<bool> updateProgressFlow(
    BuildContext context,
    WidgetRef ref,
    MediaItem item, {
      int? fixedMinutes,
    }) async {
  final db = ref.read(databaseProvider);
  final r = await askProgress(
    context,
    ref,
    item,
    starting: false,
    fixedMinutes: fixedMinutes,
  );
  if (r == null) return false;

  final atEnd = await db.saveProgress(
    item.id,
    unit: r.unit,
    pageCount: r.pageCount,
    value: r.value,
    minutes: r.minutes,
  );

  if (atEnd && context.mounted) {
    final finished = await confirmDialog(
      context,
      title: 'Finished?',
      message: 'You reached the end of "${item.title}". Mark it as read now?',
      yes: 'Mark as read',
    );
    if (finished) {
      await db.markBookRead(item.id, counted: true);
      final s = ref.read(readingSessionProvider).session;
      if (s != null && s.itemId == item.id) {
        await ref.read(readingSessionProvider.notifier).end();
      }
    }
  }
  return true;
}