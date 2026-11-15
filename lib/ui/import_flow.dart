import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/import_queries.dart';
import '../providers.dart';
import 'series_actions.dart' show confirmDialog;

/// You > Backup and data > Import from JSON.
/// Pick file, check it, ask only if something conflicts, then import.
Future<void> importBackupFlow(BuildContext context, WidgetRef ref) async {
  final messenger = ScaffoldMessenger.of(context);
  final db = ref.read(databaseProvider);

  void say(String text) =>
      messenger.showSnackBar(SnackBar(content: Text(text)));

  // 1. Pick the file.
  final List<PlatformFile> picked =
  await FilePicker.pickFiles(
    type: FileType.any,
  );

  // 2. Check whether a file was selected.
  if (picked.isEmpty) return;

  final file = picked.first;

  // 3. Read file bytes.

  final bytes = await file.readAsBytes();

  if (bytes.isEmpty) {
    say('The selected file is empty.');
    return;
  }


  // 2. Check it and compare with the library.
  final ImportPreview preview;
  try {
    preview = await db.analyzeBackup(BackupFile.parse(utf8.decode(bytes)));
  } on FormatException catch (e) {
    say(e.message);
    return;
  } catch (_) {
    say('Could not read that backup.');
    return;
  }
  if (!context.mounted) return;

  // 3. Decide.
  var choice = ImportChoice.merge; // only matters when there are conflicts
  if (preview.conflicts.isNotEmpty) {
    final answer = await _askChoice(context, preview);
    if (answer == null) return; // cancelled
    choice = answer;
  } else if (preview.newItems.isNotEmpty) {
    final n = preview.newItems.length;
    final message = preview.libraryEmpty
        ? 'Import $n item${n == 1 ? '' : 's'} and ${preview.file.lists.length} '
        'list${preview.file.lists.length == 1 ? '' : 's'} from this backup?'
        : '$n new item${n == 1 ? '' : 's'} will be added. '
        '${preview.identical} already on your phone will be skipped. '
        'Nothing on your phone is changed.';
    final ok = await confirmDialog(
      context,
      title: 'Import backup?',
      message: message,
      yes: 'Import',
    );
    if (!ok) return;
  }
  if (!context.mounted) return;

  // 4. Import, with a spinner. One transaction: all or nothing.
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const PopScope(
      canPop: false,
      child: Center(child: CircularProgressIndicator()),
    ),
  );
  try {
    final report = await db.applyBackup(preview, choice);
    say(report.summary);
  } catch (e) {
    say('Import failed. Nothing was changed. ($e)');
  } finally {
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
  }
}

Future<ImportChoice?> _askChoice(BuildContext context, ImportPreview pv) {
  final n = pv.conflicts.length;
  return showModalBottomSheet<ImportChoice>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (sheetContext) {
      final text = Theme.of(sheetContext).textTheme;
      final scheme = Theme.of(sheetContext).colorScheme;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                '$n item${n == 1 ? '' : 's'} differ',
                style: text.titleLarge,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 8),
              child: Text(
                'These are on your phone and in the backup, with different progress. '
                    'Choose what to do with them. Everything else in the backup is added.',
                style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 150),
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  for (final c in pv.conflicts)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            c.item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: text.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          Text(
                            c.reason,
                            style: text.bodySmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const Divider(height: 24),
            ListTile(
              leading: const Icon(Icons.merge_type_rounded),
              title: const Text('Merge both (recommended)'),
              subtitle: const Text(
                'Keeps every ticked episode and history row from both sides. '
                    'The later activity decides the status.',
              ),
              onTap: () => Navigator.of(sheetContext).pop(ImportChoice.merge),
            ),
            ListTile(
              leading: const Icon(Icons.smartphone_rounded),
              title: const Text("Keep my phone's version"),
              subtitle: const Text('These items stay exactly as they are.'),
              onTap: () => Navigator.of(sheetContext).pop(ImportChoice.keepPhone),
            ),
            ListTile(
              leading: const Icon(Icons.restore_rounded),
              title: const Text("Use the backup's version"),
              subtitle: const Text(
                'Overwrites progress on these items. Anything ticked after the backup is lost.',
              ),
              onTap: () => Navigator.of(sheetContext).pop(ImportChoice.useBackup),
            ),
          ],
        ),
      );
    },
  );
}