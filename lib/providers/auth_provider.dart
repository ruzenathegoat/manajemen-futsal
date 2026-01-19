import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  StreamSubscription<User?>? _authSubscription;

  AuthStatus _status = AuthStatus.initial;
  UserModel? _user;
  String? _error;

  // ==================== GETTERS ====================
  AuthStatus get status => _status;
  UserModel? get user => _user;
  String? get error => _error;

  bool get isAuthenticated => _status == AuthStatus.authenticated;
  bool get isAdmin => _user?.role == 'admin';
  bool get isUser => _user?.role == 'user';
  bool get isLoading => _status == AuthStatus.loading;

  AuthProvider() {
    _authSubscription =
        _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  // ==================== AUTH STATE LISTENER ====================
  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user = null;
      _status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    _status = AuthStatus.loading;
    notifyListeners();

    try {
      final userData = await _authService.getUserData(firebaseUser.uid);

      if (userData == null) {
        await _authService.logout();
        _user = null;
        _status = AuthStatus.unauthenticated;
        _error = 'USER_DOC_NOT_FOUND';
      } else {
        _user = userData;
        _status = AuthStatus.authenticated;
        _error = null;
      }
    } catch (e) {
      _user = null;
      _status = AuthStatus.unauthenticated;
      _error = e.toString();
    }

    notifyListeners();
  }

      // ==================== REGISTER ====================
    Future<bool> register({
      required String email,
      required String password,
      required String name,
    }) async {
      _error = null;
      notifyListeners();

      try {
        await _authService.registerWithEmail(
          email: email,
          password: password,
          name: name,
        );
        return true;
      } catch (e) {
        _error = e.toString();
        notifyListeners();
        return false;
      }
    }

    // ==================== LOGIN ====================
    Future<bool> login({
      required String email,
      required String password,
    }) async {
      _error = null;
      notifyListeners();

      try {
        await _authService.loginWithEmail(
          email: email,
          password: password,
        );
        return true;
      } catch (e) {
        _error = e.toString();
        notifyListeners();
        return false;
      }
    }


  // ==================== RESET PASSWORD ====================
  Future<bool> sendPasswordResetEmail(String email) async {
    _error = null;
    try {
      await _authService.sendPasswordResetEmail(email);
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== CHANGE PASSWORD ====================
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    _error = null;
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== UPDATE PROFILE (DIPERTAHANKAN) ====================
  Future<bool> updateProfile({
    String? name,
    String? photoUrl,
    String? themePreference,
  }) async {
    if (_user == null) return false;

    _error = null;
    try {
      await _authService.updateProfile(
        uid: _user!.uid,
        name: name,
        photoUrl: photoUrl,
        themePreference: themePreference,
      );

      _user = _user!.copyWith(
        name: name ?? _user!.name,
        photoUrl: photoUrl ?? _user!.photoUrl,
        themePreference:
            themePreference ?? _user!.themePreference,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== LOGOUT ====================
  Future<void> logout() async {
    await _authService.logout();
    _user = null;
    _status = AuthStatus.unauthenticated;
    _error = null;
    notifyListeners();
  }

  // ==================== CLEAR ERROR ====================
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
