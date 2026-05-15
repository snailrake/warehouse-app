import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../../../data/models/app_user.dart';
import '../../../data/models/product.dart';
import '../../../data/qr/warehouse_qr.dart';
import '../../../data/repositories/product_repository.dart';
import '../../controllers/auth_controller.dart';
import '../catalog/product_details_screen.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({
    super.key,
    required this.productRepository,
  });

  final ProductRepository productRepository;

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();

  bool _handlingScan = false;
  bool _requestingCameraPermission = true;
  bool _cameraPermissionGranted = false;
  String? _lastRaw;
  String? _lastMessage;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _requestCameraPermission() async {
    setState(() => _requestingCameraPermission = true);

    final status = await Permission.camera.request();
    if (!mounted) {
      return;
    }

    setState(() {
      _cameraPermissionGranted = status.isGranted;
      _requestingCameraPermission = false;
    });
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
      if (!mounted) {
        return;
      }

      final trimmed = raw.trim();
      if (trimmed.isEmpty) {
        await _showError(
          title: 'Пустые данные',
          message: 'QR-код не содержит текст.',
        );
        return;
      }

      final productId = WarehouseQr.tryDecodeProductId(trimmed);
      if (productId == null) {
        await _showError(
          title: 'Некорректный QR-код',
          message: 'Содержимое: $trimmed',
        );
        return;
      }

      final user = context.read<AuthController>().currentUser;
      if (user == null) {
        await _showError(
          title: 'Нет доступа',
          message: 'Нужно войти в систему, чтобы работать с товарами.',
        );
        return;
      }

      if (!_canTakeReturn(user)) {
        await _showError(
          title: 'Нет доступа',
          message: 'Ваша роль не позволяет брать и возвращать товары.',
        );
        return;
      }

      final result = await widget.productRepository.toggleTakeReturn(
        productId: productId,
        userId: user.id,
      );

      await _showResult(result.product, action: result.action);
    } catch (e) {
      await _showError(
        title: 'Ошибка',
        message: e.toString(),
      );
    } finally {
      if (mounted) {
        await _controller.start();
      }
      _handlingScan = false;
    }
  }

  bool _canTakeReturn(AppUser user) {
    return user.role == UserRole.admin || user.role == UserRole.employee;
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

  Future<void> _showResult(Product product, {required String action}) async {
    final actionText = action == 'take' ? 'взят' : 'возвращен';
    setState(() {
      _lastMessage = 'Товар $actionText: ${product.name} (ID: ${product.id})';
    });

    final openDetails = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(action == 'take' ? 'Товар взят' : 'Товар возвращен'),
        content: Text(
          'ID: ${product.id}\n'
          'Название: ${product.name}\n'
          'Статус: ${product.status == ProductStatus.available ? 'Доступен' : 'Взят'}\n\n'
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
          builder: (_) => ProductDetailsScreen(productId: product.id),
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
          Expanded(child: _buildScanner()),
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

  Widget _buildScanner() {
    if (_requestingCameraPermission) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!_cameraPermissionGranted) {
      return _CameraPermissionView(onRetry: _requestCameraPermission);
    }

    return MobileScanner(
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

class _CameraPermissionView extends StatelessWidget {
  const _CameraPermissionView({
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Нужен доступ к камере, чтобы сканировать QR-коды.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Разрешить доступ'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              child: const Text('Назад'),
            ),
          ],
        ),
      ),
    );
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
