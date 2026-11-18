import 'dart:io';

/// Delete only a resolved, uniquely-created DAYFLOW directory directly in temp.
Future<void> removeOwnedTestDirectory(Directory directory) async {
  final target = await directory.resolveSymbolicLinks();
  final temporaryRoot = await Directory.systemTemp.resolveSymbolicLinks();
  final parent = Directory(target).parent.path;
  final expectedPrefix = '$temporaryRoot${Platform.pathSeparator}dayflow-';
  if (parent.toLowerCase() != temporaryRoot.toLowerCase() ||
      !target.toLowerCase().startsWith(expectedPrefix.toLowerCase())) {
    throw StateError(
      'Refusing to delete a directory outside the owned test scope: $target',
    );
  }
  await Directory(target).delete(recursive: true);
}
