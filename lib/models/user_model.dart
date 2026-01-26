class UserModel {
  final String uid;
  final String email;
  final String name;
  final String role; // 'admin' atau 'user'
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    this.role = 'user',
    this.photoUrl,
  });

  // Konversi dari Firestore Document ke Object
  factory UserModel.fromMap(Map<String, dynamic> data, String uid) {
    return UserModel(
      uid: uid,
      email: data['email'] ?? '',
      name: data['name'] ?? 'No Name',
      role: data['role'] ?? 'user',
      photoUrl: data['photoUrl'],
    );
  }

  // Konversi dari Object ke Map (untuk simpan ke Firestore)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'name': name,
      'role': role,
      'photoUrl': photoUrl,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }
}