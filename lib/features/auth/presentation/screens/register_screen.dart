import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:aedes_alert_yungrai/core/constants/app_colors.dart';
import 'package:aedes_alert_yungrai/core/routes/app_router.dart';
import 'package:aedes_alert_yungrai/core/utils/validators.dart';
import 'package:aedes_alert_yungrai/features/auth/widgets/custom_text_field.dart';
import 'package:aedes_alert_yungrai/features/auth/services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  final AuthService? authService;

  const RegisterScreen({super.key, this.authService});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  bool _isLoading = false;
  String? _backendError;
  late final AuthService _authService;

  @override
  void initState() {
    super.initState();
    _authService = widget.authService ?? AuthService();
    _emailController.addListener(_clearErrorOnType);
    _passwordController.addListener(_clearErrorOnType);
    _firstNameController.addListener(_clearErrorOnType);
    _lastNameController.addListener(_clearErrorOnType);
    _phoneNumberController.addListener(_clearErrorOnType);
  }

  void _clearErrorOnType() {
    if (_backendError != null) {
      setState(() {
        _backendError = null;
      });
      _formKey.currentState?.validate();
    }
  }

  @override
  void dispose() {
    _emailController.removeListener(_clearErrorOnType);
    _passwordController.removeListener(_clearErrorOnType);
    _firstNameController.removeListener(_clearErrorOnType);
    _lastNameController.removeListener(_clearErrorOnType);
    _phoneNumberController.removeListener(_clearErrorOnType);
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) => AppValidators.email(value);

  String? _validatePassword(String? value) => AppValidators.password(value);

  String? _validateName(String? value) => AppValidators.name(value);

  String? _validatePhone(String? value) => AppValidators.phoneNumber(value);

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _authService.register(
        _emailController.text.trim(),
        _passwordController.text,
        _firstNameController.text.trim(),
        _lastNameController.text.trim(),
        _phoneNumberController.text.trim(),
      );
      if (mounted) {
        if (result == "Success") {
          if (mounted) {
            context.go(routeHome);
          }
        } else {
          setState(() {
            _backendError = result ?? 'Registration failed';
          });
          _formKey.currentState!.validate();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Registration error')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToLogin() {
    context.go(routeLogin);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              // Top Image Section with Aedes Mosquito
              Container(
                height: MediaQuery.of(context).size.height * 0.25,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  image: DecorationImage(
                    image: AssetImage('assets/images/Background.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  // Overlay for better text visibility
                  color: Colors.black.withValues(alpha: 0.2),
                ),
              ),
              // Bottom Content Section
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 255, 255, 255),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Yungrai Text with Bug Icon
                          Row(
                            children: [
                              // Bug Icon
                              const Icon(
                                Icons.pest_control_outlined,
                                color: AppColors.primary,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              // Yungrai Text
                              SizedBox(
                                width: 103,
                                height: 32,
                                child: const Text(
                                  'Yungrai',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w800,
                                    fontSize: 24,
                                    height: 1.3333,
                                    letterSpacing: 0,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          // Sign Up Heading
                          const Text(
                            'Sign Up',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 18,
                              height: 1.33,
                              letterSpacing: 0,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Description
                          const Text(
                            'Create an account to continue',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              height: 1.0,
                              letterSpacing: 0,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Registration Form
                          Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Email Field
                                CustomTextField(
                                  label: 'Email',
                                  hintText: 'Enter Email',
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  validator: _validateEmail,
                                ),
                                const SizedBox(height: 20),
                                // Password Field
                                CustomTextField(
                                  label: 'Password',
                                  hintText: 'Enter Password',
                                  controller: _passwordController,
                                  isPassword: true,
                                  validator: _validatePassword,
                                ),
                                const SizedBox(height: 20),
                                // Name Fields (First Name and Surname)
                                Row(
                                  children: [
                                    Expanded(
                                      child: CustomTextField(
                                        label: 'Name',
                                        hintText: 'First Name',
                                        controller: _firstNameController,
                                        validator: _validateName,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: CustomTextField(
                                        label: 'Surname',
                                        hintText: 'Surname',
                                        controller: _lastNameController,
                                        validator: _validateName,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                // Phone Number Field
                                CustomTextField(
                                  label: 'Phone Number',
                                  hintText: '+66  000 000 00000',
                                  controller: _phoneNumberController,
                                  keyboardType: TextInputType.phone,
                                  validator: _validatePhone,
                                ),
                                const SizedBox(height: 32),
                                // Sign Up Button
                                SizedBox(
                                  width: double.infinity,
                                  height: 46,
                                  child: ElevatedButton(
                                    onPressed: _isLoading
                                        ? null
                                        : _handleSignUp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF05108B),
                                      padding: const EdgeInsets.fromLTRB(
                                        6,
                                        12,
                                        6,
                                        12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 3,
                                      shadowColor: const Color(
                                        0xFF05108B,
                                      ).withValues(alpha: 0.4),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            height: 24,
                                            width: 24,
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                    Colors.white,
                                                  ),
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Text(
                                            'Sign Up',
                                            style: TextStyle(
                                              fontFamily: 'Poppins',
                                              fontWeight: FontWeight.w500,
                                              fontSize: 16,
                                              height: 1.375,
                                              letterSpacing: 0,
                                              color: Colors.white,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Sign In Link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Already have an account ',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w400,
                                  fontSize: 14,
                                  height: 1.0,
                                  letterSpacing: 0,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Semantics(
                                container: true,
                                label: 'Sign In',
                                button: true,
                                excludeSemantics: true,
                                child: GestureDetector(
                                  onTap: _navigateToLogin,
                                  child: const Text(
                                    'Sign In',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      height: 1.0,
                                      letterSpacing: 0,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
