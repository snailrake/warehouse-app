import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../data/models/product.dart';
import '../../../data/qr/warehouse_qr.dart';
import '../../../data/repositories/mock_product_repository.dart';
import '../catalog/product_details_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({
    super.key,
    required this.productRepository,
  });

  final MockProductRepository productRepository;

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();

  bool _handlingScan = false;
  String? _lastRaw;
  String? _lastMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleRaw(String raw) async {
    if (_handlingScan) {
      return;
    }
    _handlingScan = true;

    setState(() {
      _lastRaw = raw;
      _lastMessage = null;
    });

    await _controller.stop();

    try {
      final trimmed = raw.trim();
      if (trimmed.isEmpty) {
        await _showError(
          title: 'Пустые данные',
          message: 'QR-код не содержит текста.',
        );
        return;
      }

      final id = WarehouseQr.tryDecodeProductId(trimmed);
      if (id == null) {
        await _showError(
          title: 'Некорректный QR-код',
          message: 'Содержимое: $trimmed',
        );
        return;
      }

      final product = widget.productRepository.getProductById(id);
      if (product == null) {
        await _showError(
          title: 'Товар не найден',
          message: 'ID из QR-кода: $id',
        );
        return;
      }

      await _showProductFound(product);
    } finally {
      if (mounted) {
        await _controller.start();
      }
      _handlingScan = false;
    }
  }

  Future<void> _showError({
    required String title,
    required String message,
  }) async {
    setState(() {
      _lastMessage = '$title: $message';
    });

    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ОК'),
          ),
        ],
      ),
    );
  }

  Future<void> _showProductFound(Product product) async {
    setState(() {
      _lastMessage = 'Найден товар: ${product.name} (ID: ${product.id})';
    });

    final openDetails = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Товар найден'),
        content: Text(
          'ID: ${product.id}\n'
          'Название: ${product.name}\n'
          'Статус: ${product.status == ProductStatus.available ? 'Свободен' : 'Занят'}\n\n'
          '${product.shortDescription}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Закрыть'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Открыть карточку'),
          ),
        ],
      ),
    );

    if (!mounted) {
      return;
    }

    if (openDetails == true) {
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ProductDetailsScreen(product: product),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Сканирование QR')),
      body: Column(
        children: [
          Expanded(
            child: MobileScanner(
              controller: _controller,
              onDetect: (capture) {
                final barcodes = capture.barcodes;
                if (barcodes.isEmpty) {
                  return;
                }

                final raw = barcodes.first.rawValue ?? '';
                _handleRaw(raw);
              },
              errorBuilder: (context, error, child) {
                return _CameraErrorView(message: _cameraErrorMessage(error));
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  _lastRaw == null
                      ? 'Наведите камеру на QR-код.'
                      : 'Последний QR: $_lastRaw',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  _lastMessage ?? 'Ожидание сканирования...',
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _cameraErrorMessage(Object error) {
    final text = error.toString();
    final lower = text.toLowerCase();

    if (lower.contains('nocamera') || lower.contains('no camera')) {
      return 'Камера не найдена на устройстве.';
    }

    if (lower.contains('permission') || lower.contains('denied')) {
      return 'Нет доступа к камере. Разрешите доступ в настройках.';
    }

    return 'Ошибка камеры: $text';
  }
}

class _CameraErrorView extends StatelessWidget {
  const _CameraErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Назад'),
            ),
          ],
        ),
      ),
    );
  }
}

