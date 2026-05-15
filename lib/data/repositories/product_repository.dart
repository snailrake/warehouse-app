import '../models/product.dart';

class ProductTakeResult {
  const ProductTakeResult({
    required this.product,
    required this.action,
  });

  final Product product;

  final String action;
}

abstract class ProductRepository {
  Future<List<Product>> getProducts();

  Future<Product?> getProductById(int id);

  Future<Product> addProduct({
    required String name,
    required String shortDescription,
    required String description,
    required String imagePath,
    required ProductStatus status,
  });

  Future<ProductTakeResult> toggleTakeReturn({
    required int productId,
    required int userId,
  });
}
