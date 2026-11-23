import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/app_database.dart';
import '../../data/reading_queries.dart';

class ProgressResult {
  const ProgressResult({
    required this.unit,
    required this.pageCount,
    required this.value,
    this.minutes,
  });

  final ProgressUnit unit;
  final int? pageCount;
  final int value;
  final int? minutes;
}

const _timeChoices = <int?>[null, 15, 30, 45, 60, 90];

Future<ProgressResult?> showProgressSheet(
    BuildContext context, {
      required MediaItem item,
      required bool starting,
      int? suggestedPageCount,
      int? fixedMinutes,
      bool mandatory = false,
    }) {
  return showModalBottomSheet<ProgressResult>(
    context: context,
    isScrollControlled: true,
    isDismissible: !mandatory,
    enableDrag: !mandatory,
    showDragHandle: !mandatory,
    builder: (_) => PopScope(
      canPop: !mandatory,
      child: _ProgressSheet(
        item: item,
        starting: starting,
        suggestedPageCount: suggestedPageCount,
        fixedMinutes: fixedMinutes,
        mandatory: mandatory,
      ),
    ),
  );
}

class _ProgressSheet extends StatefulWidget {
  const _ProgressSheet({
    required this.item,
    required this.starting,
    this.suggestedPageCount,
    this.fixedMinutes,
    this.mandatory = false,
  });

  final MediaItem item;
  final bool starting;
  final int? suggestedPageCount;
  final int? fixedMinutes;
  final bool mandatory;

  @override
  State<_ProgressSheet> createState() => _ProgressSheetState();
}

class _ProgressSheetState extends State<_ProgressSheet> {
  late int? _pageCount;
  late ProgressUnit _unit;
  late int _value;
  int? _minutes;

  int get _max => _unit == ProgressUnit.pages ? _pageCount! : 100;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    final count = item.hasPages ? item.pageCount : widget.suggestedPageCount;
    _pageCount = (count ?? 0) > 0 ? count : null;
    _unit = _pageCount == null
        ? ProgressUnit.percent
        : (item.progressUnit ?? ProgressUnit.pages);
    final base =
    (widget.starting && item.status == Status.done) ? 0 : item.currentPage;
    _value = convertValue(base, item.unit, _unit, _pageCount)
        .clamp(0, _max)
        .toInt();
  }

  void _bump(int delta) =>
      setState(() => _value = (_value + delta).clamp(0, _max).toInt());

  void _setUnit(ProgressUnit next) {
    if (next == _unit) return;
    setState(() {
      _value = convertValue(_value, _unit, next, _pageCount);
      _unit = next;
    });
  }

  Future<void> _editCount() async {
    final n = await showDialog<int>(
      context: context,
      builder: (_) => _PageCountDialog(initial: _pageCount),
    );
    if (n == null) return;
    setState(() {
      _pageCount = n;
      if (_unit == ProgressUnit.pages) _value = _value.clamp(0, n).toInt();
    });
  }

  void _save() {
    Navigator.of(context).pop(ProgressResult(
      unit: _unit,
      pageCount: _pageCount,
      value: _value,
      minutes: widget.fixedMinutes ?? _minutes,
    ));
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

  String get _valueLabel {
    final count = _pageCount;
    if (_unit == ProgressUnit.pages) {
      final pct = (_value * 100 / count!).round();
      return 'Page $_value of $count ($pct%)';
    }
    if (count == null) return '$_value%';
    final page = convertValue(_value, ProgressUnit.percent, ProgressUnit.pages, count);
    return '$_value% (about page $page of $count)';
  }

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final fixed = widget.fixedMinutes;
    final mandatory = widget.mandatory;

    final title = mandatory
        ? 'Reading session ended'
        : (widget.starting ? 'Start reading' : 'Update progress');
    final subtitle = mandatory
        ? 'Update your progress to continue.'
        : (widget.starting ? 'Where are you in the book?' : null);

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(20, mandatory ? 24 : 0, 20, 20),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: text.titleLarge),
            if (subtitle != null) Text(subtitle, style: text.bodyMedium),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ProgressUnit>(
                showSelectedIcon: false,
                segments: [
                  ButtonSegment(
                    value: ProgressUnit.pages,
                    label: const Text('Pages'),
                    enabled: _pageCount != null,
                  ),
                  const ButtonSegment(
                    value: ProgressUnit.percent,
                    label: Text('Percent'),
                  ),
                ],
                selected: {_unit},
                onSelectionChanged: (s) => _setUnit(s.first),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _pageCount == null
                        ? 'Total pages: not set'
                        : 'Total pages: $_pageCount',
                    style: text.bodyMedium,
                  ),
                ),
                TextButton(
                  onPressed: _editCount,
                  child: Text(_pageCount == null ? 'Add' : 'Edit'),
                ),
              ],
            ),
            if (_pageCount == null)
              Text(
                'Without a page count, progress is tracked in percent.',
                style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            const SizedBox(height: 16),
            Text(_valueLabel, style: text.titleMedium),
            Slider(
              value: _value.toDouble(),
              min: 0,
              max: _max.toDouble(),
              onChanged: (v) => setState(() => _value = v.round()),
            ),
            Row(
              children: [
                _step('-10', -10),
                _step('-1', -1),
                _step('+1', 1),
                _step('+10', 10),
              ],
            ),
            if (fixed != null) ...[
              const SizedBox(height: 16),
              Text('Time spent: $fixed min', style: text.titleSmall),
            ] else if (!widget.starting && !mandatory) ...[
              const SizedBox(height: 16),
              Text('Time spent (optional)', style: text.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final m in _timeChoices)
                    ChoiceChip(
                      label: Text(m == null ? 'None' : '$m min'),
                      selected: _minutes == m,
                      onSelected: (_) => setState(() => _minutes = m),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            if (mandatory)
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Save progress'),
                ),
              )
            else
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
                      child: Text(widget.starting ? 'Start reading' : 'Save'),
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

class _PageCountDialog extends StatefulWidget {
  const _PageCountDialog({this.initial});

  final int? initial;

  @override
  State<_PageCountDialog> createState() => _PageCountDialogState();
}

class _PageCountDialogState extends State<_PageCountDialog> {
  late final _controller =
  TextEditingController(text: widget.initial?.toString() ?? '');

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final n = int.tryParse(_controller.text);
    if (n != null && n > 0) Navigator.of(context).pop(n);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Total pages'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(5),
        ],
        decoration: const InputDecoration(
          hintText: 'Pages in your edition',
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _save(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _save, child: const Text('Save')),
      ],
    );
  }
}