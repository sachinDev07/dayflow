import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/home/presentation/home_screen.dart';
import '../shell/app_destination.dart';
import '../shell/app_shell.dart';
import '../shell/destination_placeholder.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: AppDestination.home.path,
    routes: [
      GoRoute(path: '/', redirect: (context, state) => '/home'),
      ShellRoute(
        builder: (context, state, child) => AppShell(
          destination: AppDestination.fromPath(state.uri.path),
          child: child,
        ),
        routes: [
          for (final destination in AppDestination.values)
            GoRoute(
              path: destination.path,
              pageBuilder: (context, state) => NoTransitionPage<void>(
                key: state.pageKey,
                child: destination == AppDestination.home
                    ? const HomeScreen()
                    : DestinationPlaceholder(destination: destination),
              ),
            ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
