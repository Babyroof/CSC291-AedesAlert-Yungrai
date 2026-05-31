import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aedes_alert_yungrai/features/profile/domain/entities/user_profile_entity.dart';

class UserProfileModel {
  const UserProfileModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.fcmToken,
    required this.notificationsEnabled,
  });

  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final String fcmToken;
  final bool notificationsEnabled;

  factory UserProfileModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return UserProfileModel(
      uid: doc.id,
      firstName: data['firstName'] as String? ?? '',
      lastName: data['lastName'] as String? ?? '',
      email: data['email'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
      fcmToken: data['fcmToken'] as String? ?? '',
      notificationsEnabled: data['notificationsEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'firstName': firstName,
    'lastName': lastName,
    'email': email,
    'phoneNumber': phoneNumber,
    'fcmToken': fcmToken,
    'notificationsEnabled': notificationsEnabled,
  };

  UserProfileEntity toEntity() => UserProfileEntity(
    uid: uid,
    firstName: firstName,
    lastName: lastName,
    email: email,
    phoneNumber: phoneNumber,
    notificationsEnabled: notificationsEnabled,
  );

  factory UserProfileModel.fromEntity(
    UserProfileEntity entity, {
    String fcmToken = '',
  }) => UserProfileModel(
    uid: entity.uid,
    firstName: entity.firstName,
    lastName: entity.lastName,
    email: entity.email,
    phoneNumber: entity.phoneNumber,
    fcmToken: fcmToken,
    notificationsEnabled: entity.notificationsEnabled,
  );
}
