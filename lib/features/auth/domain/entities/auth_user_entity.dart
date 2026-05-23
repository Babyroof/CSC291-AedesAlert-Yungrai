class AuthUserEntity {
  const AuthUserEntity({
    required this.uid,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.notificationsEnabled = true,
  });

  final String uid;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final bool notificationsEnabled;
}
