import '../models/app_user.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  int _nextId = 2;

  final List<AppUser> _users = [
    const AppUser(
      id: 1,
      name: 'Демо пользователь',
      email: 'store@mail.ru',
      password: '123456',
      role: UserRole.admin,
    ),
  ];

  @override
  Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    for (final user in _users) {
      if (user.email == email && user.password == password) {
        return user;
      }
    }
    return null;
  }

  @override
  Future<bool> emailExists(String email) async {
    return _users.any((u) => u.email == email);
  }

  @override
  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final user = AppUser(
      id: _nextId,
      name: name,
      email: email,
      password: password,
      role: role,
    );
    _nextId++;
    _users.add(user);
    return user;
  }
}
