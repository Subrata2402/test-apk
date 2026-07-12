class UserModel {
  final String id;
  final String email;
  final String name;
  final String? picture;
  final String role;

  const UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.picture,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'] as String? ?? json['_id'] as String,
    email: json['email'] as String,
    name: json['name'] as String,
    picture: json['picture'] as String?,
    role: json['role'] as String? ?? 'Tester',
  );

  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
