// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MediaItemsTable extends MediaItems
    with TableInfo<$MediaItemsTable, MediaItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MediaItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MediaType, int> type =
      GeneratedColumn<int>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: true,
      ).withConverter<MediaType>($MediaItemsTable.$convertertype);
  static const VerificationMeta _externalIdMeta = const VerificationMeta(
    'externalId',
  );
  @override
  late final GeneratedColumn<String> externalId = GeneratedColumn<String>(
    'external_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _posterUrlMeta = const VerificationMeta(
    'posterUrl',
  );
  @override
  late final GeneratedColumn<String> posterUrl = GeneratedColumn<String>(
    'poster_url',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _overviewMeta = const VerificationMeta(
    'overview',
  );
  @override
  late final GeneratedColumn<String> overview = GeneratedColumn<String>(
    'overview',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genresMeta = const VerificationMeta('genres');
  @override
  late final GeneratedColumn<String> genres = GeneratedColumn<String>(
    'genres',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Status, int> status =
      GeneratedColumn<int>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<Status>($MediaItemsTable.$converterstatus);
  static const VerificationMeta _ratingMeta = const VerificationMeta('rating');
  @override
  late final GeneratedColumn<int> rating = GeneratedColumn<int>(
    'rating',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageCountMeta = const VerificationMeta(
    'pageCount',
  );
  @override
  late final GeneratedColumn<int> pageCount = GeneratedColumn<int>(
    'page_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentPageMeta = const VerificationMeta(
    'currentPage',
  );
  @override
  late final GeneratedColumn<int> currentPage = GeneratedColumn<int>(
    'current_page',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dropReasonMeta = const VerificationMeta(
    'dropReason',
  );
  @override
  late final GeneratedColumn<String> dropReason = GeneratedColumn<String>(
    'drop_reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _droppedAtPageMeta = const VerificationMeta(
    'droppedAtPage',
  );
  @override
  late final GeneratedColumn<int> droppedAtPage = GeneratedColumn<int>(
    'dropped_at_page',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastActivityAtMeta = const VerificationMeta(
    'lastActivityAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastActivityAt =
      GeneratedColumn<DateTime>(
        'last_activity_at',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    externalId,
    title,
    posterUrl,
    overview,
    year,
    genres,
    status,
    rating,
    author,
    pageCount,
    currentPage,
    dropReason,
    droppedAtPage,
    addedAt,
    lastActivityAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'media_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<MediaItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('external_id')) {
      context.handle(
        _externalIdMeta,
        externalId.isAcceptableOrUnknown(data['external_id']!, _externalIdMeta),
      );
    } else if (isInserting) {
      context.missing(_externalIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('poster_url')) {
      context.handle(
        _posterUrlMeta,
        posterUrl.isAcceptableOrUnknown(data['poster_url']!, _posterUrlMeta),
      );
    }
    if (data.containsKey('overview')) {
      context.handle(
        _overviewMeta,
        overview.isAcceptableOrUnknown(data['overview']!, _overviewMeta),
      );
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('genres')) {
      context.handle(
        _genresMeta,
        genres.isAcceptableOrUnknown(data['genres']!, _genresMeta),
      );
    }
    if (data.containsKey('rating')) {
      context.handle(
        _ratingMeta,
        rating.isAcceptableOrUnknown(data['rating']!, _ratingMeta),
      );
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('page_count')) {
      context.handle(
        _pageCountMeta,
        pageCount.isAcceptableOrUnknown(data['page_count']!, _pageCountMeta),
      );
    }
    if (data.containsKey('current_page')) {
      context.handle(
        _currentPageMeta,
        currentPage.isAcceptableOrUnknown(
          data['current_page']!,
          _currentPageMeta,
        ),
      );
    }
    if (data.containsKey('drop_reason')) {
      context.handle(
        _dropReasonMeta,
        dropReason.isAcceptableOrUnknown(data['drop_reason']!, _dropReasonMeta),
      );
    }
    if (data.containsKey('dropped_at_page')) {
      context.handle(
        _droppedAtPageMeta,
        droppedAtPage.isAcceptableOrUnknown(
          data['dropped_at_page']!,
          _droppedAtPageMeta,
        ),
      );
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    }
    if (data.containsKey('last_activity_at')) {
      context.handle(
        _lastActivityAtMeta,
        lastActivityAt.isAcceptableOrUnknown(
          data['last_activity_at']!,
          _lastActivityAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {type, externalId},
  ];
  @override
  MediaItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MediaItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      type: $MediaItemsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}type'],
        )!,
      ),
      externalId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}external_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      posterUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}poster_url'],
      ),
      overview: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}overview'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      genres: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genres'],
      )!,
      status: $MediaItemsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}status'],
        )!,
      ),
      rating: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rating'],
      ),
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      ),
      pageCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_count'],
      ),
      currentPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_page'],
      )!,
      dropReason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}drop_reason'],
      ),
      droppedAtPage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}dropped_at_page'],
      ),
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
      lastActivityAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_activity_at'],
      )!,
    );
  }

  @override
  $MediaItemsTable createAlias(String alias) {
    return $MediaItemsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MediaType, int, int> $convertertype =
      const EnumIndexConverter<MediaType>(MediaType.values);
  static JsonTypeConverter2<Status, int, int> $converterstatus =
      const EnumIndexConverter<Status>(Status.values);
}

