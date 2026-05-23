import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/auth/domain/entities/auth_user_entity.dart';

class AuthState {
  const AuthState({required this.user});

  final AsyncValue<AuthUserEntity?> user;

  factory AuthState.initial() =>
      const AuthState(user: AsyncValue.loading());

  AuthState copyWith({AsyncValue<AuthUserEntity?>? user}) =>
      AuthState(user: user ?? this.user);
}
