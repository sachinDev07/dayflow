import 'package:uuid/uuid.dart';

/// Keeps UUID creation and wall-clock access injectable for deterministic tests.
final class WriteMetadata {
  WriteMetadata({int Function()? now, String Function()? newId})
    : _now = now ?? (() => DateTime.now().toUtc().millisecondsSinceEpoch),
      _newId = newId ?? const Uuid().v4;
  final int Function() _now;
  final String Function() _newId;

  String newId() => _newId();
  int timestamp({int after = 0}) {
    final now = _now();
    if (now < 0) {
      throw StateError('The clock must return UTC epoch milliseconds.');
    }
    return now < after ? after : now;
  }
}
