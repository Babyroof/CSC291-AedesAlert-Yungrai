class UserProfileEntity {
  const UserProfileEntity({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phoneNumber,
    required this.notificationsEnabled,
  });

  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String phoneNumber;
  final bool notificationsEnabled;

  UserProfileEntity copyWith({
    String? firstName,
    String? lastName,
    String? phoneNumber,
    bool? notificationsEnabled,
  }) => UserProfileEntity(
    uid: uid,
    firstName: firstName ?? this.firstName,
    lastName: lastName ?? this.lastName,
    email: email,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
  );
}
