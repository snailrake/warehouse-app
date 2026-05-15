import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:mobilki/app/warehouse_app.dart';
import 'package:mobilki/data/repositories/mock_auth_repository.dart';
import 'package:mobilki/data/repositories/mock_product_repository.dart';
import 'package:mobilki/presentation/controllers/auth_controller.dart';

void main() {
  testWidgets('Shows login screen by default', (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthController(MockAuthRepository()),
        child: WarehouseApp(productRepository: MockProductRepository()),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Вход'), findsOneWidget);
  });
}
