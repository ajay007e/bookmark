import 'package:flutter/material.dart';

import '../../data/app_database.dart';
import '../series_actions.dart';

const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

/// One episode row with a checkbox. Episodes that have not aired are greyed out.
class EpisodeTile extends StatelessWidget {
  const EpisodeTile({super.key, required this.episode, required this.onChanged});

  final Episode episode;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final e = episode;
    final air = e.airDate;
    final aired = isAired(e, DateTime.now());
    final name = e.title ?? 'Episode ${e.episodeNumber}';

    final subtitle = aired
        ? formatDate(air!)
        : (air == null ? 'Air date not announced' : 'Airs ${formatDate(air)}');

    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.trailing,
      value: e.watched,
      onChanged: aired ? (v) => onChanged(v ?? false) : null,
      title: Text('${e.episodeNumber}. $name', maxLines: 2, overflow: TextOverflow.ellipsis),
      subtitle: Text(subtitle),
    );
  }
}