import 'package:sqflite/sqflite.dart';

import '../models/product.dart';
import 'product_repository.dart';

class SqliteProductRepository implements ProductRepository {
  SqliteProductRepository(this._db);

  final Database _db;

  @override
  Future<List<Product>> getProducts() async {
    final rows = await _db.query(
      'products',
      orderBy: 'id DESC',
    );
    return rows.map(Product.fromDb).toList(growable: false);
  }

  @override
  Future<Product?> getProductById(int id) async {
    final rows = await _db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) {
      return null;
    }
    return Product.fromDb(rows.first);
  }

  @override
  Future<Product> addProduct({
    required String name,
    required String shortDescription,
    required String description,
    required String imagePath,
    required ProductStatus status,
  }) async {
    final id = await _db.insert('products', {
      'name': name,
      'short_description': shortDescription,
      'description': description,
      'image_path': imagePath,
      'status': status.name,
      'taken_by_user_id': null,
      'taken_at': null,
    });

    return Product(
      id: id,
      name: name,
      shortDescription: shortDescription,
      description: description,
      imagePath: imagePath,
      status: status,
      takenByUserId: null,
      takenAt: null,
    );
  }

  @override
  Future<ProductTakeResult> toggleTakeReturn({
    required int productId,
    required int userId,
  }) async {
    return _db.transaction((txn) async {
      final rows = await txn.query(
        'products',
        where: 'id = ?',
        whereArgs: [productId],
        limit: 1,
      );

      if (rows.isEmpty) {
        throw StateError('Product not found: $productId');
      }

      final current = Product.fromDb(rows.first);
      final now = DateTime.now();

      if (current.status == ProductStatus.available) {
        await txn.update(
          'products',
          {
            'status': ProductStatus.reserved.name,
            'taken_by_user_id': userId,
            'taken_at': now.toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [productId],
        );

        await txn.insert('product_actions', {
          'product_id': productId,
          'user_id': userId,
          'action': 'take',
          'created_at': now.toIso8601String(),
        });

        final updated = Product(
          id: current.id,
          name: current.name,
          shortDescription: current.shortDescription,
          description: current.description,
          imagePath: current.imagePath,
          status: ProductStatus.reserved,
          takenByUserId: userId,
          takenAt: now,
        );
        return ProductTakeResult(product: updated, action: 'take');
      }

      await txn.update(
        'products',
        {
          'status': ProductStatus.available.name,
          'taken_by_user_id': null,
          'taken_at': null,
        },
        where: 'id = ?',
        whereArgs: [productId],
      );

      await txn.insert('product_actions', {
        'product_id': productId,
        'user_id': userId,
        'action': 'return',
        'created_at': now.toIso8601String(),
      });

      final updated = Product(
        id: current.id,
        name: current.name,
        shortDescription: current.shortDescription,
        description: current.description,
        imagePath: current.imagePath,
        status: ProductStatus.available,
        takenByUserId: null,
        takenAt: null,
      );
      return ProductTakeResult(product: updated, action: 'return');
    });
  }
}
