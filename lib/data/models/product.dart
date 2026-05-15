enum ProductStatus {
  available,
  reserved,
}

class Product {
  const Product({
    required this.id,
    required this.name,
    required this.shortDescription,
    required this.description,
    required this.imagePath,
    required this.status,
    required this.takenByUserId,
    required this.takenAt,
  });

  final int id;
  final String name;
  final String shortDescription;
  final String description;
  final String imagePath;
  final ProductStatus status;
  final int? takenByUserId;
  final DateTime? takenAt;

  static Product fromDb(Map<String, Object?> row) {
    final statusRaw =
        (row['status'] as String?) ?? ProductStatus.available.name;
    final status = ProductStatus.values.firstWhere(
      (s) => s.name == statusRaw,
      orElse: () => ProductStatus.available,
    );

    final takenAtRaw = row['taken_at'] as String?;

    return Product(
      id: row['id'] as int,
      name: row['name'] as String,
      shortDescription: row['short_description'] as String,
      description: row['description'] as String,
      imagePath: row['image_path'] as String,
      status: status,
      takenByUserId: row['taken_by_user_id'] as int?,
      takenAt: takenAtRaw == null ? null : DateTime.tryParse(takenAtRaw),
    );
  }
}
