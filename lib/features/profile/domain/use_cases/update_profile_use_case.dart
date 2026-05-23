import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/profile/domain/entities/user_profile_entity.dart';
import 'package:aedes_alert_yungrai/features/profile/domain/repositories/profile_repository.dart';
import 'package:aedes_alert_yungrai/features/profile/data/repositories/profile_repository_impl.dart';

class UpdateProfileUseCase {
  const UpdateProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<void> execute(UserProfileEntity profile) =>
      _repository.updateProfile(profile);
}

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  return UpdateProfileUseCase(ref.watch(profileRepositoryProvider));
});
