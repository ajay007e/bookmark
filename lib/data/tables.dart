import 'package:drift/drift.dart';

enum MediaType { movie, series, book }

enum Status { want, inProgress, done, dropped }

enum ProgressUnit { pages, percent }

class MediaItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get type => intEnum<MediaType>()();
  TextColumn get externalId => text()();
  TextColumn get title => text()();
  TextColumn get posterUrl => text().nullable()();
  TextColumn get overview => text().nullable()();
  IntColumn get year => integer().nullable()();
  TextColumn get genres => text().withDefault(const Constant(''))();
  IntColumn get status =>
      intEnum<Status>().withDefault(const Constant(0))();
  IntColumn get rating => integer().nullable()();
  IntColumn get runtime => integer().nullable()();
  BoolColumn get ongoing => boolean().nullable()();
  TextColumn get author => text().nullable()();
  IntColumn get pageCount => integer().nullable()();
  IntColumn get currentPage => integer().withDefault(const Constant(0))();
  IntColumn get progressUnit => intEnum<ProgressUnit>().nullable()();
  TextColumn get dropReason => text().nullable()();
  IntColumn get droppedAtPage => integer().nullable()();
  DateTimeColumn get addedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get lastActivityAt =>
      dateTime().withDefault(currentDateAndTime)();

  @override
  List<Set<Column>> get uniqueKeys => [
    {type, externalId},
  ];
}

class Episodes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get seriesId =>
      integer().references(MediaItems, #id, onDelete: KeyAction.cascade)();
  IntColumn get seasonNumber => integer()();
  IntColumn get episodeNumber => integer()();
  TextColumn get title => text().nullable()();
  DateTimeColumn get airDate => dateTime().nullable()();
  IntColumn get runtime => integer().nullable()();
  BoolColumn get watched => boolean().withDefault(const Constant(false))();
  DateTimeColumn get watchedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {seriesId, seasonNumber, episodeNumber},
  ];
}

class WatchLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get itemId =>
      integer().references(MediaItems, #id, onDelete: KeyAction.cascade)();
  IntColumn get episodeId => integer()
      .nullable()
      .references(Episodes, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get watchedAt => dateTime()();
  BoolColumn get counted => boolean().withDefault(const Constant(true))();
  IntColumn get minutes => integer().nullable()();
}

class ReadingLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get itemId =>
      integer().references(MediaItems, #id, onDelete: KeyAction.cascade)();
  DateTimeColumn get readAt => dateTime()();
  IntColumn get fromPage => integer()();
  IntColumn get toPage => integer()();
  IntColumn get pages => integer().nullable()();
  IntColumn get minutes => integer().nullable()();

  // true while the book has no page count: fromPage and toPage are percent
  BoolColumn get inPercent => boolean().withDefault(const Constant(false))();
}

class UserLists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
}

class ListEntries extends Table {
  IntColumn get listId =>
      integer().references(UserLists, #id, onDelete: KeyAction.cascade)();
  IntColumn get itemId =>
      integer().references(MediaItems, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {listId, itemId};
}