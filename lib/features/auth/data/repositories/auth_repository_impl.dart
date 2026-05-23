import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/core/constants/app_constants.dart';
import 'package:aedes_alert_yungrai/features/auth/data/models/user_model.dart';
import 'package:aedes_alert_yungrai/features/auth/domain/entities/auth_user_entity.dart';
import 'package:aedes_alert_yungrai/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._auth, this._firestore);

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  @override
  Stream<AuthUserEntity?> get authStateChanges {
    return _auth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return _fetchUserEntity(user.uid, user.email ?? '');
    });
  }

  @override
  AuthUserEntity? get currentUser {
    final user = _auth.currentUser;
    if (user == null) return null;
    return AuthUserEntity(uid: user.uid, email: user.email ?? '');
  }

  @override
  Future<AuthUserEntity> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    return _fetchUserEntity(uid, email);
  }

  @override
  Future<AuthUserEntity> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = credential.user!.uid;
    final model = UserModel(
      uid: uid,
      firstName: firstName,
      lastName: lastName,
      email: email,
      phoneNumber: phoneNumber ?? '',
      fcmToken: '',
      notificationsEnabled: true,
    );
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .set(model.toFirestore());
    return model.toEntity();
  }

  @override
  Future<void> signOut() => _auth.signOut();

  Future<AuthUserEntity> _fetchUserEntity(String uid, String email) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists || doc.data() == null) {
      return AuthUserEntity(uid: uid, email: email);
    }
    return UserModel.fromFirestore(doc).toEntity();
  }
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    FirebaseAuth.instance,
    FirebaseFirestore.instance,
  );
});

final authStateChangesProvider = StreamProvider<AuthUserEntity?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});