class MediaItem extends DataClass implements Insertable<MediaItem> {
  final int id;
  final MediaType type;
  final String externalId;
  final String title;
  final String? posterUrl;
  final String? overview;
  final int? year;
  final String genres;
  final Status status;
  final int? rating;
  final String? author;
  final int? pageCount;
  final int currentPage;
  final String? dropReason;
  final int? droppedAtPage;
  final DateTime addedAt;
  final DateTime lastActivityAt;
  const MediaItem({
    required this.id,
    required this.type,
    required this.externalId,
    required this.title,
    this.posterUrl,
    this.overview,
    this.year,
    required this.genres,
    required this.status,
    this.rating,
    this.author,
    this.pageCount,
    required this.currentPage,
    this.dropReason,
    this.droppedAtPage,
    required this.addedAt,
    required this.lastActivityAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    {
      map['type'] = Variable<int>($MediaItemsTable.$convertertype.toSql(type));
    }
    map['external_id'] = Variable<String>(externalId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || posterUrl != null) {
      map['poster_url'] = Variable<String>(posterUrl);
    }
    if (!nullToAbsent || overview != null) {
      map['overview'] = Variable<String>(overview);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    map['genres'] = Variable<String>(genres);
    {
      map['status'] = Variable<int>(
        $MediaItemsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || rating != null) {
      map['rating'] = Variable<int>(rating);
    }
    if (!nullToAbsent || author != null) {
      map['author'] = Variable<String>(author);
    }
    if (!nullToAbsent || pageCount != null) {
      map['page_count'] = Variable<int>(pageCount);
    }
    map['current_page'] = Variable<int>(currentPage);
    if (!nullToAbsent || dropReason != null) {
      map['drop_reason'] = Variable<String>(dropReason);
    }
    if (!nullToAbsent || droppedAtPage != null) {
      map['dropped_at_page'] = Variable<int>(droppedAtPage);
    }
    map['added_at'] = Variable<DateTime>(addedAt);
    map['last_activity_at'] = Variable<DateTime>(lastActivityAt);
    return map;
  }

  MediaItemsCompanion toCompanion(bool nullToAbsent) {
    return MediaItemsCompanion(
      id: Value(id),
      type: Value(type),
      externalId: Value(externalId),
      title: Value(title),
      posterUrl: posterUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(posterUrl),
      overview: overview == null && nullToAbsent
          ? const Value.absent()
          : Value(overview),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      genres: Value(genres),
      status: Value(status),
      rating: rating == null && nullToAbsent
          ? const Value.absent()
          : Value(rating),
      author: author == null && nullToAbsent
          ? const Value.absent()
          : Value(author),
      pageCount: pageCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pageCount),
      currentPage: Value(currentPage),
      dropReason: dropReason == null && nullToAbsent
          ? const Value.absent()
          : Value(dropReason),
      droppedAtPage: droppedAtPage == null && nullToAbsent
          ? const Value.absent()
          : Value(droppedAtPage),
      addedAt: Value(addedAt),
      lastActivityAt: Value(lastActivityAt),
    );
  }

  factory MediaItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MediaItem(
      id: serializer.fromJson<int>(json['id']),
      type: $MediaItemsTable.$convertertype.fromJson(
        serializer.fromJson<int>(json['type']),
      ),
      externalId: serializer.fromJson<String>(json['externalId']),
      title: serializer.fromJson<String>(json['title']),
      posterUrl: serializer.fromJson<String?>(json['posterUrl']),
      overview: serializer.fromJson<String?>(json['overview']),
      year: serializer.fromJson<int?>(json['year']),
      genres: serializer.fromJson<String>(json['genres']),
      status: $MediaItemsTable.$converterstatus.fromJson(
        serializer.fromJson<int>(json['status']),
      ),
      rating: serializer.fromJson<int?>(json['rating']),
      author: serializer.fromJson<String?>(json['author']),
      pageCount: serializer.fromJson<int?>(json['pageCount']),
      currentPage: serializer.fromJson<int>(json['currentPage']),
      dropReason: serializer.fromJson<String?>(json['dropReason']),
      droppedAtPage: serializer.fromJson<int?>(json['droppedAtPage']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
      lastActivityAt: serializer.fromJson<DateTime>(json['lastActivityAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'type': serializer.toJson<int>(
        $MediaItemsTable.$convertertype.toJson(type),
      ),
      'externalId': serializer.toJson<String>(externalId),
      'title': serializer.toJson<String>(title),
      'posterUrl': serializer.toJson<String?>(posterUrl),
      'overview': serializer.toJson<String?>(overview),
      'year': serializer.toJson<int?>(year),
      'genres': serializer.toJson<String>(genres),
      'status': serializer.toJson<int>(
        $MediaItemsTable.$converterstatus.toJson(status),
      ),
      'rating': serializer.toJson<int?>(rating),
      'author': serializer.toJson<String?>(author),
      'pageCount': serializer.toJson<int?>(pageCount),
      'currentPage': serializer.toJson<int>(currentPage),
      'dropReason': serializer.toJson<String?>(dropReason),
      'droppedAtPage': serializer.toJson<int?>(droppedAtPage),
      'addedAt': serializer.toJson<DateTime>(addedAt),
      'lastActivityAt': serializer.toJson<DateTime>(lastActivityAt),
    };
  }

  MediaItem copyWith({
    int? id,
    MediaType? type,
    String? externalId,
    String? title,
    Value<String?> posterUrl = const Value.absent(),
    Value<String?> overview = const Value.absent(),
    Value<int?> year = const Value.absent(),
    String? genres,
    Status? status,
    Value<int?> rating = const Value.absent(),
    Value<String?> author = const Value.absent(),
    Value<int?> pageCount = const Value.absent(),
    int? currentPage,
    Value<String?> dropReason = const Value.absent(),
    Value<int?> droppedAtPage = const Value.absent(),
    DateTime? addedAt,
    DateTime? lastActivityAt,
  }) => MediaItem(
    id: id ?? this.id,
    type: type ?? this.type,
    externalId: externalId ?? this.externalId,
    title: title ?? this.title,
    posterUrl: posterUrl.present ? posterUrl.value : this.posterUrl,
    overview: overview.present ? overview.value : this.overview,
    year: year.present ? year.value : this.year,
    genres: genres ?? this.genres,
    status: status ?? this.status,
    rating: rating.present ? rating.value : this.rating,
    author: author.present ? author.value : this.author,
    pageCount: pageCount.present ? pageCount.value : this.pageCount,
    currentPage: currentPage ?? this.currentPage,
    dropReason: dropReason.present ? dropReason.value : this.dropReason,
    droppedAtPage: droppedAtPage.present
        ? droppedAtPage.value
        : this.droppedAtPage,
    addedAt: addedAt ?? this.addedAt,
    lastActivityAt: lastActivityAt ?? this.lastActivityAt,
  );
  MediaItem copyWithCompanion(MediaItemsCompanion data) {
    return MediaItem(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      externalId: data.externalId.present
          ? data.externalId.value
          : this.externalId,
      title: data.title.present ? data.title.value : this.title,
      posterUrl: data.posterUrl.present ? data.posterUrl.value : this.posterUrl,
      overview: data.overview.present ? data.overview.value : this.overview,
      year: data.year.present ? data.year.value : this.year,
      genres: data.genres.present ? data.genres.value : this.genres,
      status: data.status.present ? data.status.value : this.status,
      rating: data.rating.present ? data.rating.value : this.rating,
      author: data.author.present ? data.author.value : this.author,
      pageCount: data.pageCount.present ? data.pageCount.value : this.pageCount,
      currentPage: data.currentPage.present
          ? data.currentPage.value
          : this.currentPage,
      dropReason: data.dropReason.present
          ? data.dropReason.value
          : this.dropReason,
      droppedAtPage: data.droppedAtPage.present
          ? data.droppedAtPage.value
          : this.droppedAtPage,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
      lastActivityAt: data.lastActivityAt.present
          ? data.lastActivityAt.value
          : this.lastActivityAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MediaItem(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('externalId: $externalId, ')
          ..write('title: $title, ')
          ..write('posterUrl: $posterUrl, ')
          ..write('overview: $overview, ')
          ..write('year: $year, ')
          ..write('genres: $genres, ')
          ..write('status: $status, ')
          ..write('rating: $rating, ')
          ..write('author: $author, ')
          ..write('pageCount: $pageCount, ')
          ..write('currentPage: $currentPage, ')
          ..write('dropReason: $dropReason, ')
          ..write('droppedAtPage: $droppedAtPage, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastActivityAt: $lastActivityAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    externalId,
    title,
    posterUrl,
    overview,
    year,
    genres,
    status,
    rating,
    author,
    pageCount,
    currentPage,
    dropReason,
    droppedAtPage,
    addedAt,
    lastActivityAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MediaItem &&
          other.id == this.id &&
          other.type == this.type &&
          other.externalId == this.externalId &&
          other.title == this.title &&
          other.posterUrl == this.posterUrl &&
          other.overview == this.overview &&
          other.year == this.year &&
          other.genres == this.genres &&
          other.status == this.status &&
          other.rating == this.rating &&
          other.author == this.author &&
          other.pageCount == this.pageCount &&
          other.currentPage == this.currentPage &&
          other.dropReason == this.dropReason &&
          other.droppedAtPage == this.droppedAtPage &&
          other.addedAt == this.addedAt &&
          other.lastActivityAt == this.lastActivityAt);
}

class MediaItemsCompanion extends UpdateCompanion<MediaItem> {
  final Value<int> id;
  final Value<MediaType> type;
  final Value<String> externalId;
  final Value<String> title;
  final Value<String?> posterUrl;
  final Value<String?> overview;
  final Value<int?> year;
  final Value<String> genres;
  final Value<Status> status;
  final Value<int?> rating;
  final Value<String?> author;
  final Value<int?> pageCount;
  final Value<int> currentPage;
  final Value<String?> dropReason;
  final Value<int?> droppedAtPage;
  final Value<DateTime> addedAt;
  final Value<DateTime> lastActivityAt;
  const MediaItemsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.externalId = const Value.absent(),
    this.title = const Value.absent(),
    this.posterUrl = const Value.absent(),
    this.overview = const Value.absent(),
    this.year = const Value.absent(),
    this.genres = const Value.absent(),
    this.status = const Value.absent(),
    this.rating = const Value.absent(),
    this.author = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.dropReason = const Value.absent(),
    this.droppedAtPage = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.lastActivityAt = const Value.absent(),
  });
  MediaItemsCompanion.insert({
    this.id = const Value.absent(),
    required MediaType type,
    required String externalId,
    required String title,
    this.posterUrl = const Value.absent(),
    this.overview = const Value.absent(),
    this.year = const Value.absent(),
    this.genres = const Value.absent(),
    this.status = const Value.absent(),
    this.rating = const Value.absent(),
    this.author = const Value.absent(),
    this.pageCount = const Value.absent(),
    this.currentPage = const Value.absent(),
    this.dropReason = const Value.absent(),
    this.droppedAtPage = const Value.absent(),
    this.addedAt = const Value.absent(),
    this.lastActivityAt = const Value.absent(),
  }) : type = Value(type),
       externalId = Value(externalId),
       title = Value(title);
  static Insertable<MediaItem> custom({
    Expression<int>? id,
    Expression<int>? type,
    Expression<String>? externalId,
    Expression<String>? title,
    Expression<String>? posterUrl,
    Expression<String>? overview,
    Expression<int>? year,
    Expression<String>? genres,
    Expression<int>? status,
    Expression<int>? rating,
    Expression<String>? author,
    Expression<int>? pageCount,
    Expression<int>? currentPage,
    Expression<String>? dropReason,
    Expression<int>? droppedAtPage,
    Expression<DateTime>? addedAt,
    Expression<DateTime>? lastActivityAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (externalId != null) 'external_id': externalId,
      if (title != null) 'title': title,
      if (posterUrl != null) 'poster_url': posterUrl,
      if (overview != null) 'overview': overview,
      if (year != null) 'year': year,
      if (genres != null) 'genres': genres,
      if (status != null) 'status': status,
      if (rating != null) 'rating': rating,
      if (author != null) 'author': author,
      if (pageCount != null) 'page_count': pageCount,
      if (currentPage != null) 'current_page': currentPage,
      if (dropReason != null) 'drop_reason': dropReason,
      if (droppedAtPage != null) 'dropped_at_page': droppedAtPage,
      if (addedAt != null) 'added_at': addedAt,
      if (lastActivityAt != null) 'last_activity_at': lastActivityAt,
    });
  }

  MediaItemsCompanion copyWith({
    Value<int>? id,
    Value<MediaType>? type,
    Value<String>? externalId,
    Value<String>? title,
    Value<String?>? posterUrl,
    Value<String?>? overview,
    Value<int?>? year,
    Value<String>? genres,
    Value<Status>? status,
    Value<int?>? rating,
    Value<String?>? author,
    Value<int?>? pageCount,
    Value<int>? currentPage,
    Value<String?>? dropReason,
    Value<int?>? droppedAtPage,
    Value<DateTime>? addedAt,
    Value<DateTime>? lastActivityAt,
  }) {
    return MediaItemsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      externalId: externalId ?? this.externalId,
      title: title ?? this.title,
      posterUrl: posterUrl ?? this.posterUrl,
      overview: overview ?? this.overview,
      year: year ?? this.year,
      genres: genres ?? this.genres,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      author: author ?? this.author,
      pageCount: pageCount ?? this.pageCount,
      currentPage: currentPage ?? this.currentPage,
      dropReason: dropReason ?? this.dropReason,
      droppedAtPage: droppedAtPage ?? this.droppedAtPage,
      addedAt: addedAt ?? this.addedAt,
      lastActivityAt: lastActivityAt ?? this.lastActivityAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<int>(
        $MediaItemsTable.$convertertype.toSql(type.value),
      );
    }
    if (externalId.present) {
      map['external_id'] = Variable<String>(externalId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (posterUrl.present) {
      map['poster_url'] = Variable<String>(posterUrl.value);
    }
    if (overview.present) {
      map['overview'] = Variable<String>(overview.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (genres.present) {
      map['genres'] = Variable<String>(genres.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(
        $MediaItemsTable.$converterstatus.toSql(status.value),
      );
    }
    if (rating.present) {
      map['rating'] = Variable<int>(rating.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (pageCount.present) {
      map['page_count'] = Variable<int>(pageCount.value);
    }
    if (currentPage.present) {
      map['current_page'] = Variable<int>(currentPage.value);
    }
    if (dropReason.present) {
      map['drop_reason'] = Variable<String>(dropReason.value);
    }
    if (droppedAtPage.present) {
      map['dropped_at_page'] = Variable<int>(droppedAtPage.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    if (lastActivityAt.present) {
      map['last_activity_at'] = Variable<DateTime>(lastActivityAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MediaItemsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('externalId: $externalId, ')
          ..write('title: $title, ')
          ..write('posterUrl: $posterUrl, ')
          ..write('overview: $overview, ')
          ..write('year: $year, ')
          ..write('genres: $genres, ')
          ..write('status: $status, ')
          ..write('rating: $rating, ')
          ..write('author: $author, ')
          ..write('pageCount: $pageCount, ')
          ..write('currentPage: $currentPage, ')
          ..write('dropReason: $dropReason, ')
          ..write('droppedAtPage: $droppedAtPage, ')
          ..write('addedAt: $addedAt, ')
          ..write('lastActivityAt: $lastActivityAt')
          ..write(')'))
        .toString();
  }
}

class $EpisodesTable extends Episodes with TableInfo<$EpisodesTable, Episode> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpisodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _seriesIdMeta = const VerificationMeta(
    'seriesId',
  );
  @override
  late final GeneratedColumn<int> seriesId = GeneratedColumn<int>(
    'series_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES media_items (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _seasonNumberMeta = const VerificationMeta(
    'seasonNumber',
  );
  @override
  late final GeneratedColumn<int> seasonNumber = GeneratedColumn<int>(
    'season_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _episodeNumberMeta = const VerificationMeta(
    'episodeNumber',
  );
  @override
  late final GeneratedColumn<int> episodeNumber = GeneratedColumn<int>(
    'episode_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _airDateMeta = const VerificationMeta(
    'airDate',
  );
  @override
  late final GeneratedColumn<DateTime> airDate = GeneratedColumn<DateTime>(
    'air_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _watchedMeta = const VerificationMeta(
    'watched',
  );
  @override
  late final GeneratedColumn<bool> watched = GeneratedColumn<bool>(
    'watched',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("watched" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _watchedAtMeta = const VerificationMeta(
    'watchedAt',
  );
  @override
  late final GeneratedColumn<DateTime> watchedAt = GeneratedColumn<DateTime>(
    'watched_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    seriesId,
    seasonNumber,
    episodeNumber,
    title,
    airDate,
    watched,
    watchedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'episodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Episode> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('series_id')) {
      context.handle(
        _seriesIdMeta,
        seriesId.isAcceptableOrUnknown(data['series_id']!, _seriesIdMeta),
      );
    } else if (isInserting) {
      context.missing(_seriesIdMeta);
    }
    if (data.containsKey('season_number')) {
      context.handle(
        _seasonNumberMeta,
        seasonNumber.isAcceptableOrUnknown(
          data['season_number']!,
          _seasonNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_seasonNumberMeta);
    }
    if (data.containsKey('episode_number')) {
      context.handle(
        _episodeNumberMeta,
        episodeNumber.isAcceptableOrUnknown(
          data['episode_number']!,
          _episodeNumberMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_episodeNumberMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('air_date')) {
      context.handle(
        _airDateMeta,
        airDate.isAcceptableOrUnknown(data['air_date']!, _airDateMeta),
      );
    }
    if (data.containsKey('watched')) {
      context.handle(
        _watchedMeta,
        watched.isAcceptableOrUnknown(data['watched']!, _watchedMeta),
      );
    }
    if (data.containsKey('watched_at')) {
      context.handle(
        _watchedAtMeta,
        watchedAt.isAcceptableOrUnknown(data['watched_at']!, _watchedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {seriesId, seasonNumber, episodeNumber},
  ];
  @override
  Episode map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Episode(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      seriesId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}series_id'],
      )!,
      seasonNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}season_number'],
      )!,
      episodeNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_number'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      ),
      airDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}air_date'],
      ),
      watched: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}watched'],
      )!,
      watchedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}watched_at'],
      ),
    );
  }

  @override
  $EpisodesTable createAlias(String alias) {
    return $EpisodesTable(attachedDatabase, alias);
  }
}

class Episode extends DataClass implements Insertable<Episode> {
  final int id;
  final int seriesId;
  final int seasonNumber;
  final int episodeNumber;
  final String? title;
  final DateTime? airDate;
  final bool watched;
  final DateTime? watchedAt;
  const Episode({
    required this.id,
    required this.seriesId,
    required this.seasonNumber,
    required this.episodeNumber,
    this.title,
    this.airDate,
    required this.watched,
    this.watchedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['series_id'] = Variable<int>(seriesId);
    map['season_number'] = Variable<int>(seasonNumber);
    map['episode_number'] = Variable<int>(episodeNumber);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    if (!nullToAbsent || airDate != null) {
      map['air_date'] = Variable<DateTime>(airDate);
    }
    map['watched'] = Variable<bool>(watched);
    if (!nullToAbsent || watchedAt != null) {
      map['watched_at'] = Variable<DateTime>(watchedAt);
    }
    return map;
  }

  EpisodesCompanion toCompanion(bool nullToAbsent) {
    return EpisodesCompanion(
      id: Value(id),
      seriesId: Value(seriesId),
      seasonNumber: Value(seasonNumber),
      episodeNumber: Value(episodeNumber),
      title: title == null && nullToAbsent
          ? const Value.absent()
          : Value(title),
      airDate: airDate == null && nullToAbsent
          ? const Value.absent()
          : Value(airDate),
      watched: Value(watched),
      watchedAt: watchedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(watchedAt),
    );
  }

  factory Episode.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Episode(
      id: serializer.fromJson<int>(json['id']),
      seriesId: serializer.fromJson<int>(json['seriesId']),
      seasonNumber: serializer.fromJson<int>(json['seasonNumber']),
      episodeNumber: serializer.fromJson<int>(json['episodeNumber']),
      title: serializer.fromJson<String?>(json['title']),
      airDate: serializer.fromJson<DateTime?>(json['airDate']),
      watched: serializer.fromJson<bool>(json['watched']),
      watchedAt: serializer.fromJson<DateTime?>(json['watchedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'seriesId': serializer.toJson<int>(seriesId),
      'seasonNumber': serializer.toJson<int>(seasonNumber),
      'episodeNumber': serializer.toJson<int>(episodeNumber),
      'title': serializer.toJson<String?>(title),
      'airDate': serializer.toJson<DateTime?>(airDate),
      'watched': serializer.toJson<bool>(watched),
      'watchedAt': serializer.toJson<DateTime?>(watchedAt),
    };
  }

  Episode copyWith({
    int? id,
    int? seriesId,
    int? seasonNumber,
    int? episodeNumber,
    Value<String?> title = const Value.absent(),
    Value<DateTime?> airDate = const Value.absent(),
    bool? watched,
    Value<DateTime?> watchedAt = const Value.absent(),
  }) => Episode(
    id: id ?? this.id,
    seriesId: seriesId ?? this.seriesId,
    seasonNumber: seasonNumber ?? this.seasonNumber,
    episodeNumber: episodeNumber ?? this.episodeNumber,
    title: title.present ? title.value : this.title,
    airDate: airDate.present ? airDate.value : this.airDate,
    watched: watched ?? this.watched,
    watchedAt: watchedAt.present ? watchedAt.value : this.watchedAt,
  );
  Episode copyWithCompanion(EpisodesCompanion data) {
    return Episode(
      id: data.id.present ? data.id.value : this.id,
      seriesId: data.seriesId.present ? data.seriesId.value : this.seriesId,
      seasonNumber: data.seasonNumber.present
          ? data.seasonNumber.value
          : this.seasonNumber,
      episodeNumber: data.episodeNumber.present
          ? data.episodeNumber.value
          : this.episodeNumber,
      title: data.title.present ? data.title.value : this.title,
      airDate: data.airDate.present ? data.airDate.value : this.airDate,
      watched: data.watched.present ? data.watched.value : this.watched,
      watchedAt: data.watchedAt.present ? data.watchedAt.value : this.watchedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Episode(')
          ..write('id: $id, ')
          ..write('seriesId: $seriesId, ')
          ..write('seasonNumber: $seasonNumber, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('title: $title, ')
          ..write('airDate: $airDate, ')
          ..write('watched: $watched, ')
          ..write('watchedAt: $watchedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    seriesId,
    seasonNumber,
    episodeNumber,
    title,
    airDate,
    watched,
    watchedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Episode &&
          other.id == this.id &&
          other.seriesId == this.seriesId &&
          other.seasonNumber == this.seasonNumber &&
          other.episodeNumber == this.episodeNumber &&
          other.title == this.title &&
          other.airDate == this.airDate &&
          other.watched == this.watched &&
          other.watchedAt == this.watchedAt);
}

class EpisodesCompanion extends UpdateCompanion<Episode> {
  final Value<int> id;
  final Value<int> seriesId;
  final Value<int> seasonNumber;
  final Value<int> episodeNumber;
  final Value<String?> title;
  final Value<DateTime?> airDate;
  final Value<bool> watched;
  final Value<DateTime?> watchedAt;
  const EpisodesCompanion({
    this.id = const Value.absent(),
    this.seriesId = const Value.absent(),
    this.seasonNumber = const Value.absent(),
    this.episodeNumber = const Value.absent(),
    this.title = const Value.absent(),
    this.airDate = const Value.absent(),
    this.watched = const Value.absent(),
    this.watchedAt = const Value.absent(),
  });
  EpisodesCompanion.insert({
    this.id = const Value.absent(),
    required int seriesId,
    required int seasonNumber,
    required int episodeNumber,
    this.title = const Value.absent(),
    this.airDate = const Value.absent(),
    this.watched = const Value.absent(),
    this.watchedAt = const Value.absent(),
  }) : seriesId = Value(seriesId),
       seasonNumber = Value(seasonNumber),
       episodeNumber = Value(episodeNumber);
  static Insertable<Episode> custom({
    Expression<int>? id,
    Expression<int>? seriesId,
    Expression<int>? seasonNumber,
    Expression<int>? episodeNumber,
    Expression<String>? title,
    Expression<DateTime>? airDate,
    Expression<bool>? watched,
    Expression<DateTime>? watchedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (seriesId != null) 'series_id': seriesId,
      if (seasonNumber != null) 'season_number': seasonNumber,
      if (episodeNumber != null) 'episode_number': episodeNumber,
      if (title != null) 'title': title,
      if (airDate != null) 'air_date': airDate,
      if (watched != null) 'watched': watched,
      if (watchedAt != null) 'watched_at': watchedAt,
    });
  }

  EpisodesCompanion copyWith({
    Value<int>? id,
    Value<int>? seriesId,
    Value<int>? seasonNumber,
    Value<int>? episodeNumber,
    Value<String?>? title,
    Value<DateTime?>? airDate,
    Value<bool>? watched,
    Value<DateTime?>? watchedAt,
  }) {
    return EpisodesCompanion(
      id: id ?? this.id,
      seriesId: seriesId ?? this.seriesId,
      seasonNumber: seasonNumber ?? this.seasonNumber,
      episodeNumber: episodeNumber ?? this.episodeNumber,
      title: title ?? this.title,
      airDate: airDate ?? this.airDate,
      watched: watched ?? this.watched,
      watchedAt: watchedAt ?? this.watchedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (seriesId.present) {
      map['series_id'] = Variable<int>(seriesId.value);
    }
    if (seasonNumber.present) {
      map['season_number'] = Variable<int>(seasonNumber.value);
    }
    if (episodeNumber.present) {
      map['episode_number'] = Variable<int>(episodeNumber.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (airDate.present) {
      map['air_date'] = Variable<DateTime>(airDate.value);
    }
    if (watched.present) {
      map['watched'] = Variable<bool>(watched.value);
    }
    if (watchedAt.present) {
      map['watched_at'] = Variable<DateTime>(watchedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpisodesCompanion(')
          ..write('id: $id, ')
          ..write('seriesId: $seriesId, ')
          ..write('seasonNumber: $seasonNumber, ')
          ..write('episodeNumber: $episodeNumber, ')
          ..write('title: $title, ')
          ..write('airDate: $airDate, ')
          ..write('watched: $watched, ')
          ..write('watchedAt: $watchedAt')
          ..write(')'))
        .toString();
  }
}

class $UserListsTable extends UserLists
    with TableInfo<$UserListsTable, UserList> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserListsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, name];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_lists';
  @override
  VerificationContext validateIntegrity(
    Insertable<UserList> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserList map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserList(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
    );
  }

  @override
  $UserListsTable createAlias(String alias) {
    return $UserListsTable(attachedDatabase, alias);
  }
}

class UserList extends DataClass implements Insertable<UserList> {
  final int id;
  final String name;
  const UserList({required this.id, required this.name});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    return map;
  }

  UserListsCompanion toCompanion(bool nullToAbsent) {
    return UserListsCompanion(id: Value(id), name: Value(name));
  }

  factory UserList.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserList(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
    };
  }

  UserList copyWith({int? id, String? name}) =>
      UserList(id: id ?? this.id, name: name ?? this.name);
  UserList copyWithCompanion(UserListsCompanion data) {
    return UserList(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserList(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserList && other.id == this.id && other.name == this.name);
}

class UserListsCompanion extends UpdateCompanion<UserList> {
  final Value<int> id;
  final Value<String> name;
  const UserListsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
  });
  UserListsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
  }) : name = Value(name);
  static Insertable<UserList> custom({
    Expression<int>? id,
    Expression<String>? name,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
    });
  }

  UserListsCompanion copyWith({Value<int>? id, Value<String>? name}) {
    return UserListsCompanion(id: id ?? this.id, name: name ?? this.name);
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserListsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name')
          ..write(')'))
        .toString();
  }
}

class $ListEntriesTable extends ListEntries
    with TableInfo<$ListEntriesTable, ListEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ListEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _listIdMeta = const VerificationMeta('listId');
  @override
  late final GeneratedColumn<int> listId = GeneratedColumn<int>(
    'list_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES user_lists (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _itemIdMeta = const VerificationMeta('itemId');
  @override
  late final GeneratedColumn<int> itemId = GeneratedColumn<int>(
    'item_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES media_items (id) ON DELETE CASCADE',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [listId, itemId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'list_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ListEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('list_id')) {
      context.handle(
        _listIdMeta,
        listId.isAcceptableOrUnknown(data['list_id']!, _listIdMeta),
      );
    } else if (isInserting) {
      context.missing(_listIdMeta);
    }
    if (data.containsKey('item_id')) {
      context.handle(
        _itemIdMeta,
        itemId.isAcceptableOrUnknown(data['item_id']!, _itemIdMeta),
      );
    } else if (isInserting) {
      context.missing(_itemIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {listId, itemId};
  @override
  ListEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ListEntry(
      listId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}list_id'],
      )!,
      itemId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}item_id'],
      )!,
    );
  }

  @override
  $ListEntriesTable createAlias(String alias) {
    return $ListEntriesTable(attachedDatabase, alias);
  }
}

class ListEntry extends DataClass implements Insertable<ListEntry> {
  final int listId;
  final int itemId;
  const ListEntry({required this.listId, required this.itemId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['list_id'] = Variable<int>(listId);
    map['item_id'] = Variable<int>(itemId);
    return map;
  }

  ListEntriesCompanion toCompanion(bool nullToAbsent) {
    return ListEntriesCompanion(listId: Value(listId), itemId: Value(itemId));
  }

  factory ListEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ListEntry(
      listId: serializer.fromJson<int>(json['listId']),
      itemId: serializer.fromJson<int>(json['itemId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'listId': serializer.toJson<int>(listId),
      'itemId': serializer.toJson<int>(itemId),
    };
  }

  ListEntry copyWith({int? listId, int? itemId}) =>
      ListEntry(listId: listId ?? this.listId, itemId: itemId ?? this.itemId);
  ListEntry copyWithCompanion(ListEntriesCompanion data) {
    return ListEntry(
      listId: data.listId.present ? data.listId.value : this.listId,
      itemId: data.itemId.present ? data.itemId.value : this.itemId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ListEntry(')
          ..write('listId: $listId, ')
          ..write('itemId: $itemId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(listId, itemId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ListEntry &&
          other.listId == this.listId &&
          other.itemId == this.itemId);
}

class ListEntriesCompanion extends UpdateCompanion<ListEntry> {
  final Value<int> listId;
  final Value<int> itemId;
  final Value<int> rowid;
  const ListEntriesCompanion({
    this.listId = const Value.absent(),
    this.itemId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ListEntriesCompanion.insert({
    required int listId,
    required int itemId,
    this.rowid = const Value.absent(),
  }) : listId = Value(listId),
       itemId = Value(itemId);
  static Insertable<ListEntry> custom({
    Expression<int>? listId,
    Expression<int>? itemId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (listId != null) 'list_id': listId,
      if (itemId != null) 'item_id': itemId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ListEntriesCompanion copyWith({
    Value<int>? listId,
    Value<int>? itemId,
    Value<int>? rowid,
  }) {
    return ListEntriesCompanion(
      listId: listId ?? this.listId,
      itemId: itemId ?? this.itemId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (listId.present) {
      map['list_id'] = Variable<int>(listId.value);
    }
    if (itemId.present) {
      map['item_id'] = Variable<int>(itemId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ListEntriesCompanion(')
          ..write('listId: $listId, ')
          ..write('itemId: $itemId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MediaItemsTable mediaItems = $MediaItemsTable(this);
  late final $EpisodesTable episodes = $EpisodesTable(this);
  late final $UserListsTable userLists = $UserListsTable(this);
  late final $ListEntriesTable listEntries = $ListEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    mediaItems,
    episodes,
    userLists,
    listEntries,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'media_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('episodes', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'user_lists',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('list_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'media_items',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('list_entries', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$MediaItemsTableCreateCompanionBuilder = MediaItemsCompanion Function({
  Value<int> id,
  required MediaType type,
  required String externalId,
  required String title,
  Value<String?> posterUrl,
  Value<String?> overview,
  Value<int?> year,
  Value<String> genres,
  Value<Status> status,
  Value<int?> rating,
  Value<String?> author,
  Value<int?> pageCount,
  Value<int> currentPage,
  Value<String?> dropReason,
  Value<int?> droppedAtPage,
  Value<DateTime> addedAt,
  Value<DateTime> lastActivityAt,
});
typedef $$MediaItemsTableUpdateCompanionBuilder = MediaItemsCompanion Function({
  Value<int> id,
  Value<MediaType> type,
  Value<String> externalId,
  Value<String> title,
  Value<String?> posterUrl,
  Value<String?> overview,
  Value<int?> year,
  Value<String> genres,
  Value<Status> status,
  Value<int?> rating,
  Value<String?> author,
  Value<int?> pageCount,
  Value<int> currentPage,
  Value<String?> dropReason,
  Value<int?> droppedAtPage,
  Value<DateTime> addedAt,
  Value<DateTime> lastActivityAt,
});

final class $$MediaItemsTableReferences
    extends BaseReferences<_$AppDatabase, $MediaItemsTable, MediaItem> {
  $$MediaItemsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EpisodesTable, List<Episode>> _episodesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.episodes,
    aliasName: 'media_items__id__episodes__series_id',
  );

  $$EpisodesTableProcessedTableManager get episodesRefs {
    final manager = $$EpisodesTableTableManager(
      $_db,
      $_db.episodes,
    ).filter((f) => f.seriesId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_episodesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$ListEntriesTable, List<ListEntry>>
  _listEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.listEntries,
    aliasName: 'media_items__id__list_entries__item_id',
  );

  $$ListEntriesTableProcessedTableManager get listEntriesRefs {
    final manager = $$ListEntriesTableTableManager(
      $_db,
      $_db.listEntries,
    ).filter((f) => f.itemId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_listEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MediaItemsTableFilterComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MediaType, MediaType, int> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get posterUrl => $composableBuilder(
    column: $table.posterUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get overview => $composableBuilder(
    column: $table.overview,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Status, Status, int> get status =>
      $composableBuilder(
        column: $table.status,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dropReason => $composableBuilder(
    column: $table.dropReason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get droppedAtPage => $composableBuilder(
    column: $table.droppedAtPage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastActivityAt => $composableBuilder(
    column: $table.lastActivityAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> episodesRefs(
    Expression<bool> Function($$EpisodesTableFilterComposer f) f,
  ) {
    final $$EpisodesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableFilterComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> listEntriesRefs(
    Expression<bool> Function($$ListEntriesTableFilterComposer f) f,
  ) {
    final $$ListEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.listEntries,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ListEntriesTableFilterComposer(
            $db: $db,
            $table: $db.listEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MediaItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get posterUrl => $composableBuilder(
    column: $table.posterUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get overview => $composableBuilder(
    column: $table.overview,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genres => $composableBuilder(
    column: $table.genres,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rating => $composableBuilder(
    column: $table.rating,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageCount => $composableBuilder(
    column: $table.pageCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dropReason => $composableBuilder(
    column: $table.dropReason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get droppedAtPage => $composableBuilder(
    column: $table.droppedAtPage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastActivityAt => $composableBuilder(
    column: $table.lastActivityAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MediaItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MediaItemsTable> {
  $$MediaItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MediaType, int> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get externalId => $composableBuilder(
    column: $table.externalId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get posterUrl =>
      $composableBuilder(column: $table.posterUrl, builder: (column) => column);

  GeneratedColumn<String> get overview =>
      $composableBuilder(column: $table.overview, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get genres =>
      $composableBuilder(column: $table.genres, builder: (column) => column);

  GeneratedColumnWithTypeConverter<Status, int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get rating =>
      $composableBuilder(column: $table.rating, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<int> get pageCount =>
      $composableBuilder(column: $table.pageCount, builder: (column) => column);

  GeneratedColumn<int> get currentPage => $composableBuilder(
    column: $table.currentPage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dropReason => $composableBuilder(
    column: $table.dropReason,
    builder: (column) => column,
  );

  GeneratedColumn<int> get droppedAtPage => $composableBuilder(
    column: $table.droppedAtPage,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastActivityAt => $composableBuilder(
    column: $table.lastActivityAt,
    builder: (column) => column,
  );

  Expression<T> episodesRefs<T extends Object>(
    Expression<T> Function($$EpisodesTableAnnotationComposer a) f,
  ) {
    final $$EpisodesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.episodes,
      getReferencedColumn: (t) => t.seriesId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodesTableAnnotationComposer(
            $db: $db,
            $table: $db.episodes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> listEntriesRefs<T extends Object>(
    Expression<T> Function($$ListEntriesTableAnnotationComposer a) f,
  ) {
    final $$ListEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.listEntries,
      getReferencedColumn: (t) => t.itemId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ListEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.listEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MediaItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MediaItemsTable,
          MediaItem,
          $$MediaItemsTableFilterComposer,
          $$MediaItemsTableOrderingComposer,
          $$MediaItemsTableAnnotationComposer,
          $$MediaItemsTableCreateCompanionBuilder,
          $$MediaItemsTableUpdateCompanionBuilder,
          (MediaItem, $$MediaItemsTableReferences),
          MediaItem,
          PrefetchHooks Function({bool episodesRefs, bool listEntriesRefs})
        > {
  $$MediaItemsTableTableManager(_$AppDatabase db, $MediaItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MediaItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MediaItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MediaItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<MediaType> type = const Value.absent(),
                Value<String> externalId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> posterUrl = const Value.absent(),
                Value<String?> overview = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String> genres = const Value.absent(),
                Value<Status> status = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<int> currentPage = const Value.absent(),
                Value<String?> dropReason = const Value.absent(),
                Value<int?> droppedAtPage = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<DateTime> lastActivityAt = const Value.absent(),
              }) => MediaItemsCompanion(
                id: id,
                type: type,
                externalId: externalId,
                title: title,
                posterUrl: posterUrl,
                overview: overview,
                year: year,
                genres: genres,
                status: status,
                rating: rating,
                author: author,
                pageCount: pageCount,
                currentPage: currentPage,
                dropReason: dropReason,
                droppedAtPage: droppedAtPage,
                addedAt: addedAt,
                lastActivityAt: lastActivityAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required MediaType type,
                required String externalId,
                required String title,
                Value<String?> posterUrl = const Value.absent(),
                Value<String?> overview = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String> genres = const Value.absent(),
                Value<Status> status = const Value.absent(),
                Value<int?> rating = const Value.absent(),
                Value<String?> author = const Value.absent(),
                Value<int?> pageCount = const Value.absent(),
                Value<int> currentPage = const Value.absent(),
                Value<String?> dropReason = const Value.absent(),
                Value<int?> droppedAtPage = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
                Value<DateTime> lastActivityAt = const Value.absent(),
              }) => MediaItemsCompanion.insert(
                id: id,
                type: type,
                externalId: externalId,
                title: title,
                posterUrl: posterUrl,
                overview: overview,
                year: year,
                genres: genres,
                status: status,
                rating: rating,
                author: author,
                pageCount: pageCount,
                currentPage: currentPage,
                dropReason: dropReason,
                droppedAtPage: droppedAtPage,
                addedAt: addedAt,
                lastActivityAt: lastActivityAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MediaItemsTable, MediaItem>(table),
                  $$MediaItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({episodesRefs = false, listEntriesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (episodesRefs) db.episodes,
                    if (listEntriesRefs) db.listEntries,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (episodesRefs)
                        await $_getPrefetchedData<
                          MediaItem,
                          $MediaItemsTable,
                          Episode
                        >(
                          currentTable: table,
                          referencedTable: $$MediaItemsTableReferences
                              ._episodesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MediaItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).episodesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.seriesId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (listEntriesRefs)
                        await $_getPrefetchedData<
                          MediaItem,
                          $MediaItemsTable,
                          ListEntry
                        >(
                          currentTable: table,
                          referencedTable: $$MediaItemsTableReferences
                              ._listEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$MediaItemsTableReferences(
                                db,
                                table,
                                p0,
                              ).listEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.itemId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$MediaItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MediaItemsTable,
      MediaItem,
      $$MediaItemsTableFilterComposer,
      $$MediaItemsTableOrderingComposer,
      $$MediaItemsTableAnnotationComposer,
      $$MediaItemsTableCreateCompanionBuilder,
      $$MediaItemsTableUpdateCompanionBuilder,
      (MediaItem, $$MediaItemsTableReferences),
      MediaItem,
      PrefetchHooks Function({bool episodesRefs, bool listEntriesRefs})
    >;
typedef $$EpisodesTableCreateCompanionBuilder = EpisodesCompanion Function({
  Value<int> id,
  required int seriesId,
  required int seasonNumber,
  required int episodeNumber,
  Value<String?> title,
  Value<DateTime?> airDate,
  Value<bool> watched,
  Value<DateTime?> watchedAt,
});
typedef $$EpisodesTableUpdateCompanionBuilder = EpisodesCompanion Function({
  Value<int> id,
  Value<int> seriesId,
  Value<int> seasonNumber,
  Value<int> episodeNumber,
  Value<String?> title,
  Value<DateTime?> airDate,
  Value<bool> watched,
  Value<DateTime?> watchedAt,
});

final class $$EpisodesTableReferences
    extends BaseReferences<_$AppDatabase, $EpisodesTable, Episode> {
  $$EpisodesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $MediaItemsTable _seriesIdTable(_$AppDatabase db) =>
      db.mediaItems.createAlias('episodes__series_id__media_items__id');

  $$MediaItemsTableProcessedTableManager get seriesId {
    final $_column = $_itemColumn<int>('series_id')!;

    final manager = $$MediaItemsTableTableManager(
      $_db,
      $_db.mediaItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_seriesIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EpisodesTableFilterComposer
    extends Composer<_$AppDatabase, $EpisodesTable> {
  $$EpisodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seasonNumber => $composableBuilder(
    column: $table.seasonNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get episodeNumber => $composableBuilder(
    column: $table.episodeNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get airDate => $composableBuilder(
    column: $table.airDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get watched => $composableBuilder(
    column: $table.watched,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get watchedAt => $composableBuilder(
    column: $table.watchedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$MediaItemsTableFilterComposer get seriesId {
    final $$MediaItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableFilterComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpisodesTableOrderingComposer
    extends Composer<_$AppDatabase, $EpisodesTable> {
  $$EpisodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seasonNumber => $composableBuilder(
    column: $table.seasonNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get episodeNumber => $composableBuilder(
    column: $table.episodeNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get airDate => $composableBuilder(
    column: $table.airDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get watched => $composableBuilder(
    column: $table.watched,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get watchedAt => $composableBuilder(
    column: $table.watchedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$MediaItemsTableOrderingComposer get seriesId {
    final $$MediaItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableOrderingComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpisodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EpisodesTable> {
  $$EpisodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get seasonNumber => $composableBuilder(
    column: $table.seasonNumber,
    builder: (column) => column,
  );

  GeneratedColumn<int> get episodeNumber => $composableBuilder(
    column: $table.episodeNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get airDate =>
      $composableBuilder(column: $table.airDate, builder: (column) => column);

  GeneratedColumn<bool> get watched =>
      $composableBuilder(column: $table.watched, builder: (column) => column);

  GeneratedColumn<DateTime> get watchedAt =>
      $composableBuilder(column: $table.watchedAt, builder: (column) => column);

  $$MediaItemsTableAnnotationComposer get seriesId {
    final $$MediaItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.seriesId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpisodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EpisodesTable,
          Episode,
          $$EpisodesTableFilterComposer,
          $$EpisodesTableOrderingComposer,
          $$EpisodesTableAnnotationComposer,
          $$EpisodesTableCreateCompanionBuilder,
          $$EpisodesTableUpdateCompanionBuilder,
          (Episode, $$EpisodesTableReferences),
          Episode,
          PrefetchHooks Function({bool seriesId})
        > {
  $$EpisodesTableTableManager(_$AppDatabase db, $EpisodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpisodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EpisodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EpisodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> seriesId = const Value.absent(),
                Value<int> seasonNumber = const Value.absent(),
                Value<int> episodeNumber = const Value.absent(),
                Value<String?> title = const Value.absent(),
                Value<DateTime?> airDate = const Value.absent(),
                Value<bool> watched = const Value.absent(),
                Value<DateTime?> watchedAt = const Value.absent(),
              }) => EpisodesCompanion(
                id: id,
                seriesId: seriesId,
                seasonNumber: seasonNumber,
                episodeNumber: episodeNumber,
                title: title,
                airDate: airDate,
                watched: watched,
                watchedAt: watchedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int seriesId,
                required int seasonNumber,
                required int episodeNumber,
                Value<String?> title = const Value.absent(),
                Value<DateTime?> airDate = const Value.absent(),
                Value<bool> watched = const Value.absent(),
                Value<DateTime?> watchedAt = const Value.absent(),
              }) => EpisodesCompanion.insert(
                id: id,
                seriesId: seriesId,
                seasonNumber: seasonNumber,
                episodeNumber: episodeNumber,
                title: title,
                airDate: airDate,
                watched: watched,
                watchedAt: watchedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$EpisodesTable, Episode>(table),
                  $$EpisodesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({seriesId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (seriesId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.seriesId,
                        referencedTable: $$EpisodesTableReferences
                            ._seriesIdTable(db),
                        referencedColumn: $$EpisodesTableReferences
                            ._seriesIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$EpisodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EpisodesTable,
      Episode,
      $$EpisodesTableFilterComposer,
      $$EpisodesTableOrderingComposer,
      $$EpisodesTableAnnotationComposer,
      $$EpisodesTableCreateCompanionBuilder,
      $$EpisodesTableUpdateCompanionBuilder,
      (Episode, $$EpisodesTableReferences),
      Episode,
      PrefetchHooks Function({bool seriesId})
    >;
typedef $$UserListsTableCreateCompanionBuilder = UserListsCompanion Function({
  Value<int> id,
  required String name,
});
typedef $$UserListsTableUpdateCompanionBuilder = UserListsCompanion Function({
  Value<int> id,
  Value<String> name,
});

final class $$UserListsTableReferences
    extends BaseReferences<_$AppDatabase, $UserListsTable, UserList> {
  $$UserListsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ListEntriesTable, List<ListEntry>>
  _listEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.listEntries,
    aliasName: 'user_lists__id__list_entries__list_id',
  );

  $$ListEntriesTableProcessedTableManager get listEntriesRefs {
    final manager = $$ListEntriesTableTableManager(
      $_db,
      $_db.listEntries,
    ).filter((f) => f.listId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_listEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$UserListsTableFilterComposer
    extends Composer<_$AppDatabase, $UserListsTable> {
  $$UserListsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> listEntriesRefs(
    Expression<bool> Function($$ListEntriesTableFilterComposer f) f,
  ) {
    final $$ListEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.listEntries,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ListEntriesTableFilterComposer(
            $db: $db,
            $table: $db.listEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserListsTableOrderingComposer
    extends Composer<_$AppDatabase, $UserListsTable> {
  $$UserListsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$UserListsTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserListsTable> {
  $$UserListsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  Expression<T> listEntriesRefs<T extends Object>(
    Expression<T> Function($$ListEntriesTableAnnotationComposer a) f,
  ) {
    final $$ListEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.listEntries,
      getReferencedColumn: (t) => t.listId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ListEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.listEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$UserListsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $UserListsTable,
          UserList,
          $$UserListsTableFilterComposer,
          $$UserListsTableOrderingComposer,
          $$UserListsTableAnnotationComposer,
          $$UserListsTableCreateCompanionBuilder,
          $$UserListsTableUpdateCompanionBuilder,
          (UserList, $$UserListsTableReferences),
          UserList,
          PrefetchHooks Function({bool listEntriesRefs})
        > {
  $$UserListsTableTableManager(_$AppDatabase db, $UserListsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserListsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserListsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserListsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
          }) => UserListsCompanion(id: id, name: name),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
          }) => UserListsCompanion.insert(id: id, name: name),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$UserListsTable, UserList>(table),
                  $$UserListsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({listEntriesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (listEntriesRefs) db.listEntries],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (listEntriesRefs)
                    await $_getPrefetchedData<
                      UserList,
                      $UserListsTable,
                      ListEntry
                    >(
                      currentTable: table,
                      referencedTable: $$UserListsTableReferences
                          ._listEntriesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$UserListsTableReferences(
                            db,
                            table,
                            p0,
                          ).listEntriesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.listId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$UserListsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $UserListsTable,
      UserList,
      $$UserListsTableFilterComposer,
      $$UserListsTableOrderingComposer,
      $$UserListsTableAnnotationComposer,
      $$UserListsTableCreateCompanionBuilder,
      $$UserListsTableUpdateCompanionBuilder,
      (UserList, $$UserListsTableReferences),
      UserList,
      PrefetchHooks Function({bool listEntriesRefs})
    >;
typedef $$ListEntriesTableCreateCompanionBuilder =
    ListEntriesCompanion Function({
      required int listId,
      required int itemId,
      Value<int> rowid,
    });
typedef $$ListEntriesTableUpdateCompanionBuilder =
    ListEntriesCompanion Function({
      Value<int> listId,
      Value<int> itemId,
      Value<int> rowid,
    });

final class $$ListEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $ListEntriesTable, ListEntry> {
  $$ListEntriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $UserListsTable _listIdTable(_$AppDatabase db) =>
      db.userLists.createAlias('list_entries__list_id__user_lists__id');

  $$UserListsTableProcessedTableManager get listId {
    final $_column = $_itemColumn<int>('list_id')!;

    final manager = $$UserListsTableTableManager(
      $_db,
      $_db.userLists,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_listIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $MediaItemsTable _itemIdTable(_$AppDatabase db) =>
      db.mediaItems.createAlias('list_entries__item_id__media_items__id');

  $$MediaItemsTableProcessedTableManager get itemId {
    final $_column = $_itemColumn<int>('item_id')!;

    final manager = $$MediaItemsTableTableManager(
      $_db,
      $_db.mediaItems,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_itemIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ListEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ListEntriesTable> {
  $$ListEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$UserListsTableFilterComposer get listId {
    final $$UserListsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.userLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserListsTableFilterComposer(
            $db: $db,
            $table: $db.userLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MediaItemsTableFilterComposer get itemId {
    final $$MediaItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableFilterComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ListEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ListEntriesTable> {
  $$ListEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$UserListsTableOrderingComposer get listId {
    final $$UserListsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.userLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserListsTableOrderingComposer(
            $db: $db,
            $table: $db.userLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MediaItemsTableOrderingComposer get itemId {
    final $$MediaItemsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableOrderingComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ListEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ListEntriesTable> {
  $$ListEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  $$UserListsTableAnnotationComposer get listId {
    final $$UserListsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.listId,
      referencedTable: $db.userLists,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$UserListsTableAnnotationComposer(
            $db: $db,
            $table: $db.userLists,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$MediaItemsTableAnnotationComposer get itemId {
    final $$MediaItemsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.itemId,
      referencedTable: $db.mediaItems,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MediaItemsTableAnnotationComposer(
            $db: $db,
            $table: $db.mediaItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ListEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ListEntriesTable,
          ListEntry,
          $$ListEntriesTableFilterComposer,
          $$ListEntriesTableOrderingComposer,
          $$ListEntriesTableAnnotationComposer,
          $$ListEntriesTableCreateCompanionBuilder,
          $$ListEntriesTableUpdateCompanionBuilder,
          (ListEntry, $$ListEntriesTableReferences),
          ListEntry,
          PrefetchHooks Function({bool listId, bool itemId})
        > {
  $$ListEntriesTableTableManager(_$AppDatabase db, $ListEntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ListEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ListEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ListEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> listId = const Value.absent(),
                Value<int> itemId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ListEntriesCompanion(
                listId: listId,
                itemId: itemId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int listId,
                required int itemId,
                Value<int> rowid = const Value.absent(),
              }) => ListEntriesCompanion.insert(
                listId: listId,
                itemId: itemId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ListEntriesTable, ListEntry>(table),
                  $$ListEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({listId = false, itemId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (listId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.listId,
                        referencedTable: $$ListEntriesTableReferences
                            ._listIdTable(db),
                        referencedColumn: $$ListEntriesTableReferences
                            ._listIdTable(db)
                            .id,
                      ) as T;
                    }
                    if (itemId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.itemId,
                        referencedTable: $$ListEntriesTableReferences
                            ._itemIdTable(db),
                        referencedColumn: $$ListEntriesTableReferences
                            ._itemIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ListEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ListEntriesTable,
      ListEntry,
      $$ListEntriesTableFilterComposer,
      $$ListEntriesTableOrderingComposer,
      $$ListEntriesTableAnnotationComposer,
      $$ListEntriesTableCreateCompanionBuilder,
      $$ListEntriesTableUpdateCompanionBuilder,
      (ListEntry, $$ListEntriesTableReferences),
      ListEntry,
      PrefetchHooks Function({bool listId, bool itemId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MediaItemsTableTableManager get mediaItems =>
      $$MediaItemsTableTableManager(_db, _db.mediaItems);
  $$EpisodesTableTableManager get episodes =>
      $$EpisodesTableTableManager(_db, _db.episodes);
  $$UserListsTableTableManager get userLists =>
      $$UserListsTableTableManager(_db, _db.userLists);
  $$ListEntriesTableTableManager get listEntries =>
      $$ListEntriesTableTableManager(_db, _db.listEntries);
}
