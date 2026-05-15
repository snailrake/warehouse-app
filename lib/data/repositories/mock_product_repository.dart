import '../models/product.dart';
import '../product_defaults.dart';
import 'product_repository.dart';

class MockProductRepository implements ProductRepository {
  int _nextId = 5;

  final List<Product> _products = [
    Product(
      id: 1,
      name: 'Сканер штрихкодов',
      shortDescription: 'Ручной сканер для быстрой приемки товаров.',
      description:
          'Компактный сканер штрихкодов для работы на складе. Подходит для приемки, инвентаризации и быстрой проверки позиций.',
      imagePath: ProductDefaults.placeholderImagePath,
      status: ProductStatus.available,
      takenByUserId: null,
      takenAt: null,
    ),
    Product(
      id: 2,
      name: 'Терминал сбора данных',
      shortDescription: 'Мобильное устройство для учета остатков.',
      description:
          'Терминал помогает сотрудникам склада сканировать товары, сверять остатки и быстро обновлять информацию по позициям.',
      imagePath: ProductDefaults.placeholderImagePath,
      status: ProductStatus.reserved,
      takenByUserId: 1,
      takenAt: DateTime.now(),
    ),
    Product(
      id: 3,
      name: 'Принтер этикеток',
      shortDescription: 'Печать маркировки и складских стикеров.',
      description:
          'Настольный принтер этикеток для маркировки товара, коробок и полок. Удобен для повседневной работы на складе.',
      imagePath: ProductDefaults.placeholderImagePath,
      status: ProductStatus.available,
      takenByUserId: null,
      takenAt: null,
    ),
    Product(
      id: 4,
      name: 'Погрузочная тележка',
      shortDescription: 'Тележка для перемещения коробок по складу.',
      description:
          'Прочная складская тележка для перемещения грузов между зонами хранения и отгрузки. Подходит для ежедневной эксплуатации.',
      imagePath: ProductDefaults.placeholderImagePath,
      status: ProductStatus.reserved,
      takenByUserId: 1,
      takenAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  @override
  Future<List<Product>> getProducts() async {
    return List<Product>.unmodifiable(_products);
  }

  @override
  Future<Product?> getProductById(int id) async {
    for (final product in _products) {
      if (product.id == id) {
        return product;
      }
    }
    return null;
  }

  @override
  Future<Product> addProduct({
    required String name,
    required String shortDescription,
    required String description,
    required String imagePath,
    required ProductStatus status,
  }) async {
    final product = Product(
      id: _nextId,
      name: name,
      shortDescription: shortDescription,
      description: description,
      imagePath: imagePath,
      status: status,
      takenByUserId: null,
      takenAt: null,
    );

    _nextId++;
    _products.insert(0, product);
    return product;
  }

  @override
  Future<ProductTakeResult> toggleTakeReturn({
    required int productId,
    required int userId,
  }) async {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index < 0) {
      throw StateError('Product not found: $productId');
    }

    final current = _products[index];
    final now = DateTime.now();

    if (current.status == ProductStatus.available) {
      final updated = Product(
        id: current.id,
        name: current.name,
        shortDescription: current.shortDescription,
        description: current.description,
        imagePath: current.imagePath,
        status: ProductStatus.reserved,
        takenByUserId: userId,
        takenAt: now,
      );
      _products[index] = updated;
      return ProductTakeResult(product: updated, action: 'take');
    }

    final updated = Product(
      id: current.id,
      name: current.name,
      shortDescription: current.shortDescription,
      description: current.description,
      imagePath: current.imagePath,
      status: ProductStatus.available,
      takenByUserId: null,
      takenAt: null,
    );
    _products[index] = updated;
    return ProductTakeResult(product: updated, action: 'return');
  }
}
