import 'package:aedes_alert_yungrai/features/auth/domain/entities/auth_user_entity.dart';

abstract class AuthRepository {
  Stream<AuthUserEntity?> get authStateChanges;
  Future<AuthUserEntity> signIn({required String email, required String password});
  Future<AuthUserEntity> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  });
  Future<void> signOut();
  AuthUserEntity? get currentUser;
}
