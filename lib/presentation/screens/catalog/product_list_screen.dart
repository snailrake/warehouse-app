import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/product.dart';
import '../../../data/repositories/mock_product_repository.dart';
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

  final MockProductRepository productRepository;

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  Future<void> _openAddProduct() async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => AddProductScreen(
          productRepository: widget.productRepository,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    setState(() {});
  }

  Future<void> _openQrScanner() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => QrScannerScreen(
          productRepository: widget.productRepository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final products = widget.productRepository.getProducts();
    final userName =
        context.read<AuthController>().currentUser?.name ?? 'Пользователь';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог товаров'),
        actions: [
          IconButton(
            tooltip: 'Добавить товар',
            onPressed: _openAddProduct,
            icon: const Icon(Icons.add),
          ),
          IconButton(
            tooltip: 'Сканировать QR',
            onPressed: _openQrScanner,
            icon: const Icon(Icons.qr_code_scanner),
          ),
          IconButton(
            tooltip: 'Выйти',
            onPressed: () => context.read<AuthController>().logout(),
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: products.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                'Пользователь: $userName',
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
          product.status == ProductStatus.available ? 'Свободен' : 'Занят',
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
              builder: (_) => ProductDetailsScreen(product: product),
            ),
          );
        },
      ),
    );
  }
}
