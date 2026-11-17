import 'package:material_ui/material_ui.dart';

import 'app_destination.dart';

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
      padding: const EdgeInsets.all(24),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(destination.label, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 16),
              Text(_description, style: theme.textTheme.bodyLarge),
              const SizedBox(height: 32),
              Text('Coming soon', style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
