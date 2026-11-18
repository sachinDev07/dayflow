import 'dart:io';

import 'package:drift_flutter/drift_flutter.dart';
import 'package:path_provider/path_provider.dart';

import 'app_database.dart';

abstract final class DatabaseStorage {
  static const name = 'dayflow';
  static const fileName = '$name.sqlite';

  /// On Android this is Context.filesDir/dayflow.sqlite, never getDatabasePath().
  static Future<String> path() async {
    final directory = await getApplicationSupportDirectory();
    return '${directory.path}${Platform.pathSeparator}$fileName';
  }
}

/// drift_flutter performs SQLite IO on one background Dart isolate, not a
/// separate Android process. No WAL/read pool is enabled in this milestone.
AppDatabase openAppDatabase() => AppDatabase(
  driftDatabase(
    name: DatabaseStorage.name,
    native: DriftNativeOptions(databasePath: DatabaseStorage.path),
  ),
);
