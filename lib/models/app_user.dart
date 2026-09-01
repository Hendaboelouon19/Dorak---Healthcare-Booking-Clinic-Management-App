enum UserRole {
  patient,
  assistant,
  admin,
}

class AppUser {
  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.clinicId,
  });

  final String uid;
  final String name;
  final String email;
  final String? phone;
  final UserRole role;

  // Only assistants will normally have this.
  final String? clinicId;

  factory AppUser.fromMap(
    String uid,
    Map<String, dynamic> data,
  ) {
    return AppUser(
      uid: uid,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phone: data['phone'] as String?,
      role: _roleFromString(
        data['role'] as String? ?? 'patient',
      ),
      clinicId: data['clinicId'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'clinicId': clinicId,
    };
  }

  static UserRole _roleFromString(String role) {
    switch (role) {
      case 'assistant':
        return UserRole.assistant;

      case 'admin':
        return UserRole.admin;

      case 'patient':
      default:
        return UserRole.patient;
    }
  }
}