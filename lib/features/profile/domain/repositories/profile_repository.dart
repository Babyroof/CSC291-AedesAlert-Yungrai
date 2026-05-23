import 'package:aedes_alert_yungrai/features/profile/domain/entities/user_profile_entity.dart';

abstract class ProfileRepository {
  Future<UserProfileEntity?> getProfile(String uid);
  Future<void> updateProfile(UserProfileEntity profile);
}
