import 'package:drift/drift.dart';

import '../../../core/utils/local_date.dart';
import '../../../database/app_database.dart';
import '../../../database/repository_guards.dart';
import '../../../database/write_metadata.dart';
import '../domain/note_entity.dart';
import '../domain/note_repository.dart';

final class SqliteNoteRepository implements NoteRepository {
  SqliteNoteRepository(this._db, this._metadata);
  final AppDatabase _db;
  final WriteMetadata _metadata;

  @override
  Future<NoteEntity> create(NoteInput input) => _db.transaction(() async {
    await requireActiveCategory(_db, input.categoryId);
    await requireActiveTask(_db, input.linkedTaskId);
    final id = _metadata.newId();
    final now = _metadata.timestamp();
    await _db.noteDao.add(
      NotesCompanion.insert(
        id: id,
        content: input.content,
        title: Value(_title(input.title)),
        noteDate: Value(input.date?.toString()),
        categoryId: Value(input.categoryId),
        linkedTaskId: Value(input.linkedTaskId),
        createdAt: now,
        updatedAt: now,
      ),
    );
    return _map((await _db.noteDao.find(id))!);
  });
  @override
  Future<NoteEntity?> get(String id, {bool includeDeleted = false}) async {
    final row = await _db.noteDao.find(id, includeDeleted: includeDeleted);
    return row == null ? null : _map(row);
  }

  @override
  Future<List<NoteEntity>> all() async =>
      (await _db.noteDao.all()).map(_map).toList(growable: false);
  @override
  Stream<List<NoteEntity>> watchAll() => _db.noteDao.watchAll().map(
    (rows) => rows.map(_map).toList(growable: false),
  );
  @override
  Future<List<NoteEntity>> onDate(LocalDate date) async =>
      (await _db.noteDao.onDate(date.toString()))
          .map(_map)
          .toList(growable: false);

  @override
  Future<NoteEntity> update(String id, NoteInput input) =>
      _db.transaction(() async {
        final row = await _required(id);
        if (input.categoryId != row.categoryId) {
          await requireActiveCategory(_db, input.categoryId);
        }
        if (input.linkedTaskId != row.linkedTaskId) {
          await requireActiveTask(_db, input.linkedTaskId);
        }
        await _db.noteDao.change(
          id,
          NotesCompanion(
            title: Value(_title(input.title)),
            content: Value(input.content),
            noteDate: Value(input.date?.toString()),
            categoryId: Value(input.categoryId),
            linkedTaskId: Value(input.linkedTaskId),
            updatedAt: Value(_metadata.timestamp(after: row.updatedAt)),
          ),
        );
        return _map((await _db.noteDao.find(id))!);
      });
  @override
  Future<NoteEntity> setPinned(String id, bool pinned) =>
      _db.transaction(() async {
        final row = await _required(id);
        if (row.isPinned == pinned) return _map(row);
        await _db.noteDao.change(
          id,
          NotesCompanion(
            isPinned: Value(pinned),
            updatedAt: Value(_metadata.timestamp(after: row.updatedAt)),
          ),
        );
        return _map((await _db.noteDao.find(id))!);
      });
  @override
  Future<void> softDelete(String id) => _setDeleted(id, true);
  @override
  Future<void> restore(String id) => _setDeleted(id, false);
  Future<void> _setDeleted(String id, bool deleted) =>
      _db.transaction(() async {
        final row = await _required(id, includeDeleted: true);
        if ((row.deletedAt != null) == deleted) return;
        final now = _metadata.timestamp(after: row.updatedAt);
        await _db.noteDao.change(
          id,
          NotesCompanion(
            deletedAt: Value(deleted ? now : null),
            updatedAt: Value(now),
          ),
        );
      });
  Future<NoteRecord> _required(
    String id, {
    bool includeDeleted = false,
  }) async =>
      await _db.noteDao.find(id, includeDeleted: includeDeleted) ??
      (throw StateError('Note is missing or deleted: $id'));
  String? _title(String? title) =>
      title == null || title.trim().isEmpty ? null : title.trim();
  NoteEntity _map(NoteRecord row) => NoteEntity(
    id: row.id,
    title: row.title,
    content: row.content,
    date: row.noteDate == null ? null : LocalDate.parse(row.noteDate!),
    categoryId: row.categoryId,
    linkedTaskId: row.linkedTaskId,
    isPinned: row.isPinned,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
    deletedAt: row.deletedAt,
  );
}
