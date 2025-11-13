class User {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? groupId;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.groupId,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'member',
      groupId: json['group'] is Map
          ? json['group']['_id']
          : json['group']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'role': role,
      'group': groupId,
    };
  }
}
