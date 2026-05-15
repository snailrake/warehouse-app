enum UserRole {
  admin,
  employee,
}

class AppUser {
  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.role,
  });

  final int id;
  final String name;
  final String email;
  final String password;
  final UserRole role;

  static AppUser fromDb(Map<String, Object?> row) {
    final roleRaw = (row['role'] as String?) ?? UserRole.employee.name;
    final role = UserRole.values.firstWhere(
      (r) => r.name == roleRaw,
      orElse: () => UserRole.employee,
    );

    return AppUser(
      id: row['id'] as int,
      name: row['name'] as String,
      email: row['email'] as String,
      password: row['password'] as String,
      role: role,
    );
  }
}
