import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:aedes_alert_yungrai/features/auth/domain/use_cases/sign_up_use_case.dart';
import 'package:aedes_alert_yungrai/features/auth/domain/use_cases/sign_out_use_case.dart';
import 'package:aedes_alert_yungrai/features/auth/presentation/controllers/auth_state.dart';

class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required SignInUseCase signIn,
    required SignUpUseCase signUp,
    required SignOutUseCase signOut,
  }) : _signIn = signIn,
       _signUp = signUp,
       _signOut = signOut,
       super(AuthState.initial());

  final SignInUseCase _signIn;
  final SignUpUseCase _signUp;
  final SignOutUseCase _signOut;

  Future<void> signIn({required String email, required String password}) async {
    state = AuthState.initial();
    try {
      final user = await _signIn.execute(email: email, password: password);
      state = AuthState(user: AsyncValue.data(user));
    } catch (e, st) {
      state = AuthState(user: AsyncValue.error(e, st));
    }
  }

  Future<void> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? phoneNumber,
  }) async {
    state = AuthState.initial();
    try {
      final user = await _signUp.execute(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
      );
      state = AuthState(user: AsyncValue.data(user));
    } catch (e, st) {
      state = AuthState(user: AsyncValue.error(e, st));
    }
  }

  Future<void> signOut() async {
    await _signOut.execute();
    state = const AuthState(user: AsyncValue.data(null));
  }
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>(
  (ref) {
    return AuthController(
      signIn: ref.watch(signInUseCaseProvider),
      signUp: ref.watch(signUpUseCaseProvider),
      signOut: ref.watch(signOutUseCaseProvider),
    );
  },
);
