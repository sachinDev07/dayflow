import '../../../core/utils/local_date.dart';
import 'note_entity.dart';

abstract interface class NoteRepository {
  Future<NoteEntity> create(NoteInput input);
  Future<NoteEntity?> get(String id, {bool includeDeleted = false});
  Future<List<NoteEntity>> all();
  Stream<List<NoteEntity>> watchAll();
  Future<List<NoteEntity>> onDate(LocalDate date);
  Future<NoteEntity> update(String id, NoteInput input);
  Future<NoteEntity> setPinned(String id, bool pinned);
  Future<void> softDelete(String id);
  Future<void> restore(String id);
}
