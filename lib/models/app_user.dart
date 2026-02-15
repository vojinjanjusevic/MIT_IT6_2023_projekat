enum UserRole { guest, user, admin }

class AppUser {
  final String id;
  final String name;
  final String email;
  final UserRole role;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final roleValue = (json['role'] ?? 'user').toString();
    final role = switch (roleValue) {
      'admin' => UserRole.admin,
      'user' => UserRole.user,
      _ => UserRole.guest,
    };

    return AppUser(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: role,
    );
  }
}
