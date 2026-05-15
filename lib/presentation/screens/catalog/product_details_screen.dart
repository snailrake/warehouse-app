import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../data/models/product.dart';
import '../../../data/qr/warehouse_qr.dart';
import '../../../data/repositories/product_repository.dart';
import '../../widgets/product_image.dart';

class ProductDetailsScreen extends StatelessWidget {
  const ProductDetailsScreen({
    super.key,
    required this.productId,
  });

  final int productId;

  @override
  Widget build(BuildContext context) {
    final repository = context.read<ProductRepository>();

    return FutureBuilder<Product?>(
      future: repository.getProductById(productId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final product = snapshot.data;
        if (product == null) {
          return const Scaffold(
            body: Center(child: Text('Товар не найден')),
          );
        }

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
              const SizedBox(height: 12),
              Text(
                isAvailable ? 'Статус: доступен' : 'Статус: взят',
                style: TextStyle(
                  color: isAvailable ? Colors.green : Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (!isAvailable) ...[
                const SizedBox(height: 8),
                Text(
                  _takenInfo(product),
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
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
      },
    );
  }

  String _takenInfo(Product product) {
    final userId = product.takenByUserId;
    final at = product.takenAt;

    final parts = <String>[];
    if (userId != null) {
      parts.add('Кем взят (ID пользователя): $userId');
    }
    if (at != null) {
      parts.add('Когда: ${at.toLocal()}');
    }

    return parts.isEmpty
        ? 'Информация о взятии отсутствует.'
        : parts.join('\n');
  }
}
