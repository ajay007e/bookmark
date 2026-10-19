import 'package:go_router/go_router.dart';

import 'ui/home_shell.dart';
import 'ui/item_detail_screen.dart';

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
  ],
);