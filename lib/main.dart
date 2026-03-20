import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/warehouse_app.dart';
import 'data/repositories/mock_auth_repository.dart';
import 'data/repositories/mock_product_repository.dart';
import 'presentation/controllers/auth_controller.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthController(MockAuthRepository()),
      child: WarehouseApp(
        productRepository: MockProductRepository(),
      ),
    ),
  );
}
