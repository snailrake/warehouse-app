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
  });

  final int id;
  final String name;
  final String shortDescription;
  final String description;
  final String imagePath;
  final ProductStatus status;
}
