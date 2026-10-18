import 'package:drift/drift.dart';

enum MediaType { movie, series, book }

/// One status enum for everything. Labels differ per type, see labels.dart.
enum Status { want, inProgress, done, dropped }

/// Movies, series and books share one table. Book-only fields are nullable.
class MediaItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get type => intEnum<MediaType>()();
  TextColumn get externalId => text()(); // TMDB id or Open Library work key
  TextColumn get title => text()();
  TextColumn get posterUrl => text().nullable()();
  TextColumn get overview => text().nullable()();
  IntColumn get year => integer().nullable()();
  TextColumn get genres => text().withDefault(const Constant(''))();
  IntColumn get status =>
      intEnum<Status>().withDefault(const Constant(0))(); // 0 = want
  IntColumn get rating => integer().nullable()();

  // Book only
  TextColumn get author => text().nullable()();
  IntColumn get pageCount => integer().nullable()();
  IntColumn get currentPage => integer().withDefault(const Constant(0))();
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

/// Episode-level tracking for series.
class Episodes extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get seriesId =>
      integer().references(MediaItems, #id, onDelete: KeyAction.cascade)();
  IntColumn get seasonNumber => integer()();
  IntColumn get episodeNumber => integer()();
  TextColumn get title => text().nullable()();
  DateTimeColumn get airDate => dateTime().nullable()();
  BoolColumn get watched => boolean().withDefault(const Constant(false))();
  DateTimeColumn get watchedAt => dateTime().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
    {seriesId, seasonNumber, episodeNumber},
  ];
}

/// Custom lists and tags (Favorites, Weekend watch, ...).
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