import 'package:dayflow/app/app.dart';
import 'package:dayflow/app/theme/app_theme.dart';
import 'package:dayflow/app/theme/design_tokens.dart';
import 'package:dayflow/core/widgets/dayflow_button.dart';
import 'package:dayflow/core/widgets/dayflow_launch_reveal.dart';
import 'package:dayflow/core/widgets/dayflow_logo.dart';
import 'package:dayflow/core/widgets/dayflow_sheet.dart';
import 'package:dayflow/core/widgets/dayflow_text_field.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/shell_container.dart';

double contrast(Color a, Color b) {
  final x = a.computeLuminance();
  final y = b.computeLuminance();
  return (x > y ? x + 0.05 : y + 0.05) / (x > y ? y + 0.05 : x + 0.05);
}

void main() {
  test('Both themes keep normal text and primary actions readable', () {
    for (final brightness in Brightness.values) {
      final theme = buildAppTheme(brightness: brightness);
      final colors = theme.extension<DayflowColors>()!;
      for (final background in [
        colors.canvas,
        colors.surface,
        colors.accentSurface,
      ]) {
        expect(contrast(colors.text, background), greaterThanOrEqualTo(4.5));
        expect(
          contrast(colors.secondaryText, background),
          greaterThanOrEqualTo(4.5),
        );
      }
      expect(
        contrast(colors.onAction, colors.actionStart),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(colors.onAction, colors.actionEnd),
        greaterThanOrEqualTo(4.5),
      );
      expect(
        contrast(theme.colorScheme.primary, colors.canvas),
        greaterThanOrEqualTo(4.5),
      );
    }
  });

  testWidgets(
    'Approved logo and offline font are included in the asset bundle',
    (tester) async {
      final logo = await rootBundle.load(DayflowLogo.asset);
      expect(logo.getUint32(0), 0x89504E47);
      final font = await rootBundle.load(
        'assets/fonts/PlusJakartaSans-Variable.ttf',
      );
      expect(font.getUint32(0), 0x00010000);
    },
  );

  testWidgets(
    'Light is the default even on a dark device; explicit modes work',
    (tester) async {
      tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
      addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
      final container = shellContainer();
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const DayflowApp(),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.byType(NavigationBar))).brightness,
        Brightness.light,
      );
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const DayflowApp(themeMode: ThemeMode.system),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        Theme.of(tester.element(find.byType(NavigationBar))).brightness,
        Brightness.dark,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Reduced motion reveals the ready UI immediately', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(disableAnimations: true),
          child: const DayflowLaunchReveal(child: Text('Ready')),
        ),
      ),
    );
    final fade = tester.widget<FadeTransition>(
      find.descendant(
        of: find.byType(DayflowLaunchReveal),
        matching: find.byType(FadeTransition),
      ),
    );
    expect(fade.opacity.value, 1);
    expect(find.text('Ready'), findsOneWidget);
  });

  testWidgets(
    'Sheet input validates and action remains reachable at large text size',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      final formKey = GlobalKey<FormState>();
      var accepted = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: buildAppTheme(),
          home: Builder(
            builder: (context) => Scaffold(
              body: DayflowButton(
                label: 'Open sheet',
                onPressed: () => showDayflowSheet<void>(
                  context: context,
                  builder: (context) => Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DayflowTextField(
                          label: 'Title',
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Enter a title'
                              : null,
                        ),
                        const SizedBox(height: 24),
                        DayflowButton(
                          label: 'Continue',
                          onPressed: () {
                            accepted = formKey.currentState!.validate();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open sheet'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a title'), findsOneWidget);
      expect(accepted, isFalse);
      await tester.enterText(find.byType(TextFormField), 'A sample title');
      await tester.ensureVisible(find.text('Continue'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(accepted, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Disabled primary action does not invoke an action', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: buildAppTheme(),
        home: const Scaffold(
          body: DayflowButton(label: 'Unavailable', onPressed: null),
        ),
      ),
    );
    final ink = tester.widget<InkWell>(find.byType(InkWell));
    expect(ink.onTap, isNull);
  });
}
