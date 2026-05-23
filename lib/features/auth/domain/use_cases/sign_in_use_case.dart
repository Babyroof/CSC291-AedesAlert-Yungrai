import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/auth/domain/entities/auth_user_entity.dart';
import 'package:aedes_alert_yungrai/features/auth/domain/repositories/auth_repository.dart';
import 'package:aedes_alert_yungrai/features/auth/data/repositories/auth_repository_impl.dart';

class SignInUseCase {
  const SignInUseCase(this._repository);

  final AuthRepository _repository;

  Future<AuthUserEntity> execute({
    required String email,
    required String password,
  }) {
    return _repository.signIn(email: email, password: password);
  }
}

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  return SignInUseCase(ref.watch(authRepositoryProvider));
});
