enum UserRole { patient, assistant, admin }

class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    this.avatarUrl,
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String phone;
  final String? avatarUrl;
}
