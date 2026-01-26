import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get Current User (Firebase User)
  User? get currentUser => _auth.currentUser;

  // Stream perubahan status auth
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // --- REGISTER (Hanya untuk User) ---
  Future<UserModel?> register({required String email, required String password, required String name}) async {
    try {
      // 1. Create User di Auth
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // 2. Siapkan data user (Default role: 'user')
        UserModel newUser = UserModel(
          uid: user.uid,
          email: email,
          name: name,
          role: 'user', 
        );

        // 3. Simpan ke Firestore
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        
        return newUser;
      }
    } catch (e) {
      rethrow; // Lempar error ke UI untuk ditampilkan
    }
    return null;
  }

  // --- LOGIN ---
  Future<UserModel?> login({required String email, required String password}) async {
    try {
      // 1. Login Auth
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user != null) {
        // 2. Ambil data role dari Firestore
        return await getUserDetails(user.uid);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  // --- GET USER DETAILS (Cek Role) ---
  Future<UserModel?> getUserDetails(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, uid);
      }
    } catch (e) {
      // Error getting user details
      debugPrint('Error getting user details: $e');
    }
    return null;
  }

  // --- LOGOUT ---
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // --- FORGOT PASSWORD ---
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
}