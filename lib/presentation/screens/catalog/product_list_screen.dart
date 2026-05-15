import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/product.dart';
import '../../../data/repositories/product_repository.dart';
import '../../controllers/auth_controller.dart';
import '../../widgets/product_image.dart';
import '../qr/qr_scanner_screen.dart';
import 'add_product_screen.dart';
import 'product_details_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({
    super.key,
    required this.productRepository,
  });

  final ProductRepository productRepository;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = widget.productRepository.getProducts();
  }

  void _reload() {
    setState(() {
      _productsFuture = widget.productRepository.getProducts();
    });
  }

  Future<void> _openAddProduct() async {
    final authController = context.read<AuthController>();
    if (!authController.canCreateProducts) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('У вас нет прав на создание товаров.')),
        );
      return;
    }

    final changed = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AddProductScreen(
          productRepository: widget.productRepository,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (changed == true) {
      _reload();
    }
  }

  Future<void> _openQrScanner() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => QrScannerScreen(
          productRepository: widget.productRepository,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final user = authController.currentUser;
    final userName = user?.name ?? 'Пользователь';
    final roleText = user?.role.name == 'admin' ? 'администратор' : 'сотрудник';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог товаров'),
        actions: [
          IconButton(
            tooltip: authController.canCreateProducts
                ? 'Добавить товар'
                : 'Нет прав на добавление',
            onPressed:
                authController.canCreateProducts ? _openAddProduct : null,
            icon: const Icon(Icons.add),
          ),
          IconButton(
            tooltip: 'Сканировать QR',
            onPressed: _openQrScanner,
            icon: const Icon(Icons.qr_code_scanner),
          ),
          IconButton(
            tooltip: 'Выйти',
            onPressed: () => authController.logout(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Ошибка загрузки: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final products = snapshot.data ?? const <Product>[];

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Пользователь: $userName ($roleText)',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }

              final product = products[index - 1];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _ProductCard(product: product),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ProductImage(
          imagePath: product.imagePath,
          width: 64,
          height: 64,
        ),
        title: Text(product.name),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Text(product.shortDescription),
        ),
        trailing: Text(
          product.status == ProductStatus.available ? 'Доступен' : 'Взят',
          style: TextStyle(
            color: product.status == ProductStatus.available
                ? Colors.green
                : Colors.red,
            fontWeight: FontWeight.w600,
          ),
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => ProductDetailsScreen(
                productId: product.id,
              ),
            ),
          );
        },
      ),
    );
  }
}
