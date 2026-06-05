import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:aedes_alert_yungrai/core/constants/app_colors.dart';
import 'package:aedes_alert_yungrai/features/auth/services/auth_service.dart';
import 'package:aedes_alert_yungrai/features/profile/presentation/controllers/profile_controller.dart';
import 'package:aedes_alert_yungrai/features/profile/presentation/controllers/profile_state.dart';
import 'package:aedes_alert_yungrai/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:aedes_alert_yungrai/features/profile/presentation/screens/change_password_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _authService = AuthService();
  bool? _localNotificationsEnabled;

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(profileControllerProvider.notifier).loadProfile(uid);
      });
    }
  }

  Future<void> _handleSignOut() async {
    await _authService.logout();
  }

  Future<void> _handleDeleteAccount() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Delete Account',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Color(0xFFBA1A1A),
          ),
        ),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
          style: TextStyle(fontFamily: 'Poppins'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF454652)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Delete',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFFBA1A1A),
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Firebase requires recent login before deleting account
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final passwordController = TextEditingController();
    if (!mounted) return;
    final reAuthConfirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'Confirm Password',
          style: TextStyle(fontFamily: 'Poppins', fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Please enter your password to confirm.',
              style: TextStyle(fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(fontFamily: 'Poppins', color: Color(0xFF454652)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Confirm',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                color: Color(0xFFBA1A1A),
              ),
            ),
          ),
        ],
      ),
    );

    if (reAuthConfirmed != true) return;

    try {
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: passwordController.text,
      );
      await user.reauthenticateWithCredential(credential);
      await ref.read(profileControllerProvider.notifier).deleteAccount();
      await _authService.logout();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect password. Please try again.')),
      );
    }
  }

  Future<void> _handleNotificationToggle(bool value) async {
    setState(() => _localNotificationsEnabled = value);
    final profile = ref.read(profileControllerProvider).profile.valueOrNull;
    if (profile != null) {
      await ref
          .read(profileControllerProvider.notifier)
          .saveProfile(profile.copyWith(notificationsEnabled: value));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<ProfileState>(profileControllerProvider, (_, next) {
      final p = next.profile.valueOrNull;
      if (p != null && _localNotificationsEnabled == null) {
        setState(() => _localNotificationsEnabled = p.notificationsEnabled);
      }
    });

    final profileState = ref.watch(profileControllerProvider);
    final profile = profileState.profile.valueOrNull;
    final authUser = FirebaseAuth.instance.currentUser;

    final profileName = profile != null
        ? '${profile.firstName} ${profile.lastName}'.trim()
        : '';
    final displayName = profileName.isNotEmpty
        ? profileName
        : (authUser?.displayName ?? '');
    final email = (profile?.email ?? '').isNotEmpty
        ? profile!.email
        : (authUser?.email ?? '');
    final notificationsEnabled =
        profile?.notificationsEnabled ?? _localNotificationsEnabled ?? true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Profile',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w500,
            fontSize: 19,
            height: 28 / 19,
            letterSpacing: 0,
            color: Color(0xFF0D1117),
          ),
        ),
        backgroundColor: AppColors.background,
        elevation: 0,
      ),
      body: profileState.profile.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      height: 216,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x0A000000),
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color(0xFF283593), Color(0xFF1A237E)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            displayName,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                              height: 28 / 20,
                              letterSpacing: 0,
                              color: Color(0xFF1B1B21),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            email,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              height: 20 / 14,
                              letterSpacing: 0,
                              color: Color(0xFF454652),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Container(
                      width: double.infinity,
                      height: 75,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Push Notifications',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  height: 24 / 16,
                                  letterSpacing: 0,
                                  color: Color(0xFF1B1B21),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notificationsEnabled ? 'Enabled' : 'Disabled',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 10,
                                  height: 15 / 10,
                                  letterSpacing: 0.5,
                                  color: Color(0xFF454652),
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: notificationsEnabled,
                            onChanged: _handleNotificationToggle,
                            activeThumbColor: const Color(0xFF22C55E),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildProfileMenuItem(
                      icon: Icons.person_outline,
                      iconBackgroundColor: const Color(0xFFE0E0FF),
                      iconColor: AppColors.primary,
                      title: 'Edit Profile',
                      subtitle: profile != null
                          ? '${profile.firstName} · ${profile.lastName} · ${profile.phoneNumber}'
                          : '',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditProfileScreen(),
                          ),
                        ).then((_) {
                          final uid = FirebaseAuth.instance.currentUser?.uid;
                          if (uid != null) {
                            ref
                                .read(profileControllerProvider.notifier)
                                .loadProfile(uid);
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildProfileMenuItem(
                      icon: Icons.lock_outline,
                      iconBackgroundColor: const Color(0xFFEEEEEE),
                      iconColor: const Color(0xFF666666),
                      title: 'Change Password',
                      subtitle: 'Firebase Authentication',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ChangePasswordScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildProfileMenuItem(
                      icon: Icons.exit_to_app_outlined,
                      iconBackgroundColor: const Color(0xFFFFEBEE),
                      iconColor: const Color(0xFFBA1A1A),
                      title: 'Sign Out',
                      subtitle: '',
                      titleColor: const Color(0xFFBA1A1A),
                      titleFontWeight: FontWeight.w500,
                      arrowIconColor: const Color(0xFFBA1A1A),
                      onTap: () => _handleSignOut(),
                    ),
                    const SizedBox(height: 16),
                    _buildProfileMenuItem(
                      icon: Icons.delete_outline,
                      iconBackgroundColor: const Color(0xFFFFEBEE),
                      iconColor: const Color(0xFFBA1A1A),
                      title: 'Delete Account',
                      subtitle: 'Permanently remove your account',
                      titleColor: const Color(0xFFBA1A1A),
                      titleFontWeight: FontWeight.w500,
                      arrowIconColor: const Color(0xFFBA1A1A),
                      onTap: () => _handleDeleteAccount(),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required Color iconBackgroundColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    Color titleColor = const Color(0xFF1B1B21),
    FontWeight titleFontWeight = FontWeight.w600,
    Color arrowIconColor = const Color(0xFF454652),
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: titleFontWeight,
                        fontSize: 16,
                        height: 24 / 16,
                        letterSpacing: 0,
                        color: titleColor,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subtitle,
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 14,
                            height: 20 / 14,
                            letterSpacing: 0,
                            color: Color(0xFF454652),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: arrowIconColor, size: 24),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.divider, height: 1),
        ],
      ),
    );
  }
}
