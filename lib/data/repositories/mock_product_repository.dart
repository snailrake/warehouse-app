import '../models/product.dart';

class MockProductRepository {
  final List<Product> _products = const [
    Product(
      id: 1,
      name: 'Сканер штрихкодов',
      shortDescription: 'Ручной сканер для быстрой приемки товаров.',
      description:
          'Компактный сканер штрихкодов для работы на складе. Подходит для приемки, инвентаризации и быстрой проверки позиций.',
      imagePath: 'assets/images/product_placeholder.png',
      status: ProductStatus.available,
    ),
    Product(
      id: 2,
      name: 'Терминал сбора данных',
      shortDescription: 'Мобильное устройство для учета остатков.',
      description:
          'Терминал помогает сотрудникам склада сканировать товары, сверять остатки и быстро обновлять информацию по позициям.',
      imagePath: 'assets/images/product_placeholder.png',
      status: ProductStatus.reserved,
    ),
    Product(
      id: 3,
      name: 'Принтер этикеток',
      shortDescription: 'Печать маркировки и складских стикеров.',
      description:
          'Настольный принтер этикеток для маркировки товара, коробок и полок. Удобен для повседневной работы на складе.',
      imagePath: 'assets/images/product_placeholder.png',
      status: ProductStatus.available,
    ),
    Product(
      id: 4,
      name: 'Погрузочная тележка',
      shortDescription: 'Тележка для перемещения коробок по складу.',
      description:
          'Прочная складская тележка для перемещения грузов между зонами хранения и отгрузки. Подходит для ежедневной эксплуатации.',
      imagePath: 'assets/images/product_placeholder.png',
      status: ProductStatus.reserved,
    ),
  ];

  List<Product> getProducts() {
    return List<Product>.from(_products);
  }
}
