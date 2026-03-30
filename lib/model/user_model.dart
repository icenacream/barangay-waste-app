class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String purok;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.purok,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'resident',
      purok: data['purok'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'purok': purok,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isResident => role == 'resident';
}