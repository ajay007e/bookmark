import 'package:flutter/material.dart';

/// Fixed reasons, so no typing is needed.
const dropReasons = [
  'Lost interest',
  'Too slow-paced',
  'Too difficult to follow',
  'Not what I expected',
  'Disliked the writing',
  'Ran out of time',
];
const _other = 'Other';

class DropResult {
  const DropResult({this.reason, this.page});

  final String? reason;
  final int? page;
}

/// Returns null if the sheet is dismissed or cancelled.
Future<DropResult?> showDropSheet(
    BuildContext context, {
      String? reason,
      int? page,
      int? pageCount,
    }) {
  return showModalBottomSheet<DropResult>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _DropSheet(reason: reason, page: page, pageCount: pageCount),
  );
}

class _DropSheet extends StatefulWidget {
  const _DropSheet({this.reason, this.page, this.pageCount});

  final String? reason;
  final int? page;
  final int? pageCount;

  @override
  State<_DropSheet> createState() => _DropSheetState();
}

class _DropSheetState extends State<_DropSheet> {
  final _custom = TextEditingController();
  String? _choice; // a fixed reason, "Other", or null for no reason
  int? _page;

  int get _max =>
      (widget.pageCount != null && widget.pageCount! > 0) ? widget.pageCount! : 1000;

  @override
  void initState() {
    super.initState();
    _page = widget.page;
    final r = widget.reason;
    if (r != null && r.isNotEmpty) {
      if (dropReasons.contains(r)) {
        _choice = r;
      } else {
        _choice = _other;
        _custom.text = r;
      }
    }
  }

  @override
  void dispose() {
    _custom.dispose();
    super.dispose();
  }

  void _bump(int delta) =>
      setState(() => _page = ((_page ?? 0) + delta).clamp(0, _max).toInt());

  void _save() {
    String? reason;
    if (_choice == _other) {
      final t = _custom.text.trim();
      reason = t.isEmpty ? null : t;
    } else {
      reason = _choice;
    }
    Navigator.of(context).pop(
      DropResult(reason: reason, page: (_page == null || _page == 0) ? null : _page),
    );
  }

  Widget _step(String label, int delta) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: OutlinedButton(
        onPressed: () => _bump(delta),
        child: Text(label),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        20,
        0,
        20,
        20 + MediaQuery.viewInsetsOf(context).bottom, // lift above the keyboard
      ),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Did not complete', style: text.titleLarge),
            const SizedBox(height: 4),
            Text('Both parts are optional.', style: text.bodyMedium),
            const SizedBox(height: 20),
            Text('Why did you stop?', style: text.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final r in [...dropReasons, _other])
                  ChoiceChip(
                    label: Text(r),
                    selected: _choice == r,
                    onSelected: (on) => setState(() => _choice = on ? r : null),
                  ),
              ],
            ),
            if (_choice == _other) ...[
              const SizedBox(height: 12),
              TextField(
                controller: _custom,
                maxLength: 80,
                decoration: const InputDecoration(
                  hintText: 'Your reason',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _page == null ? 'Page stopped at: not set' : 'Page stopped at: $_page',
                    style: text.titleSmall,
                  ),
                ),
                if (_page != null)
                  TextButton(
                    onPressed: () => setState(() => _page = null),
                    child: const Text('Clear'),
                  ),
              ],
            ),
            Slider(
              value: (_page ?? 0).toDouble(),
              min: 0,
              max: _max.toDouble(),
              onChanged: (v) => setState(() => _page = v.round()),
            ),
            Row(
              children: [
                _step('-10', -10),
                _step('-1', -1),
                _step('+1', 1),
                _step('+10', 10),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}