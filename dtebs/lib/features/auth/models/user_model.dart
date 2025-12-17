class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'Customer' or 'Restaurant Owner'

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
  });

  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'Customer',
    );
  }

  Map<String, dynamic> toMap() {
    return {'email': email, 'name': name, 'role': role};
  }
}
