import '../models/product.dart';

class MockProductRepository {
  static const placeholderImagePath = 'assets/images/product_placeholder.png';

  MockProductRepository() {
    final maxId = _products.fold<int>(0, (max, product) {
      return product.id > max ? product.id : max;
    });
    _nextId = maxId + 1;
  }

  late int _nextId;

  final List<Product> _products = [
    Product(
      id: 1,
      name: 'Сканер штрихкодов',
      shortDescription: 'Ручной сканер для быстрой приемки товаров.',
      description:
          'Компактный сканер штрихкодов для работы на складе. Подходит для приемки, инвентаризации и быстрой проверки позиций.',
      imagePath: placeholderImagePath,
      status: ProductStatus.available,
    ),
    Product(
      id: 2,
      name: 'Терминал сбора данных',
      shortDescription: 'Мобильное устройство для учета остатков.',
      description:
          'Терминал помогает сотрудникам склада сканировать товары, сверять остатки и быстро обновлять информацию по позициям.',
      imagePath: placeholderImagePath,
      status: ProductStatus.reserved,
    ),
    Product(
      id: 3,
      name: 'Принтер этикеток',
      shortDescription: 'Печать маркировки и складских стикеров.',
      description:
          'Настольный принтер этикеток для маркировки товара, коробок и полок. Удобен для повседневной работы на складе.',
      imagePath: placeholderImagePath,
      status: ProductStatus.available,
    ),
    Product(
      id: 4,
      name: 'Погрузочная тележка',
      shortDescription: 'Тележка для перемещения коробок по складу.',
      description:
          'Прочная складская тележка для перемещения грузов между зонами хранения и отгрузки. Подходит для ежедневной эксплуатации.',
      imagePath: placeholderImagePath,
      status: ProductStatus.reserved,
    ),
  ];

  List<Product> getProducts() {
    return List<Product>.unmodifiable(_products);
  }

  Product? getProductById(int id) {
    for (final product in _products) {
      if (product.id == id) {
        return product;
      }
    }

    return null;
  }

  Product addProduct({
    required String name,
    required String shortDescription,
    required String description,
    required String imagePath,
    required ProductStatus status,
  }) {
    final product = Product(
      id: _nextId,
      name: name,
      shortDescription: shortDescription,
      description: description,
      imagePath: imagePath,
      status: status,
    );

    _products.insert(0, product);
    _nextId++;
    return product;
  }
}
