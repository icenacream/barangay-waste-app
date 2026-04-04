class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String barangay;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    required this.barangay,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? 'resident',
      barangay: data['barangay'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'barangay': barangay,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isResident => role == 'resident';
}