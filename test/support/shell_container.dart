import 'package:dayflow/features/tasks/application/task_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Shell/design tests don't need platform plugins or a database connection.
ProviderContainer shellContainer() {
  final container = ProviderContainer(
    overrides: [
      currentTimeProvider.overrideWithValue(DateTime(2026, 11, 18, 10)),
      tasksOnDateProvider.overrideWith((ref, date) => Stream.value([])),
      activeCategoriesProvider.overrideWith((ref) => Stream.value([])),
    ],
  );
  addTearDown(container.dispose);
  return container;
}
