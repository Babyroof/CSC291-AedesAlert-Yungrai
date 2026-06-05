import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:aedes_alert_yungrai/features/profile/domain/entities/user_profile_entity.dart';
import 'package:aedes_alert_yungrai/features/profile/domain/use_cases/get_profile_use_case.dart';
import 'package:aedes_alert_yungrai/features/profile/domain/use_cases/update_profile_use_case.dart';
import 'package:aedes_alert_yungrai/features/profile/presentation/controllers/profile_state.dart';

class ProfileController extends StateNotifier<ProfileState> {
  ProfileController({
    required GetProfileUseCase getProfile,
    required UpdateProfileUseCase updateProfile,
    required ProfileRepositoryImpl profileRepository,
  }) : _getProfile = getProfile,
       _updateProfile = updateProfile,
       _profileRepository = profileRepository,
       super(ProfileState.initial());

  final GetProfileUseCase _getProfile;
  final UpdateProfileUseCase _updateProfile;
  final ProfileRepositoryImpl _profileRepository;

  Future<void> loadProfile(String uid) async {
    state = ProfileState.initial();
    try {
      final profile = await _getProfile.execute(uid);
      state = state.copyWith(profile: AsyncValue.data(profile));
    } catch (e, st) {
      state = state.copyWith(profile: AsyncValue.error(e, st));
    }
  }

  Future<void> saveProfile(UserProfileEntity profile) async {
    state = state.copyWith(saving: true);
    try {
      await _updateProfile.execute(profile);
      state = state.copyWith(profile: AsyncValue.data(profile), saving: false);
    } catch (_) {
      state = state.copyWith(saving: false);
      rethrow;
    }
  }

  Future<void> deleteAccount() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await _profileRepository.deleteAccount(user.uid);
    await user.delete();
  }
}

final profileControllerProvider =
    StateNotifierProvider<ProfileController, ProfileState>((ref) {
      return ProfileController(
        getProfile: ref.watch(getProfileUseCaseProvider),
        updateProfile: ref.watch(updateProfileUseCaseProvider),
        profileRepository:
            ref.watch(profileRepositoryProvider) as ProfileRepositoryImpl,
      );
    });
