import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../data/models/product.dart';
import '../../../data/qr/warehouse_qr.dart';
import '../../widgets/product_image.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({
    super.key,
    required this.product,
  });

  final Product product;

  @override
  Widget build(BuildContext context) {
    final isAvailable = product.status == ProductStatus.available;
    final qrData = WarehouseQr.encodeProductId(product.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Карточка товара')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ProductImage(
            imagePath: product.imagePath,
            width: double.infinity,
            height: 220,
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
          const SizedBox(height: 24),
          const Text(
            'QR-код товара',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: QrImageView(
              data: qrData,
              size: 220,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Содержимое QR: $qrData',
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
