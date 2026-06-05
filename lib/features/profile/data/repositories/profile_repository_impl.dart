import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/core/constants/app_constants.dart';
import 'package:aedes_alert_yungrai/features/profile/data/models/user_profile_model.dart';
import 'package:aedes_alert_yungrai/features/profile/domain/entities/user_profile_entity.dart';
import 'package:aedes_alert_yungrai/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._firestore);

  final FirebaseFirestore _firestore;

  @override
  Future<UserProfileEntity?> getProfile(String uid) async {
    final doc = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(uid)
        .get();
    if (!doc.exists || doc.data() == null) return null;
    return UserProfileModel.fromFirestore(doc).toEntity();
  }

  @override
  Future<void> updateProfile(UserProfileEntity profile) async {
    final existing = await _firestore
        .collection(AppConstants.usersCollection)
        .doc(profile.uid)
        .get();
    final fcmToken = existing.data()?['fcmToken'] as String? ?? '';
    final model = UserProfileModel.fromEntity(profile, fcmToken: fcmToken);
    await _firestore
        .collection(AppConstants.usersCollection)
        .doc(profile.uid)
        .update(model.toFirestore());
  }

  @override
  Future<void> deleteAccount(String uid) async {
    await _firestore.collection(AppConstants.usersCollection).doc(uid).delete();
  }
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepositoryImpl(FirebaseFirestore.instance);
});
