import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'app_database.dart';
import 'export_queries.dart';

String _two(int n) => n.toString().padLeft(2, '0');

/// Writes every table to one JSON file and opens the Android share sheet,
/// so the file can be saved to Files or Drive, or sent to yourself.
/// Returns how many items (movies, series, books) were exported.
Future<int> exportBackup(AppDatabase db) async {
  final data = await db.exportData();

  final now = DateTime.now();
  final stamp = '${now.year}-${_two(now.month)}-${_two(now.day)}';
  final name = 'bookmark-backup-$stamp.json';

  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$name');
  await file.writeAsString(jsonEncode(data));

  await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path, mimeType: 'application/json', name: name)],
      subject: 'Bookmark backup $stamp',
    ),
  );

  return (data['counts'] as Map)['mediaItems'] as int;
}