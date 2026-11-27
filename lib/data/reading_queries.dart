import 'package:drift/drift.dart';

import 'app_database.dart';

int convertValue(int value, ProgressUnit from, ProgressUnit to, int? pageCount) {
  if (from == to || pageCount == null || pageCount <= 0) return value;
  if (to == ProgressUnit.percent) {
    return (value * 100 / pageCount).round().clamp(0, 100).toInt();
  }
  return (value * pageCount / 100).round().clamp(0, pageCount).toInt();
}

int _pagesOf(int value, ProgressUnit unit, int pageCount) =>
    unit == ProgressUnit.pages ? value : (value * pageCount / 100).round();

extension BookProgress on MediaItem {
  bool get hasPages => (pageCount ?? 0) > 0;

  ProgressUnit get unit => !hasPages
      ? ProgressUnit.percent
      : (progressUnit ?? ProgressUnit.pages);

  int get progressMax => unit == ProgressUnit.pages ? pageCount! : 100;

  int get percentDone => progressMax == 0
      ? 0
      : (currentPage * 100 / progressMax).round().clamp(0, 100).toInt();

  int? get pagesNow {
    if (!hasPages || currentPage == 0) return null;
    return unit == ProgressUnit.pages
        ? currentPage
        : (currentPage * pageCount! / 100).round();
  }
}

extension ReadingQueries on AppDatabase {
  Future<bool> saveProgress(
      int itemId, {
        required ProgressUnit unit,
        required int? pageCount,
        required int value,
        int? minutes,
        DateTime? readAt,
      }) =>
      transaction(() async {
        final item = await (select(mediaItems)
          ..where((t) => t.id.equals(itemId)))
            .getSingle();
        final pc = (pageCount ?? 0) > 0 ? pageCount : null;
        final effective = pc == null ? ProgressUnit.percent : unit;
        final max = effective == ProgressUnit.pages ? pc! : 100;
        final target = value.clamp(0, max).toInt();
        final before = convertValue(item.currentPage, item.unit, effective, pc);

        if (pc != null && !item.hasPages) await _convertPercentLogs(itemId, pc);

        final spent = (minutes ?? 0) > 0 ? minutes : null;
        final forward = target > before;
        if (forward || spent != null) {
          final from = pc == null ? before : _pagesOf(before, effective, pc);
          final to = forward
              ? (pc == null ? target : _pagesOf(target, effective, pc))
              : from;
          await into(readingLogs).insert(ReadingLogsCompanion.insert(
            itemId: itemId,
            readAt: readAt ?? DateTime.now(),
            fromPage: from,
            toPage: to,
            pages: Value(pc == null ? null : to - from),
            minutes: Value(spent),
            inPercent: Value(pc == null),
          ));
        }

        await (update(mediaItems)..where((t) => t.id.equals(itemId))).write(
          MediaItemsCompanion(
            pageCount: Value(pc ?? item.pageCount),
            progressUnit: Value(pc == null ? null : effective),
            currentPage: Value(target),
            status: const Value(Status.inProgress),
            dropReason: const Value(null),
            droppedAtPage: const Value(null),
            lastActivityAt: Value(DateTime.now()),
          ),
        );
        return target >= max;
      });

  Future<void> markBookRead(int itemId, {required bool counted}) =>
      transaction(() async {
        final item = await (select(mediaItems)
          ..where((t) => t.id.equals(itemId)))
            .getSingle();
        final max = item.progressMax;
        final start = item.status == Status.done ? 0 : item.currentPage;

        if (counted && start < max) {
          final pc = item.hasPages ? item.pageCount : null;
          final from = pc == null ? start : _pagesOf(start, item.unit, pc);
          final to = pc == null ? max : _pagesOf(max, item.unit, pc);
          await into(readingLogs).insert(ReadingLogsCompanion.insert(
            itemId: itemId,
            readAt: DateTime.now(),
            fromPage: from,
            toPage: to,
            pages: Value(pc == null ? null : to - from),
            inPercent: Value(pc == null),
          ));
        }

        await markDone(item, counted: counted);
        await (update(mediaItems)..where((t) => t.id.equals(itemId)))
            .write(MediaItemsCompanion(currentPage: Value(max)));
      });

  Future<void> _convertPercentLogs(int itemId, int pageCount) async {
    final rows = await (select(readingLogs)
      ..where((l) => l.itemId.equals(itemId) & l.inPercent.equals(true)))
        .get();
    for (final r in rows) {
      final from = (r.fromPage * pageCount / 100).round();
      final to = (r.toPage * pageCount / 100).round();
      await (update(readingLogs)..where((l) => l.id.equals(r.id))).write(
        ReadingLogsCompanion(
          fromPage: Value(from),
          toPage: Value(to),
          pages: Value(to - from),
          inPercent: const Value(false),
        ),
      );
    }
  }
}