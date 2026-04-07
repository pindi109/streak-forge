
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  AuthStatus _status       = AuthStatus.initial;
  User?      _user;
  String?    _errorMessage;
  bool       _isLoading    = false;

  // ── Getters ───────────────────────────────────────────────────────────────────

  AuthStatus get status       => _status;
  User?      get user         => _user;
  String?    get errorMessage => _errorMessage;
  bool       get isLoading    => _isLoading;
  bool       get isAuthenticated => _status == AuthStatus.authenticated;

  // ── Lifecycle ─────────────────────────────────────────────────────────────────

  AuthProvider() {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    _user = user;
    _status = user != null
        ? AuthStatus.authenticated
        : AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────────

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String? message) {
    _errorMessage = message;
    _status = message != null ? AuthStatus.error : _status;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ── Auth Actions ──────────────────────────────────────────────────────────────

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      _user   = user;
      _status = user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      _setLoading(true);
      _setError(null);
      final user = await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      _user   = user;
      _status = user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      _setLoading(true);
      _setError(null);
      final user = await _authService.signInWithGoogle();
      _user   = user;
      _status = user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> signOut() async {
    try {
      _setLoading(true);
      _setError(null);
      await _authService.signOut();
      _user   = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _setLoading(true);
      _setError(null);
      await _authService.sendPasswordResetEmail(email);
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteAccount() async {
    try {
      _setLoading(true);
      _setError(null);
      await _authService.deleteAccount();
      _user   = null;
      _status = AuthStatus.unauthenticated;
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}