class UserModel {
  final String id;
  final String name;
  final String role;
  final String email;
  final String token;
  final bool isActive;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
    required this.token,
    required this.isActive,
  });

  // De JSON (API) a Objeto Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    final userData = json['user'] as Map<String, dynamic>;
    final tokensData = json['tokens'] as Map<String, dynamic>;

    return UserModel(
      id: userData['id'] ?? '',
      name: userData['first_name'] ?? '',
      role: userData['role'] ?? 'EMPLOYEE',
      email: userData['email'],
      token: tokensData['access'],
      isActive: userData['is_active'],
    );
  }

  // De Objeto Dart a JSON (Para mandar a la API)
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}
