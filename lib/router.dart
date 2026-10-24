import 'package:go_router/go_router.dart';

import 'stats/stats_models.dart';
import 'ui/genre_screen.dart';
import 'ui/home_shell.dart';
import 'ui/item_detail_screen.dart';
import 'ui/list_detail_screen.dart';
import 'ui/stats_screen.dart';

/// All app addresses live here.
final appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeShell(),
    ),
    GoRoute(
      path: '/item/:id',
      builder: (context, state) => ItemDetailScreen(
        id: int.parse(state.pathParameters['id']!),
      ),
    ),
    // /genre?name=Drama
    GoRoute(
      path: '/genre',
      builder: (context, state) => GenreScreen(
        genre: state.uri.queryParameters['name'] ?? '',
      ),
    ),
    GoRoute(
      path: '/list/:id',
      builder: (context, state) => ListDetailScreen(
        id: int.parse(state.pathParameters['id']!),
      ),
    ),
    // /stats?period=month
    GoRoute(
      path: '/stats',
      builder: (context, state) {
        final name = state.uri.queryParameters['period'];
        final period = StatsPeriod.values.where((p) => p.name == name).firstOrNull ??
            StatsPeriod.month;
        return StatsScreen(initialPeriod: period);
      },
    ),
  ],
);