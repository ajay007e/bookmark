import 'package:dio/dio.dart';

import '../data/app_database.dart';
import 'detail_info.dart';
import 'search_result.dart';

class OpenLibraryClient {
  OpenLibraryClient([Dio? dio])
      : _dio = dio ??
      Dio(BaseOptions(
        baseUrl: 'https://openlibrary.org',
        headers: {'User-Agent': 'Bookmark/1.0 (personal reading tracker)'},
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
      ));

  final Dio _dio;

  Future<List<SearchResult>> search(String query) =>
      _search({'q': query, 'limit': 25});

  Future<List<SearchResult>> _search(Map<String, dynamic> params) async {
    final res = await _dio.get('/search.json', queryParameters: {
      ...params,
      'fields':
      'key,title,author_name,first_publish_year,cover_i,number_of_pages_median,subject',
    });
    final docs = (res.data['docs'] as List).cast<Map<String, dynamic>>();
    return docs.map((d) {
      final authors = (d['author_name'] as List?)?.cast<String>() ?? const [];
      final subjects = (d['subject'] as List?)?.cast<String>() ?? const [];
      final cover = d['cover_i'];
      return SearchResult(
        type: MediaType.book,
        externalId: d['key'] as String,
        title: (d['title'] as String?) ?? 'Untitled',
        year: d['first_publish_year'] as int?,
        posterUrl:
        cover == null ? null : 'https://covers.openlibrary.org/b/id/$cover-M.jpg',
        author: authors.isEmpty ? null : authors.first,
        pageCount: d['number_of_pages_median'] as int?,
        genres: subjects.take(3).map((s) => s.replaceAll(',', ' ')).join(','),
      );
    }).toList();
  }

  // Subjects that say nothing about the content of a book.
  static const _skipSubjects = [
    'accessible book',
    'protected daisy',
    'in library',
    'large type',
    'overdrive',
    'open library',
  ];
  static const _tooGeneric = [
    'fiction',
    'general',
    'literature',
    'novel',
    'novels',
    'nonfiction',
  ];

  /// "You may also like": other books by the same author, then top-rated
  /// books in one of this book's subjects. Failures give an empty list.
  Future<List<SearchResult>> similarBooks({
    required String workKey,
    required String title,
    String? author,
    List<String> subjects = const [],
  }) async {
    String? topic;
    for (final s in subjects) {
      final low = s.toLowerCase();
      if (_skipSubjects.any(low.contains) || _tooGeneric.contains(low)) continue;
      topic = s.replaceAll('"', '');
      break;
    }

    Future<List<SearchResult>> safe(Map<String, dynamic> params) async {
      try {
        return await _search(params);
      } catch (_) {
        return const [];
      }
    }

    final cleanAuthor = author?.replaceAll('"', '').trim();
    final lists = await Future.wait([
      (cleanAuthor == null || cleanAuthor.isEmpty)
          ? Future.value(<SearchResult>[])
          : safe({'q': 'author:"$cleanAuthor"', 'sort': 'rating', 'limit': 12}),
      topic == null
          ? Future.value(<SearchResult>[])
          : safe({'q': 'subject:"$topic"', 'sort': 'rating', 'limit': 20}),
    ]);

    // Author's other books first, then the subject matches, then the rest.
    final ordered = [...lists[0].take(6), ...lists[1], ...lists[0].skip(6)];

    final seenKeys = <String>{workKey};
    final seenTitles = <String>{title.toLowerCase()};
    final out = <SearchResult>[];
    for (final r in ordered) {
      if (r.posterUrl == null) continue;
      if (!seenKeys.add(r.externalId)) continue;
      if (!seenTitles.add(r.title.toLowerCase())) continue;
      out.add(r);
      if (out.length == 12) break;
    }
    return out;
  }

