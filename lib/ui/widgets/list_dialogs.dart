import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers.dart';

/// Asks for a list name. Returns null when cancelled.
Future<String?> askListName(
    BuildContext context, {
      String title = 'New list',
      String confirm = 'Create',
      String initial = '',
    }) =>
    showDialog<String>(
      context: context,
      builder: (_) => _NameDialog(title: title, confirm: confirm, initial: initial),
    );

/// Asks for a name and creates the list. Returns the new id, or null.
Future<int?> createListFlow(BuildContext context, WidgetRef ref) async {
  final db = ref.read(databaseProvider);
  final messenger = ScaffoldMessenger.of(context);
  final name = await askListName(context);
  if (name == null) return null;
  final id = await db.createList(name);
  if (id == null) {
    messenger.showSnackBar(
      const SnackBar(content: Text('Enter a name that is not already used.')),
    );
  }
  return id;
}

class _NameDialog extends StatefulWidget {
  const _NameDialog({
    required this.title,
    required this.confirm,
    required this.initial,
  });

  final String title;
  final String confirm;
  final String initial;

  @override
  State<_NameDialog> createState() => _NameDialogState();
}

class _NameDialogState extends State<_NameDialog> {
  late final _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _done() => Navigator.of(context).pop(_controller.text);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: 40,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _done(),
        decoration: const InputDecoration(hintText: 'List name'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _done, child: Text(widget.confirm)),
      ],
    );
  }
}