import 'package:firebase_auth/firebase_auth.dart';

/// Service class to handle Firebase authentication operations
class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  /// Get the currently authenticated user
  User? get currentUser => _firebaseAuth.currentUser;

  /// Check if user is authenticated
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  /// Get the current user's UID
  String? get currentUserUid => _firebaseAuth.currentUser?.uid;

  /// Get the current user's email
  String? get currentUserEmail => _firebaseAuth.currentUser?.email;

  /// Login with email and password
  /// Returns "Success" on successful login, or an error message
  Future<String?> login(String email, String password) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return "Success";
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return "An unexpected error occurred";
    }
  }

  /// Register a new user with email and password
  /// Returns "Success" on successful registration, or an error message
  Future<String?> register(
    String email,
    String password,
    String firstName,
    String lastName,
    String phoneNumber,
  ) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      // Update user profile with display name
      await userCredential.user?.updateDisplayName('$firstName $lastName');

      return "Success";
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return "An unexpected error occurred";
    }
  }

  /// Sign out the current user
  Future<void> logout() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  /// Reset password for email
  Future<String?> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email.trim());
      return "Success";
    } on FirebaseAuthException catch (e) {
      return _handleFirebaseAuthException(e);
    } catch (e) {
      return "An unexpected error occurred";
    }
  }

  /// Handle Firebase Authentication exceptions
  String _handleFirebaseAuthException(FirebaseAuthException e) {
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

  /// Stream of authentication state changes
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
