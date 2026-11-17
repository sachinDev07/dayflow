import 'package:material_ui/material_ui.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

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
              // Text branding until the exact approved logo is supplied in M2.
              Text(
                'DAYFLOW',
                style: theme.textTheme.labelLarge?.copyWith(letterSpacing: 2),
              ),
              const SizedBox(height: 40),
              Text(
                'Make room for your day.',
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Your day. Your pace. Your progress.',
                style: theme.textTheme.bodyLarge,
              ),
              const SizedBox(height: 32),
              Text(
                'A calm place for your daily tasks.',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
