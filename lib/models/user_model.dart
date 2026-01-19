import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String? photoUrl;
  final String themePreference;
  final String? securityQuestion;
  final String? securityAnswer;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.photoUrl,
    this.themePreference = 'system',
    this.securityQuestion,
    this.securityAnswer,
    required this.createdAt,
    this.lastLogin,
  });

  /// Role helpers
  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';

  /// Safe factory from Firestore
  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    if (data == null) {
      throw StateError('User document does not exist');
    }

    return UserModel(
      uid: doc.id,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      role: data['role'] as String? ?? 'user',
      photoUrl: data['photoUrl'] as String?,
      themePreference: data['themePreference'] as String? ?? 'system',
      securityQuestion: data['securityQuestion'] as String?,
      securityAnswer: data['securityAnswer'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ??
          DateTime.fromMillisecondsSinceEpoch(0),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate(),
    );
  }

  /// Map for Firestore write
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'role': role,
      'photoUrl': photoUrl,
      'themePreference': themePreference,
      'securityQuestion': securityQuestion,
      'securityAnswer': securityAnswer,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin':
          lastLogin == null ? null : Timestamp.fromDate(lastLogin!),
    };
  }

  /// Immutable update
  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? role,
    String? photoUrl,
    String? themePreference,
    String? securityQuestion,
    String? securityAnswer,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      themePreference: themePreference ?? this.themePreference,
      securityQuestion: securityQuestion ?? this.securityQuestion,
      securityAnswer: securityAnswer ?? this.securityAnswer,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
