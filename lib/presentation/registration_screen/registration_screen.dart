import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_app_bar.dart';
import './widgets/confirm_password_input_widget.dart';
import './widgets/create_account_button_widget.dart';
import './widgets/email_input_widget.dart';
import './widgets/login_link_widget.dart';
import './widgets/password_input_widget.dart';
import './widgets/terms_checkbox_widget.dart';

/// Registration screen for new user account creation with Supabase authentication
/// Implements streamlined mobile form design with real-time validation
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _termsAccepted = false;
  bool _isLoading = false;

  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;

  // Password strength indicator
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.grey;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_validateEmail);
    _passwordController.addListener(_validatePassword);
    _confirmPasswordController.addListener(_validateConfirmPassword);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _validateEmail() {
    setState(() {
      final email = _emailController.text.trim();
      if (email.isEmpty) {
        _emailError = null;
      } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
        _emailError = 'Inserisci un indirizzo email valido';
      } else {
        _emailError = null;
      }
    });
  }

  void _validatePassword() {
    setState(() {
      final password = _passwordController.text;
      if (password.isEmpty) {
        _passwordError = null;
        _passwordStrength = 0.0;
        _passwordStrengthText = '';
        return;
      }

      // Calculate password strength
      int strength = 0;
      if (password.length >= 8) strength++;
      if (password.length >= 12) strength++;
      if (RegExp(r'[A-Z]').hasMatch(password)) strength++;
      if (RegExp(r'[a-z]').hasMatch(password)) strength++;
      if (RegExp(r'[0-9]').hasMatch(password)) strength++;
      if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(password)) strength++;

      _passwordStrength = strength / 6;

      if (strength <= 2) {
        _passwordStrengthText = 'Debole';
        _passwordStrengthColor = const Color(0xFFE74C3C);
        _passwordError = 'La password deve contenere almeno 8 caratteri';
      } else if (strength <= 4) {
        _passwordStrengthText = 'Media';
        _passwordStrengthColor = const Color(0xFFF39C12);
        _passwordError = null;
      } else {
        _passwordStrengthText = 'Forte';
        _passwordStrengthColor = const Color(0xFF27AE60);
        _passwordError = null;
      }
    });
  }

  void _validateConfirmPassword() {
    setState(() {
      final confirmPassword = _confirmPasswordController.text;
      if (confirmPassword.isEmpty) {
        _confirmPasswordError = null;
      } else if (confirmPassword != _passwordController.text) {
        _confirmPasswordError = 'Le password non corrispondono';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  bool get _isFormValid {
    return _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _termsAccepted &&
        _passwordStrength >= 0.33;
  }

  Future<void> _handleRegistration() async {
    if (!_isFormValid) return;

    setState(() => _isLoading = true);
    HapticFeedback.mediumImpact();

    try {
      // Simulate Supabase registration
      await Future.delayed(const Duration(seconds: 2));

      // Check for duplicate email (mock validation)
      if (_emailController.text.toLowerCase() == 'test@example.com') {
        throw Exception('Questo indirizzo email è già registrato');
      }

      // Success - show confirmation and navigate
      if (mounted) {
        HapticFeedback.heavyImpact();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Account creato con successo!',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF27AE60),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );

        // Navigate to home screen after brief delay
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home-screen');
        }
      }
    } catch (e) {
      if (mounted) {
        HapticFeedback.vibrate();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceAll('Exception: ', ''),
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            backgroundColor: const Color(0xFFE74C3C),
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Crea Account',
        automaticallyImplyLeading: true,
        onBackPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Welcome text
                  Text(
                    'Benvenuto!',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Crea il tuo account per iniziare a imparare',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 4.h),

                  // Email input
                  EmailInputWidget(
                    controller: _emailController,
                    errorText: _emailError,
                  ),
                  SizedBox(height: 2.h),

                  // Password input
                  PasswordInputWidget(
                    controller: _passwordController,
                    isPasswordVisible: _isPasswordVisible,
                    onVisibilityToggle: () {
                      setState(() => _isPasswordVisible = !_isPasswordVisible);
                      HapticFeedback.selectionClick();
                    },
                    errorText: _passwordError,
                    passwordStrength: _passwordStrength,
                    passwordStrengthText: _passwordStrengthText,
                    passwordStrengthColor: _passwordStrengthColor,
                  ),
                  SizedBox(height: 2.h),

                  // Confirm password input
                  ConfirmPasswordInputWidget(
                    controller: _confirmPasswordController,
                    isPasswordVisible: _isConfirmPasswordVisible,
                    onVisibilityToggle: () {
                      setState(
                        () => _isConfirmPasswordVisible =
                            !_isConfirmPasswordVisible,
                      );
                      HapticFeedback.selectionClick();
                    },
                    errorText: _confirmPasswordError,
                  ),
                  SizedBox(height: 3.h),

                  // Terms and privacy checkbox
                  TermsCheckboxWidget(
                    isAccepted: _termsAccepted,
                    onChanged: (value) {
                      setState(() => _termsAccepted = value ?? false);
                      HapticFeedback.selectionClick();
                    },
                  ),
                  SizedBox(height: 4.h),

                  // Create account button
                  CreateAccountButtonWidget(
                    isEnabled: _isFormValid,
                    isLoading: _isLoading,
                    onPressed: _handleRegistration,
                  ),
                  SizedBox(height: 3.h),

                  // Login link
                  LoginLinkWidget(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Navigator.pushReplacementNamed(context, '/login-screen');
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
