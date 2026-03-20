import '../models/app_user.dart';

class MockAuthRepository {
  final List<AppUser> _users = [
    const AppUser(
      name: 'Демо пользователь',
      email: 'store@mail.ru',
      password: '123456',
    ),
  ];

  AppUser? login({
    required String email,
    required String password,
  }) {
    for (final user in _users) {
      if (user.email == email && user.password == password) {
        return user;
      }
    }

    return null;
  }

  bool emailExists(String email) {
    for (final user in _users) {
      if (user.email == email) {
        return true;
      }
    }

    return false;
  }

  void register(AppUser user) {
    _users.add(user);
  }
}
