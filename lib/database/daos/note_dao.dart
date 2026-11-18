part of '../app_database.dart';

@DriftAccessor(tables: [Notes])
class NoteDao extends DatabaseAccessor<AppDatabase> with _$NoteDaoMixin {
  NoteDao(super.db);

  Future<NoteRecord?> find(String id, {bool includeDeleted = false}) =>
      (select(notes)..where(
            (n) =>
                n.id.equals(id) &
                (includeDeleted ? const Constant(true) : n.deletedAt.isNull()),
          ))
          .getSingleOrNull();
  SimpleSelectStatement<$NotesTable, NoteRecord> _active() => select(notes)
    ..where((n) => n.deletedAt.isNull())
    ..orderBy([
      (n) => OrderingTerm.desc(n.isPinned),
      (n) => OrderingTerm.desc(n.updatedAt),
      (n) => OrderingTerm.asc(n.id),
    ]);
  Future<List<NoteRecord>> all() => _active().get();
  Stream<List<NoteRecord>> watchAll() => _active().watch();
  Future<List<NoteRecord>> onDate(String date) =>
      (_active()..where((n) => n.noteDate.equals(date))).get();
  Future<void> add(NotesCompanion values) async => into(notes).insert(values);
  Future<int> change(String id, NotesCompanion values) =>
      (update(notes)..where((n) => n.id.equals(id))).write(values);
}
