class WarehouseQr {
  static const String _productPrefix = 'warehouse-app:product:';

  static String encodeProductId(int id) {
    return '$_productPrefix$id';
  }

  static int? tryDecodeProductId(String raw) {
    final value = raw.trim();
    if (!value.startsWith(_productPrefix)) {
      return null;
    }

    final idPart = value.substring(_productPrefix.length).trim();
    if (idPart.isEmpty) {
      return null;
    }

    final id = int.tryParse(idPart);
    if (id == null || id <= 0) {
      return null;
    }

    return id;
  }
}
