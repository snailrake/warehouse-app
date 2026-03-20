import 'package:flutter/material.dart';

import '../../../data/models/product.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    final isAvailable = product.status == ProductStatus.available;

    return Scaffold(
      appBar: AppBar(title: const Text('Карточка товара')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Image.asset(
            product.imagePath,
            width: double.infinity,
            height: 220,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 16),
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isAvailable ? 'Статус: свободен' : 'Статус: занят',
            style: TextStyle(
              color: isAvailable ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Описание',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(product.description),
        ],
      ),
    );
  }
}
