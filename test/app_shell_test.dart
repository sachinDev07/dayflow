import 'package:dayflow/app/app.dart';
import 'package:dayflow/app/router/app_router.dart';
import 'package:dayflow/app/shell/app_destination.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import 'support/shell_container.dart';

void main() {
  testWidgets('Launches Home and navigates all five destinations', (
    tester,
  ) async {
    final container = shellContainer();
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const DayflowApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('DAYFLOW'), findsOneWidget);
    expect(find.text('Your day. Your pace. Your progress.'), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(5));

    for (final destination in AppDestination.values.skip(1)) {
      await tester.tap(find.byKey(ValueKey(destination.path)));
      await tester.pumpAndSettle();
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        destination.index,
      );
      expect(find.text('Coming soon'), findsOneWidget);
      expect(container.read(appRouterProvider).canPop(), isFalse);
    }

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('DAYFLOW'), findsOneWidget);
    expect(
      tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
      0,
    );
  });

  testWidgets('Shell fits a small screen with large text', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: shellContainer(),
        child: const DayflowApp(),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    for (final destination in AppDestination.values.skip(1)) {
      await tester.tap(find.byKey(ValueKey(destination.path)));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
  });
}
