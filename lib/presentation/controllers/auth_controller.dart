import 'package:flutter/foundation.dart';

import '../../data/models/app_user.dart';
import '../../data/repositories/mock_auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._authRepository);

  final MockAuthRepository _authRepository;

  AppUser? _currentUser;
  String? _errorMessage;

  AppUser? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;

  bool login({
    required String email,
    required String password,
  }) {
    final user = _authRepository.login(email: email, password: password);

    if (user == null) {
      _errorMessage = 'Неверный email или пароль.';
      notifyListeners();
      return false;
    }

    _currentUser = user;
    _errorMessage = null;
    notifyListeners();
    return true;
  }

  bool register({
    required String name,
    required String email,
    required String password,
  }) {
    if (_authRepository.emailExists(email)) {
      _errorMessage = 'Пользователь с таким email уже существует.';
      notifyListeners();
      return false;
    }

    _authRepository.register(
      AppUser(
        name: name,
        email: email,
        password: password,
      ),
    );

    _errorMessage = null;
    notifyListeners();
    return true;
  }

  void clearError() {
    if (_errorMessage == null) {
      return;
    }

    _errorMessage = null;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }
}
