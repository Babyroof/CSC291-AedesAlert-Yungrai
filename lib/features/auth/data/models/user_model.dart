import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aedes_alert_yungrai/features/auth/domain/entities/auth_user_entity.dart';

class UserModel {
  const UserModel({
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

  factory UserModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return UserModel(
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

  AuthUserEntity toEntity() => AuthUserEntity(
        uid: uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        notificationsEnabled: notificationsEnabled,
      );
}
