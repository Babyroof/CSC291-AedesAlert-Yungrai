import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/profile/domain/entities/user_profile_entity.dart';
import 'package:aedes_alert_yungrai/features/profile/domain/repositories/profile_repository.dart';
import 'package:aedes_alert_yungrai/features/profile/data/repositories/profile_repository_impl.dart';

class GetProfileUseCase {
  const GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<UserProfileEntity?> execute(String uid) => _repository.getProfile(uid);
}

final getProfileUseCaseProvider = Provider<GetProfileUseCase>((ref) {
  return GetProfileUseCase(ref.watch(profileRepositoryProvider));
});
