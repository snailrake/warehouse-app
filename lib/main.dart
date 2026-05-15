import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/warehouse_app.dart';
import 'data/db/app_database.dart';
import 'data/repositories/product_repository.dart';
import 'data/repositories/sqlite_auth_repository.dart';
import 'data/repositories/sqlite_product_repository.dart';
import 'presentation/controllers/auth_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final database = await AppDatabase.open();
  final authRepository = SqliteAuthRepository(database.db);
  final productRepository = SqliteProductRepository(database.db);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthController(authRepository),
        ),
        Provider<ProductRepository>.value(value: productRepository),
      ],
      child: WarehouseApp(productRepository: productRepository),
    ),
  );
}