  static const _languages = {
    'eng': 'English', 'fre': 'French', 'fra': 'French', 'ger': 'German',
    'deu': 'German', 'spa': 'Spanish', 'ita': 'Italian', 'por': 'Portuguese',
    'rus': 'Russian', 'jpn': 'Japanese', 'chi': 'Chinese', 'zho': 'Chinese',
    'dut': 'Dutch', 'nld': 'Dutch', 'swe': 'Swedish', 'nor': 'Norwegian',
    'dan': 'Danish', 'fin': 'Finnish', 'pol': 'Polish', 'tur': 'Turkish',
    'ara': 'Arabic', 'heb': 'Hebrew', 'hin': 'Hindi', 'kor': 'Korean',
    'lat': 'Latin', 'gre': 'Greek', 'ell': 'Greek', 'cze': 'Czech',
    'hun': 'Hungarian', 'ukr': 'Ukrainian',
  };

  /// Language, publisher and page count of the most prominent English edition.
  /// Best effort: any failure gives empty values.
  Future<({String? language, String? publisher, int? pages})> _edition(
      String key,
      ) async {
    try {
      final res = await _dio.get('$key/editions.json', queryParameters: {'limit': 30});
      final entries = ((res.data['entries'] as List?) ?? const [])
          .cast<Map<String, dynamic>>();

      bool english(Map<String, dynamic> e) => ((e['languages'] as List?) ?? const [])
          .any((l) => (l as Map)['key'] == '/languages/eng');
      bool hasPublisher(Map<String, dynamic> e) =>
          ((e['publishers'] as List?) ?? const []).isNotEmpty;

      final pick = entries.where((e) => english(e) && hasPublisher(e)).firstOrNull ??
          entries.where(hasPublisher).firstOrNull ??
          entries.firstOrNull;
      if (pick == null) return (language: null, publisher: null, pages: null);

      final langs = (pick['languages'] as List?) ?? const [];
      final code = langs.isEmpty
          ? null
          : ((langs.first as Map)['key'] as String?)?.split('/').last;
      final publishers = (pick['publishers'] as List?) ?? const [];

      return (
      language: code == null ? null : (_languages[code] ?? code.toUpperCase()),
      publisher: publishers.isEmpty ? null : '${publishers.first}',
      pages: (pick['number_of_pages'] as num?)?.toInt(),
      );
    } catch (_) {
      return (language: null, publisher: null, pages: null);
    }
  }

  /// Description, rating, subjects, language and publisher for the book page.
  /// [key] is the work key we store, for example "/works/OL45883W".
  Future<BookInfo> bookInfo(String key) async {
    final editionFuture = _edition(key); // runs alongside, never throws
    final work = (await _dio.get('$key.json')).data as Map<String, dynamic>;

    // The rating is a bonus, so a failure here must not break the page.
    double? average;
    var count = 0;
    try {
      final r = await _dio.get('$key/ratings.json');
      final summary = (r.data['summary'] as Map?) ?? const {};
      average = (summary['average'] as num?)?.toDouble();
      count = (summary['count'] as num?)?.toInt() ?? 0;
    } catch (_) {}

    final subjects = ((work['subjects'] as List?) ?? const [])
        .whereType<String>()
        .where((s) => s.length <= 28)
        .take(8)
        .toList();

    final edition = await editionFuture;
    return BookInfo(
      description: _description(work['description']),
      ratingAverage: average,
      ratingCount: count,
      subjects: subjects,
      language: edition.language,
      publisher: edition.publisher,
      pages: edition.pages,
    );
  }

  /// Open Library descriptions are either a string or {type, value}, and often
  /// end with a "----------" section of links. Keep only the main text.
  static String? _description(dynamic d) {
    var text = d is Map ? d['value'] : d;
    if (text is! String) return null;
    text = text.split(RegExp(r'\r?\n\s*-{5,}')).first;
    text = text.replaceAllMapped(
      RegExp(r'\[([^\]]+)\]\([^)]*\)'),
          (m) => m[1]!,
    );
    text = text.trim();
    return text.isEmpty ? null : text;
  }
}