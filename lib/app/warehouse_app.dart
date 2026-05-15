import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/repositories/product_repository.dart';
import '../presentation/controllers/auth_controller.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/catalog/product_list_screen.dart';

class WarehouseApp extends StatelessWidget {
  const WarehouseApp({
    super.key,
    required this.productRepository,
  });

  final ProductRepository productRepository;

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Складской учет',
      theme: _buildTheme(),
      home: authController.isAuthenticated
          ? ProductListScreen(productRepository: productRepository)
          : const LoginScreen(),
    );
  }

  ThemeData _buildTheme() {
    const primaryColor = Color(0xFF1565C0);
    final colorScheme = ColorScheme.fromSeed(seedColor: primaryColor);

    return ThemeData(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD8E1E4)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: EdgeInsets.zero,
      ),
      appBarTheme: const AppBarTheme(centerTitle: true),
      useMaterial3: true,
    );
  }
}
