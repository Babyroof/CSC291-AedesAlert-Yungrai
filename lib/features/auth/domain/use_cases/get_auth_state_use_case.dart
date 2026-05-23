import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/auth/domain/entities/auth_user_entity.dart';
import 'package:aedes_alert_yungrai/features/auth/domain/repositories/auth_repository.dart';
import 'package:aedes_alert_yungrai/features/auth/data/repositories/auth_repository_impl.dart';

class GetAuthStateUseCase {
  const GetAuthStateUseCase(this._repository);

  final AuthRepository _repository;

  Stream<AuthUserEntity?> execute() => _repository.authStateChanges;
  AuthUserEntity? currentUser() => _repository.currentUser;
}

final getAuthStateUseCaseProvider = Provider<GetAuthStateUseCase>((ref) {
  return GetAuthStateUseCase(ref.watch(authRepositoryProvider));
});
