import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import 'app_destination.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.destination, required this.child});

  final AppDestination destination;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    // Back from a top-level destination returns Home; Back on Home exits.
    return PopScope(
      canPop: destination == AppDestination.home,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && destination != AppDestination.home) {
          context.go(AppDestination.home.path);
        }
      },
      child: Scaffold(
        body: SafeArea(child: child),
        bottomNavigationBar: NavigationBar(
          selectedIndex: destination.index,
          onDestinationSelected: (index) {
            final next = AppDestination.values[index];
            if (next != destination) {
              context.go(next.path);
            }
          },
          destinations: [
            for (final item in AppDestination.values)
              NavigationDestination(
                key: ValueKey(item.path),
                icon: Icon(item.icon),
                selectedIcon: Icon(item.selectedIcon),
                label: item.label,
                tooltip: item.label,
              ),
          ],
        ),
      ),
    );
  }
}
