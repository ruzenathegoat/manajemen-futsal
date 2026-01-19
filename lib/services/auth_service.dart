import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== AUTH STATE ====================
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ==================== REGISTER (USER ONLY) ====================
  Future<UserModel> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    late UserCredential credential;

    try {
      credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw 'AUTH_USER_NULL';
      }

      final userModel = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        role: AppConstants.roleUser,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set(userModel.toFirestore());

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } on FirebaseException catch (e) {
      if (_auth.currentUser != null) {
        await _auth.currentUser!.delete();
      }
      throw _handleFirestoreError(e);
    }
  }

  // ==================== LOGIN ====================
  Future<UserModel> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user == null) {
        throw 'AUTH_USER_NULL';
      }

      final doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .get();

      if (!doc.exists) {
        await _auth.signOut();
        throw 'USER_DOC_NOT_FOUND';
      }

      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .update({'lastLogin': Timestamp.now()});

      return UserModel.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } on FirebaseException catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  // ==================== GET USER DATA ====================
  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();

    if (!doc.exists) return null;
    return UserModel.fromFirestore(doc);
  }

  // ==================== CHANGE PASSWORD (LOGGED IN) ====================
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw 'USER_NOT_LOGGED_IN';
    }

    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: currentPassword,
    );

    try {
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ==================== FORGOT PASSWORD (EMAIL LINK - FIXED) ====================
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ==================== UPDATE PROFILE ====================
  Future<void> updateProfile({
    required String uid,
    String? name,
    String? photoUrl,
    String? themePreference,
  }) async {
    final Map<String, dynamic> updates = {};

    if (name != null) updates['name'] = name;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;
    if (themePreference != null) updates['themePreference'] = themePreference;

    if (updates.isEmpty) return;

    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(uid)
          .update(updates);
    } on FirebaseException catch (e) {
      throw _handleFirestoreError(e);
    }
  }

  // ==================== LOGOUT ====================
  Future<void> logout() async {
    await _auth.signOut();
  }

  // ==================== ERROR HANDLING ====================
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'weak-password':
        return 'Password terlalu lemah';
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'user-not-found':
        return 'Email tidak terdaftar';
      case 'wrong-password':
        return 'Password salah';
      case 'invalid-email':
        return 'Email tidak valid';
      case 'user-disabled':
        return 'Akun dinonaktifkan';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan';
      case 'network-request-failed':
        return 'Masalah koneksi';
      default:
        return e.message ?? 'Auth error';
    }
  }

  String _handleFirestoreError(FirebaseException e) {
    switch (e.code) {
      case 'permission-denied':
        return 'Firestore permission denied';
      case 'unavailable':
        return 'Firestore unavailable';
      default:
        return e.message ?? 'Firestore error';
    }
  }
}
