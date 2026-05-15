import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../product_defaults.dart';

class AppDatabase {
  AppDatabase._(this._db);

  static const int schemaVersion = 1;
  static const String fileName = 'warehouse.db';

  final Database _db;

  Database get db => _db;

  static Future<AppDatabase> open() async {
    final basePath = await getDatabasesPath();
    final dbPath = p.join(basePath, fileName);

    final db = await openDatabase(
      dbPath,
      version: schemaVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await _createSchema(db);
        await _seed(db);
      },
    );

    return AppDatabase._(db);
  }

  static Future<void> _createSchema(Database db) async {
    await db.execute('''
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  role TEXT NOT NULL
)
''');

    await db.execute('''
CREATE TABLE products (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  short_description TEXT NOT NULL,
  description TEXT NOT NULL,
  image_path TEXT NOT NULL,
  status TEXT NOT NULL,
  taken_by_user_id INTEGER,
  taken_at TEXT,
  FOREIGN KEY (taken_by_user_id) REFERENCES users(id) ON DELETE SET NULL
)
''');

    await db.execute('''
CREATE TABLE product_actions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  product_id INTEGER NOT NULL,
  user_id INTEGER NOT NULL,
  action TEXT NOT NULL,
  created_at TEXT NOT NULL,
  FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
)
''');
  }

  static Future<void> _seed(Database db) async {
    final demoUserId = await db.insert('users', {
      'name': 'Демо пользователь',
      'email': 'store@mail.ru',
      'password': '123456',
      'role': 'admin',
    });

    await db.insert('products', {
      'name': 'Сканер штрихкодов',
      'short_description': 'Ручной сканер для быстрой приемки товаров.',
      'description':
          'Компактный сканер штрихкодов для работы на складе. Подходит для приемки, инвентаризации и быстрой проверки позиций.',
      'image_path': ProductDefaults.placeholderImagePath,
      'status': 'available',
      'taken_by_user_id': null,
      'taken_at': null,
    });

    await db.insert('products', {
      'name': 'Терминал сбора данных',
      'short_description': 'Мобильное устройство для учета остатков.',
      'description':
          'Терминал помогает сотрудникам склада сканировать товары, сверять остатки и быстро обновлять информацию по позициям.',
      'image_path': ProductDefaults.placeholderImagePath,
      'status': 'reserved',
      'taken_by_user_id': demoUserId,
      'taken_at': DateTime.now().toIso8601String(),
    });

    await db.insert('products', {
      'name': 'Принтер этикеток',
      'short_description': 'Печать маркировки и складских стикеров.',
      'description':
          'Настольный принтер этикеток для маркировки товара, коробок и полок. Удобен для повседневной работы на складе.',
      'image_path': ProductDefaults.placeholderImagePath,
      'status': 'available',
      'taken_by_user_id': null,
      'taken_at': null,
    });

    await db.insert('products', {
      'name': 'Погрузочная тележка',
      'short_description': 'Тележка для перемещения коробок по складу.',
      'description':
          'Прочная складская тележка для перемещения грузов между зонами хранения и отгрузки. Подходит для ежедневной эксплуатации.',
      'image_path': ProductDefaults.placeholderImagePath,
      'status': 'reserved',
      'taken_by_user_id': demoUserId,
      'taken_at':
          DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    });
  }
}
