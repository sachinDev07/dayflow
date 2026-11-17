import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../core/widgets/dayflow_brand.dart';
import '../../core/widgets/dayflow_launch_reveal.dart';
import '../theme/design_tokens.dart';
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
        body: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  DayflowSpace.page,
                  DayflowSpace.sm,
                  DayflowSpace.md,
                  DayflowSpace.sm,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: DayflowLaunchReveal(child: DayflowBrand()),
                    ),
                    if (destination != AppDestination.settings)
                      IconButton(
                        tooltip: 'Open settings',
                        onPressed: () =>
                            context.go(AppDestination.settings.path),
                        icon: const Icon(LucideIcons.circleUserRound, size: 24),
                      ),
                  ],
                ),
              ),
              Expanded(child: child),
            ],
          ),
        ),
        bottomNavigationBar: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: DayflowColors.of(context).divider),
            ),
          ),
          child: NavigationBar(
            animationDuration: MediaQuery.disableAnimationsOf(context)
                ? Duration.zero
                : DayflowMotion.interaction,
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
      ),
    );
  }
}
