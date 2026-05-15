import '../models/app_user.dart';

abstract class AuthRepository {
  Future<AppUser?> login({
    required String email,
    required String password,
  });

  Future<bool> emailExists(String email);

  Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  });
}
