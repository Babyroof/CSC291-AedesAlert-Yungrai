import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/profile/domain/entities/user_profile_entity.dart';

class ProfileState {
  const ProfileState({required this.profile, required this.saving});

  final AsyncValue<UserProfileEntity?> profile;
  final bool saving;

  factory ProfileState.initial() =>
      const ProfileState(profile: AsyncValue.loading(), saving: false);

  ProfileState copyWith({
    AsyncValue<UserProfileEntity?>? profile,
    bool? saving,
  }) => ProfileState(
    profile: profile ?? this.profile,
    saving: saving ?? this.saving,
  );
}
