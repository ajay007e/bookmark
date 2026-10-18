import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/search_result.dart';
import '../config/secrets.dart';
import '../data/app_database.dart';
import '../data/labels.dart';
import '../providers.dart';
import 'widgets/empty_state.dart';
import 'widgets/poster_card.dart';

void openSearch(BuildContext context, {MediaType type = MediaType.movie}) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => SearchScreen(initialType: type)),
  );
}

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key, this.initialType = MediaType.movie});

  final MediaType initialType;

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  late MediaType _type = widget.initialType;
  final _controller = TextEditingController();
  Timer? _debounce;
  List<SearchResult> _results = const [];
  bool _loading = false;
  String? _error;
  int _searchId = 0; // used to ignore out-of-date responses

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  String get _hint => switch (_type) {
    MediaType.movie => 'Search movies',
    MediaType.series => 'Search series',
    MediaType.book => 'Search books or authors',
  };

  void _onChanged(String text) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _search);
    setState(() {}); // refresh the clear button
  }

  void _changeType(MediaType type) {
    setState(() {
      _type = type;
      _results = const [];
      _error = null;
    });
    _search();
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    final id = ++_searchId;

    if (query.length < 2) {
      setState(() {
        _results = const [];
        _loading = false;
        _error = null;
      });
      return;
    }

    if (_type != MediaType.book && tmdbApiKey == 'YOUR_TMDB_API_KEY') {
      setState(() {
        _error = 'Add your TMDB API key in lib/config/secrets.dart, then restart the app.';
        _loading = false;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = _type == MediaType.book
          ? await ref.read(openLibraryProvider).search(query)
          : await ref.read(tmdbProvider).search(_type, query);
      if (!mounted || id != _searchId) return;
      setState(() {
        _results = results;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || id != _searchId) return;
      setState(() {
        _error = 'The search failed. Check your internet connection and try again.';
        _loading = false;
      });
    }
  }

  Future<void> _showAddSheet(SearchResult result) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => AddSheet(result: result),
    );
  }

  @override
  Widget build(BuildContext context) {
    final owned = ref.watch(itemsByTypeProvider(_type)).maybeWhen(
      data: (items) => items.map((i) => i.externalId).toSet(),
      orElse: () => <String>{},
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Add to Bookmark')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: SegmentedButton<MediaType>(
              showSelectedIcon: false,
              segments: const [
                ButtonSegment(value: MediaType.movie, icon: Icon(Icons.movie_outlined), label: Text('Movies')),
                ButtonSegment(value: MediaType.series, icon: Icon(Icons.tv_outlined), label: Text('Series')),
                ButtonSegment(value: MediaType.book, icon: Icon(Icons.menu_book_outlined), label: Text('Books')),
              ],
              selected: {_type},
              onSelectionChanged: (s) => _changeType(s.first),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              onChanged: _onChanged,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: _hint,
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _controller.text.isEmpty
                    ? null
                    : IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _controller.clear();
                    _search();
                  },
                ),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(28)),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(child: _body(owned)),
        ],
      ),
    );
  }

  Widget _body(Set<String> owned) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) {
      return EmptyState(compact: true, title: 'Search problem', message: _error!);
    }
    if (_controller.text.trim().length < 2) {
      return EmptyState(
        compact: true,
        title: 'Find something to add',
        message: 'Type at least two letters above to search.',
      );
    }
    if (_results.isEmpty) {
      return const EmptyState(
        compact: true,
        title: 'No results',
        message: 'Try a different title or spelling.',
      );
    }

    return ListView.separated(
      itemCount: _results.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final r = _results[i];
        final added = owned.contains(r.externalId);
        return ListTile(
          leading: SizedBox(
            width: 48,
            height: 72,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: PosterImage(type: r.type, title: r.title, url: r.posterUrl),
            ),
          ),
          title: Text(r.title, maxLines: 2, overflow: TextOverflow.ellipsis),
          subtitle: r.subtitle.isEmpty ? null : Text(r.subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
          trailing: added
              ? const Chip(label: Text('Added'), visualDensity: VisualDensity.compact)
              : const Icon(Icons.add_circle_outline),
          onTap: added ? null : () => _showAddSheet(r),
        );
      },
    );
  }
}

/// Bottom sheet: pick a status, then add.
class AddSheet extends ConsumerStatefulWidget {
  const AddSheet({required this.result});

  final SearchResult result;

  @override
  ConsumerState<AddSheet> createState() => _AddSheetState();
}

class _AddSheetState extends ConsumerState<AddSheet> {
  Status _status = Status.want;
  bool _saving = false;

  Future<void> _add() async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    setState(() => _saving = true);
    try {
      await ref.read(repositoryProvider).add(widget.result, _status);
      navigator.pop();
      messenger.showSnackBar(SnackBar(content: Text('Added "${widget.result.title}"')));
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      messenger.showSnackBar(
        const SnackBar(content: Text('Could not add it. Check your connection and try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.result;
    final text = Theme.of(context).textTheme;
    const choices = [Status.want, Status.inProgress, Status.done];

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r.title, style: text.titleLarge),
            if (r.subtitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(r.subtitle, style: text.bodyMedium),
              ),
            const SizedBox(height: 16),
            Text('Add as', style: text.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                for (final s in choices)
                  ChoiceChip(
                    label: Text(statusLabel(r.type, s)),
                    selected: _status == s,
                    onSelected: _saving ? null : (_) => setState(() => _status = s),
                  ),
              ],
            ),
            if (r.type == MediaType.series && _status == Status.done)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'Every episode that has already aired will be marked as watched.',
                  style: text.bodySmall,
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _add,
                child: _saving
                    ? const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 12),
                    Text('Adding...'),
                  ],
                )
                    : const Text('Add'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}