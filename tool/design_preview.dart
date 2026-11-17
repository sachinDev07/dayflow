// Developer-only component preview. This is not part of product navigation.
// flutter run -t tool/design_preview.dart -d <android-device-id>
import 'package:dayflow/app/theme/app_theme.dart';
import 'package:dayflow/app/licenses.dart';
import 'package:dayflow/app/theme/design_tokens.dart';
import 'package:dayflow/core/widgets/dayflow_brand.dart';
import 'package:dayflow/core/widgets/dayflow_button.dart';
import 'package:dayflow/core/widgets/dayflow_empty_state.dart';
import 'package:dayflow/core/widgets/dayflow_sheet.dart';
import 'package:dayflow/core/widgets/dayflow_surface.dart';
import 'package:dayflow/core/widgets/dayflow_text_field.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  registerFontLicenses();
  runApp(const DesignPreview());
}

class DesignPreview extends StatefulWidget {
  const DesignPreview({super.key});

  @override
  State<DesignPreview> createState() => _DesignPreviewState();
}

class _DesignPreviewState extends State<DesignPreview> {
  bool _dark = false;

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    darkTheme: buildAppTheme(brightness: Brightness.dark),
    themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
    home: Builder(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: const Text('Component preview'),
          actions: [
            IconButton(
              tooltip: _dark ? 'Preview light theme' : 'Preview dark theme',
              onPressed: () => setState(() => _dark = !_dark),
              icon: Icon(_dark ? LucideIcons.sun : LucideIcons.moon),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(DayflowSpace.page),
          children: [
            const DayflowBrand(),
            const SizedBox(height: DayflowSpace.xl),
            const DayflowSurface(
              accent: true,
              child: Text(
                'Design preview only. These controls do not create or store tasks.',
              ),
            ),
            const SizedBox(height: DayflowSpace.xl),
            const DayflowTextField(
              label: 'Example title',
              hint: 'What would you like to do?',
            ),
            const SizedBox(height: DayflowSpace.lg),
            DayflowButton(
              label: 'Preview sheet',
              icon: LucideIcons.plus,
              onPressed: () => showDayflowSheet<void>(
                context: context,
                builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sheet preview',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: DayflowSpace.xl),
                    const DayflowTextField(
                      label: 'Example title',
                      autofocus: true,
                    ),
                    const SizedBox(height: DayflowSpace.xl),
                    DayflowButton(
                      label: 'Close preview',
                      icon: LucideIcons.check,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: DayflowSpace.lg),
            const DayflowButton(label: 'Disabled action', onPressed: null),
            const SizedBox(height: DayflowSpace.xl),
            const DayflowSurface(
              child: DayflowEmptyState(
                title: 'Space for what matters',
                description: 'A preview of the shared empty-state component.',
                icon: LucideIcons.clipboardList,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
