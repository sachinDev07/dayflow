import 'package:material_ui/material_ui.dart';

import 'app_destination.dart';
import '../theme/design_tokens.dart';
import '../../core/widgets/dayflow_empty_state.dart';
import '../../core/widgets/dayflow_surface.dart';

class DestinationPlaceholder extends StatelessWidget {
  const DestinationPlaceholder({super.key, required this.destination});

  final AppDestination destination;

  String get _description => switch (destination) {
    AppDestination.home => 'Your day. Your pace. Your progress.',
    AppDestination.calendar => 'A little perspective on the days ahead.',
    AppDestination.notes => 'A quiet place for thoughts worth keeping.',
    AppDestination.insights => 'See your progress, at your own pace.',
    AppDestination.settings => 'Make DAYFLOW feel right for you.',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DayflowSpace.page),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(destination.label, style: theme.textTheme.headlineMedium),
              const SizedBox(height: DayflowSpace.sm),
              Text(_description, style: theme.textTheme.bodyMedium),
              const SizedBox(height: DayflowSpace.xxl),
              DayflowSurface(
                child: SizedBox(
                  width: double.infinity,
                  child: DayflowEmptyState(
                    title: 'Coming soon',
                    description:
                        '${destination.label}, with a little more room to focus.',
                    icon: destination.icon,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
