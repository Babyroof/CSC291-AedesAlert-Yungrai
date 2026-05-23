import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/auth/domain/repositories/auth_repository.dart';
import 'package:aedes_alert_yungrai/features/auth/data/repositories/auth_repository_impl.dart';

class SignOutUseCase {
  const SignOutUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> execute() => _repository.signOut();
}

final signOutUseCaseProvider = Provider<SignOutUseCase>((ref) {
  return SignOutUseCase(ref.watch(authRepositoryProvider));
});
