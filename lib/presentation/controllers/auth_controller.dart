import 'package:flutter/foundation.dart';

import '../../data/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';

class AuthController extends ChangeNotifier {
  AuthController(this._authRepository);

  final AuthRepository _authRepository;

  AppUser? _currentUser;
  String? _errorMessage;
  bool _busy = false;

  AppUser? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentUser != null;
  bool get isBusy => _busy;

  bool get canCreateProducts => _currentUser?.role == UserRole.admin;

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (_busy) {
      return false;
    }

    _busy = true;
    _errorMessage = null;
    notifyListeners();

    final user = await _authRepository.login(email: email, password: password);

    if (user == null) {
      _errorMessage = 'Неверный email или пароль.';
      _busy = false;
      notifyListeners();
      return false;
    }

    _currentUser = user;
    _busy = false;
    notifyListeners();
    return true;
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (_busy) {
      return false;
    }

    _busy = true;
    _errorMessage = null;
    notifyListeners();

    if (await _authRepository.emailExists(email)) {
      _errorMessage = 'Пользователь с таким email уже существует.';
      _busy = false;
      notifyListeners();
      return false;
    }

    await _authRepository.register(
      name: name,
      email: email,
      password: password,
      role: UserRole.employee,
    );

    _busy = false;
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
    _busy = false;
    notifyListeners();
  }
}
