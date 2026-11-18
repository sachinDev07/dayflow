import '../../../core/utils/local_date.dart';

final class NoteInput {
  const NoteInput({
    required this.content,
    this.title,
    this.date,
    this.categoryId,
    this.linkedTaskId,
  });
  final String content;
  final String? title;
  final LocalDate? date;
  final String? categoryId;
  final String? linkedTaskId;
}

final class NoteEntity {
  const NoteEntity({
    required this.id,
    required this.content,
    required this.isPinned,
    required this.createdAt,
    required this.updatedAt,
    this.title,
    this.date,
    this.categoryId,
    this.linkedTaskId,
    this.deletedAt,
  });
  final String id;
  final String content;
  final String? title;
  final LocalDate? date;
  final String? categoryId;
  final String? linkedTaskId;
  final bool isPinned;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
}
