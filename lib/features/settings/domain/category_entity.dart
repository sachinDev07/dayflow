final class CategoryInput {
  const CategoryInput({required this.name, required this.color});
  final String name;

  /// An opaque sRGB color encoded as 0xRRGGBB, independent of Flutter.
  final int color;
  void validate() {
    if (name.trim().isEmpty) {
      throw ArgumentError.value(name, 'name', 'Required');
    }
    if (color < 0 || color > 0xFFFFFF) {
      throw ArgumentError.value(color, 'color');
    }
  }
}

final class CategoryEntity {
  const CategoryEntity({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });
  final String id;
  final String name;
  final int color;
  final int createdAt;
  final int updatedAt;
  final int? deletedAt;
}
