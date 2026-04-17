import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../data/models/product.dart';
import '../../../data/qr/warehouse_qr.dart';
import '../../../data/repositories/mock_product_repository.dart';
import '../../widgets/product_image.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({
    super.key,
    required this.productRepository,
  });

  final MockProductRepository productRepository;

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _shortDescriptionController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imagePicker = ImagePicker();

  ProductStatus _status = ProductStatus.available;
  String? _selectedImagePath;
  Product? _lastCreatedProduct;

  @override
  void dispose() {
    _nameController.dispose();
    _shortDescriptionController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final image = await _imagePicker.pickMedia();
      if (image == null) {
        return;
      }

      setState(() => _selectedImagePath = image.path);
    } catch (_) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Не удалось выбрать изображение')),
        );
    }
  }

  void _createProduct() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final product = widget.productRepository.addProduct(
      name: _nameController.text.trim(),
      shortDescription: _shortDescriptionController.text.trim(),
      description: _descriptionController.text.trim(),
      imagePath:
          _selectedImagePath ?? MockProductRepository.placeholderImagePath,
      status: _status,
    );

    setState(() {
      _lastCreatedProduct = product;
      _status = ProductStatus.available;
      _selectedImagePath = null;
    });

    _nameController.clear();
    _shortDescriptionController.clear();
    _descriptionController.clear();

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text('Товар создан (ID: ${product.id})')),
      );
  }

  @override
  Widget build(BuildContext context) {
    final lastProduct = _lastCreatedProduct;
    final qrData = lastProduct == null
        ? null
        : WarehouseQr.encodeProductId(lastProduct.id);

    return Scaffold(
      appBar: AppBar(title: const Text('Добавление товара')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Название'),
                  validator: _validateName,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _shortDescriptionController,
                  decoration:
                      const InputDecoration(labelText: 'Краткое описание'),
                  validator: _validateShortDescription,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Описание'),
                  maxLines: 4,
                  validator: _validateDescription,
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Выбрать картинку из галереи'),
                ),
                const SizedBox(height: 12),
                ProductImage(
                  imagePath: _selectedImagePath ??
                      MockProductRepository.placeholderImagePath,
                  width: double.infinity,
                  height: 160,
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedImagePath == null
                      ? 'Если картинку не выбрать, будет использована заглушка.'
                      : 'Картинка выбрана.',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ProductStatus>(
                  key: ValueKey(_status),
                  initialValue: _status,
                  decoration: const InputDecoration(labelText: 'Статус'),
                  items: const [
                    DropdownMenuItem(
                      value: ProductStatus.available,
                      child: Text('Свободен'),
                    ),
                    DropdownMenuItem(
                      value: ProductStatus.reserved,
                      child: Text('Занят'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }
                    setState(() => _status = value);
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _createProduct,
                  child: const Text('Создать товар и QR-код'),
                ),
              ],
            ),
          ),
          if (lastProduct != null && qrData != null) ...[
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'QR-код товара (ID: ${lastProduct.id})',
              style: const TextStyle(
                fontSize: 16,
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
            const SizedBox(height: 12),
            Text(
              'Содержимое QR: $qrData',
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Готово'),
            ),
          ],
        ],
      ),
    );
  }

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) {
      return 'Введите название.';
    }
    if (name.length < 2) {
      return 'Название должно быть не короче 2 символов.';
    }
    return null;
  }

  String? _validateShortDescription(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Введите краткое описание.';
    }
    if (text.length < 5) {
      return 'Краткое описание должно быть не короче 5 символов.';
    }
    return null;
  }

  String? _validateDescription(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Введите описание.';
    }
    if (text.length < 10) {
      return 'Описание должно быть не короче 10 символов.';
    }
    return null;
  }
}
