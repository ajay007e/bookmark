import 'package:dio/dio.dart';

import '../data/app_database.dart';
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

  Future<List<SearchResult>> search(String query) async {
    final res = await _dio.get('/search.json', queryParameters: {
      'q': query,
      'limit': 25,
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
}