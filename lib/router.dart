import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'api/search_result.dart';
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
    // An item that is not in the library yet. The search result comes in `extra`.
    GoRoute(
      path: '/preview',
      builder: (context, state) {
        final result = state.extra;
        if (result is! SearchResult) {
          return const Scaffold(body: Center(child: Text('Nothing to show.')));
        }
        return ItemDetailScreen.preview(result: result);
      },
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