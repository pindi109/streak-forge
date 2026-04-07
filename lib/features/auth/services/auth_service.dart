
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/constants/app_constants.dart';

class AuthService {
  final FirebaseAuth      _auth      = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn      _googleSignIn = GoogleSignIn();

  // ── Stream ────────────────────────────────────────────────────────────────────

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  // ── Email & Password ──────────────────────────────────────────────────────────

  Future<User?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AppConstants.errGeneric;
    }
  }

  Future<User?> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(displayName);
        await _createUserDocument(user, displayName: displayName);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AppConstants.errGeneric;
    }
  }

  // ── Google Sign-In ────────────────────────────────────────────────────────────

  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;

      if (user != null && userCredential.additionalUserInfo?.isNewUser == true) {
        await _createUserDocument(user);
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AppConstants.errGoogleSignIn;
    }
  }

  // ── Sign Out ──────────────────────────────────────────────────────────────────

  Future<void> signOut() async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw AppConstants.errGeneric;
    }
  }

  // ── Password Reset ────────────────────────────────────────────────────────────

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AppConstants.errGeneric;
    }
  }

  // ── Delete Account ────────────────────────────────────────────────────────────

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Delete Firestore data first
      await _firestore
          .collection(AppConstants.colUsers)
          .doc(user.uid)
          .delete();

      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw _handleFirebaseAuthException(e);
    } catch (e) {
      throw AppConstants.errGeneric;
    }
  }

  // ── Firestore User Document ───────────────────────────────────────────────────

  Future<void> _createUserDocument(
    User user, {
    String? displayName,
  }) async {
    try {
      final docRef = _firestore
          .collection(AppConstants.colUsers)
          .doc(user.uid);

      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) {
        await docRef.set({
          AppConstants.fieldId:          user.uid,
          AppConstants.fieldEmail:        user.email ?? '',
          AppConstants.fieldDisplayName:  displayName ?? user.displayName ?? '',
          AppConstants.fieldPhotoUrl:     user.photoURL ?? '',
          AppConstants.fieldCreatedAt:    FieldValue.serverTimestamp(),
          AppConstants.fieldUpdatedAt:    FieldValue.serverTimestamp(),
          'habitCount':                   0,
          'totalCompletions':             0,
          'longestStreak':                0,
        });
      }
    } catch (e) {
      // Non-fatal: user can still proceed without Firestore doc
      debugPrint('Failed to create user document: $e');
    }
  }

  Future<void> updateFcmToken(String token) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;
      await _firestore
          .collection(AppConstants.colUsers)
          .doc(user.uid)
          .update({AppConstants.fieldFcmToken: token});
    } catch (e) {
      debugPrint('Failed to update FCM token: $e');
    }
  }

  // ── Error Handling ────────────────────────────────────────────────────────────

  String _handleFirebaseAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AppConstants.errUserNotFound;
      case 'wrong-password':
        return AppConstants.errWrongPassword;
      case 'email-already-in-use':
        return AppConstants.errEmailInUse;
      case 'weak-password':
        return AppConstants.errWeakPassword;
      case 'invalid-email':
        return AppConstants.errEmailInvalid;
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'network-request-failed':
        return AppConstants.errNetworkTimeout;
      case 'invalid-credential':
        return 'Invalid credentials. Please check your email and password.';
      default:
        return e.message ?? AppConstants.errGeneric;
    }
  }
}

// ignore_for_file: avoid_print
void debugPrint(String message) {
  // ignore: avoid_print
  print('[AuthService] $message');
}