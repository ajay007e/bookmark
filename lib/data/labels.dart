import 'app_database.dart';

String statusLabel(MediaType type, Status status) {
  final book = type == MediaType.book;
  switch (status) {
    case Status.want:
      return book ? 'Want to read' : 'Want to watch';
    case Status.inProgress:
      return book ? 'Reading' : 'Watching';
    case Status.done:
      return book ? 'Read' : 'Watched';
    case Status.dropped:
      return 'Did not complete';
  }
}