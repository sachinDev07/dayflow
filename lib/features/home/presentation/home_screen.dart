import 'package:material_ui/material_ui.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../app/theme/design_tokens.dart';
import '../../../core/widgets/dayflow_empty_state.dart';
import '../../../core/widgets/dayflow_surface.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hour = TimeOfDay.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
        ? 'Good afternoon'
        : 'Good evening';
    return SingleChildScrollView(
      padding: const EdgeInsets.all(DayflowSpace.page),
      child: Align(
        alignment: Alignment.topLeft,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(greeting, style: theme.textTheme.headlineMedium),
              const SizedBox(height: DayflowSpace.sm),
              Text(
                'Your day. Your pace. Your progress.',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: DayflowSpace.xxl),
              const DayflowSurface(
                child: SizedBox(
                  width: double.infinity,
                  child: DayflowEmptyState(
                    title: 'A calm place to begin',
                    description:
                        'Make room for what matters, one day at a time.',
                    icon: LucideIcons.clipboardList,
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
