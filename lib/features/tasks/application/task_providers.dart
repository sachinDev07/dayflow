import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/local_date.dart';
import '../../../database/database_providers.dart';
import '../../settings/domain/category_entity.dart';
import '../domain/task_entity.dart';

/// Injectable local clock; refresh on resume as well as while the app is open.
final localClockProvider = Provider<DateTime Function()>((ref) => DateTime.now);
final currentTimeProvider = Provider<DateTime>((ref) {
  final timer = Timer(const Duration(minutes: 1), ref.invalidateSelf);
  ref.onDispose(timer.cancel);
  return ref.watch(localClockProvider)();
});

final tasksOnDateProvider = StreamProvider.autoDispose
    .family<List<TaskEntity>, LocalDate>(
      (ref, date) => ref.watch(taskRepositoryProvider).watchDate(date),
    );

final activeCategoriesProvider =
    StreamProvider.autoDispose<List<CategoryEntity>>(
      (ref) => ref.watch(categoryRepositoryProvider).watchAll(),
    );
