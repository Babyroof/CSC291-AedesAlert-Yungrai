import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:aedes_alert_yungrai/features/auth/data/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _auth = auth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  bool get isAuthenticated => _auth.currentUser != null;
  String? get currentUserUid => _auth.currentUser?.uid;
  String? get currentUserEmail => _auth.currentUser?.email;
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<String?> register(
    String email,
    String password,
    String firstName,
    String lastName,
    String phoneNumber,
  ) async {
    debugPrint('[AuthService] register: attempt — email=$email');
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        debugPrint('[AuthService] register: Firebase Auth returned null user');
        return 'Cannot create an account.';
      }
      final model = UserModel(
        uid: user.uid,
        email: email.trim(),
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        fcmToken: '',
        notificationsEnabled: true,
      );
      try {
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set(model.toFirestore());
        debugPrint('[AuthService] register: success — uid=${user.uid}');
        return 'Success';
      } catch (e) {
        debugPrint('[AuthService] register: Firestore write failed — $e');
        return 'Cannot save data. Please check Firestore Rules.';
      }
    } on FirebaseAuthException catch (e) {
      debugPrint(
        '[AuthService] register: FirebaseAuthException — code=${e.code}',
      );
      if (e.code == 'weak-password') {
        return 'Password must be at least 6 characters.';
      }
      if (e.code == 'email-already-in-use') {
        return 'This email is already in use.';
      }
      return e.message ?? 'Firebase Auth Error';
    } catch (e) {
      debugPrint('[AuthService] register: unexpected error — $e');
      return 'Registration failed. Please try again.';
    }
  }

  Future<String?> login(String email, String password) async {
    debugPrint('[AuthService] login: attempt — email=$email');
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      debugPrint('[AuthService] login: success — $email');
      return 'Success';
    } on FirebaseAuthException catch (e) {
      debugPrint('[AuthService] login: FirebaseAuthException — code=${e.code}');
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        return 'Email or Password is not correct.';
      }
      if (e.code == 'user-disabled') return 'This account has been disabled.';
      if (e.code == 'too-many-requests') {
        return 'Too many attempts. Please try again later.';
      }
      return e.message ?? 'Login failed.';
    } catch (e) {
      debugPrint('[AuthService] login: unexpected error — $e');
      return 'Something went wrong.';
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return 'Success';
    } on FirebaseAuthException catch (e) {
      return _handleAuthException(e);
    } catch (e) {
      return 'An unexpected error occurred';
    }
  }

  Future<UserModel?> getCurrentUserData() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) return null;
      final doc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (!doc.exists || doc.data() == null) return null;
      return UserModel.fromFirestore(doc);
    } catch (e) {
      debugPrint('[AuthService] getCurrentUserData: error — $e');
      return null;
    }
  }

  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Email or password is incorrect';
      case 'wrong-password':
        return 'Email or password is incorrect';
      case 'invalid-email':
        return 'Please enter a valid email';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many login attempts. Please try again later';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled';
      case 'email-already-in-use':
        return 'An account with this email already exists';
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters';
      case 'invalid-credential':
        return 'Email or password is incorrect';
      case 'network-request-failed':
        return 'Network error. Please check your connection';
      default:
        return e.message ?? 'An authentication error occurred';
    }
  }
}
