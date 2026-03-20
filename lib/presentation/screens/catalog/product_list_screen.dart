import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/product.dart';
import '../../../data/repositories/mock_product_repository.dart';
import '../../controllers/auth_controller.dart';
import 'product_details_screen.dart';

class ProductListScreen extends StatelessWidget {
  const ProductListScreen({
    super.key,
    required this.productRepository,
  });

  final MockProductRepository productRepository;

  @override
  Widget build(BuildContext context) {
    final products = productRepository.getProducts();
    final userName = context.read<AuthController>().currentUser?.name ?? 'Пользователь';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Каталог товаров'),
        actions: [
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
        leading: Image.asset(
          product.imagePath,
          width: 64,
          height: 64,
          fit: BoxFit.cover,
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
