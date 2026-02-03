class UserModel {
  final String id;
  final String name;
  final String role;
  final String email;

  UserModel({
    required this.id,
    required this.name,
    required this.role,
    required this.email,
  });

  // De JSON (API) a Objeto Dart
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      role: json['role'],
      email: json['email'],
    );
  }

  // De Objeto Dart a JSON (Para mandar a la API)
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'email': email};
}
