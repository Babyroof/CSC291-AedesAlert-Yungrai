import 'package:flutter/material.dart';
import 'package:aedes_alert_yungrai/core/constants/app_colors.dart';
import 'package:aedes_alert_yungrai/features/auth/services/auth_service.dart';
import 'package:aedes_alert_yungrai/features/profile/screens/edit_profile_screen.dart';
import 'package:aedes_alert_yungrai/features/profile/screens/change_password_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;
  late final AuthService _authService;
  String? _userDisplayName;
  String? _userEmail;

  @override
  void initState() {
    super.initState();
    _authService = AuthService();
    _userEmail = _authService.currentUserEmail ?? 'somchai@email.com';
    _userDisplayName = _authService.currentUser?.displayName ?? 'Somchai Jaidee';
  }

  @override
  Widget build(BuildContext context) {
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              // Profile Card
              Container(
                width: double.infinity,
                height: 216,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0x0A000000),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // User Avatar
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          // angle: 135 * 3.14159 / 180,
                          colors: [
                            Color(0xFF283593),
                            Color(0xFF1A237E),
                          ],
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
                    // User Name
                    Text(
                      _userDisplayName ?? 'Somchai Jaidee',
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
                    // User Email
                    Text(
                      _userEmail ?? 'somchai@email.com',
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
              // Push Notifications Section
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
                          _notificationsEnabled ? 'NOTIFICATIONSENABLED' : 'NOTIFICATIONSDISABLED',
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
                      value: _notificationsEnabled,
                      onChanged: (value) {
                        setState(() {
                          _notificationsEnabled = value;
                        });
                      },
                      activeColor: const Color(0xFF22C55E),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Edit Profile
              _buildProfileMenuItem(
                icon: Icons.person_outline,
                iconBackgroundColor: const Color(0xFFE0E0FF),
                iconColor: AppColors.primary,
                title: 'Edit Profile',
                subtitle: 'firstName · lastName · phoneNumber',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditProfileScreen(
                        firstName: _userDisplayName?.split(' ').first ?? '',
                        lastName: _userDisplayName?.split(' ').skip(1).join(' ') ?? '',
                        email: _userEmail,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              // Change Password
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
              // Sign Out
              _buildProfileMenuItem(
                icon: Icons.exit_to_app_outlined,
                iconBackgroundColor: const Color(0xFFFFEBEE),
                iconColor: const Color(0xFFBA1A1A),
                title: 'Sign Out',
                subtitle: '',
                titleColor: const Color(0xFFBA1A1A),
                titleFontWeight: FontWeight.w500,
                arrowIconColor: const Color(0xFFBA1A1A),
                onTap: () {
                  // Handle Sign Out
                },
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
              // Icon Container
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackgroundColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Title and Subtitle
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
              // Arrow Icon
              Icon(
                Icons.chevron_right,
                color: arrowIconColor,
                size: 24,
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(
            color: AppColors.divider,
            height: 1,
          ),
        ],
      ),
    );
  }
}
