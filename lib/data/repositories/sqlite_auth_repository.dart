import 'package:sqflite/sqflite.dart';

import '../models/app_user.dart';
import 'auth_repository.dart';

class SqliteAuthRepository implements AuthRepository {
  SqliteAuthRepository(this._db);

  final Database _db;

  @override
  Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    final rows = await _db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );

    if (rows.isEmpty) {
      return null;
    }

    return AppUser.fromDb(rows.first);
  }

  @override
  Future<bool> emailExists(String email) async {
    final rows = await _db.query(
      'users',
      columns: ['id'],
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    return rows.isNotEmpty;
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final id = await _db.insert('users', {
      'name': name,
      'email': email,
      'password': password,
      'role': role.name,
    });

    return AppUser(
      id: id,
      name: name,
      email: email,
      password: password,
      role: role,
    );
  }
}
