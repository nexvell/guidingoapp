import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';

/// Login Screen for DuoLipatente application
/// Provides secure authentication through email/password with Supabase integration
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Validates email format
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Inserisci la tua email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email non valida';
    }
    return null;
  }

  /// Validates password
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Inserisci la tua password';
    }
    if (value.length < 6) {
      return 'La password deve contenere almeno 6 caratteri';
    }
    return null;
  }

  /// Handles login authentication
  Future<void> _handleLogin() async {
    // Clear previous error
    setState(() {
      _errorMessage = null;
    });

    // Validate form
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Dismiss keyboard
    FocusScope.of(context).unfocus();

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate Supabase authentication
      await Future.delayed(const Duration(seconds: 2));

      // Mock credentials for testing
      const mockEmail = 'test@duolipatente.it';
      const mockPassword = 'password123';

      if (_emailController.text.trim() == mockEmail &&
          _passwordController.text == mockPassword) {
        // Success - trigger haptic feedback
        HapticFeedback.lightImpact();

        if (!mounted) return;

        // Navigate to home screen
        Navigator.pushReplacementNamed(context, '/home-screen');
      } else {
        // Invalid credentials
        setState(() {
          _errorMessage = 'Email o password non corretti';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Errore di connessione. Riprova più tardi.';
        _isLoading = false;
      });
    }
  }

  /// Handles forgot password action
  void _handleForgotPassword() {
    HapticFeedback.selectionClick();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funzionalità in arrivo'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// Navigates to registration screen
  void _navigateToRegistration() {
    HapticFeedback.selectionClick();
    Navigator.pushNamed(context, '/registration-screen');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: const CustomAppBar(
        style: CustomAppBarStyle.transparent,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 4.h),
                    _buildLogo(theme),
                    SizedBox(height: 6.h),
                    _buildWelcomeText(theme),
                    SizedBox(height: 4.h),
                    _buildEmailField(theme),
                    SizedBox(height: 2.h),
                    _buildPasswordField(theme),
                    SizedBox(height: 1.h),
                    _buildForgotPasswordButton(theme),
                    if (_errorMessage != null) ...[
                      SizedBox(height: 2.h),
                      _buildErrorMessage(theme),
                    ],
                    SizedBox(height: 4.h),
                    _buildLoginButton(theme),
                    SizedBox(height: 3.h),
                    _buildRegistrationPrompt(theme),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds app logo
  Widget _buildLogo(ThemeData theme) {
    return Center(
      child: Container(
        width: 30.w,
        height: 30.w,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: 'directions_car',
            size: 15.w,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  /// Builds welcome text
  Widget _buildWelcomeText(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Bentornato!',
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 1.h),
        Text(
          'Accedi per continuare il tuo percorso',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  /// Builds email input field
  Widget _buildEmailField(ThemeData theme) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      autocorrect: false,
      enabled: !_isLoading,
      style: theme.textTheme.bodyLarge,
      decoration: InputDecoration(
        labelText: 'Email',
        hintText: 'esempio@email.com',
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: 'email',
            size: 5.w,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
      ),
      validator: _validateEmail,
    );
  }

  /// Builds password input field
  Widget _buildPasswordField(ThemeData theme) {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      textInputAction: TextInputAction.done,
      enabled: !_isLoading,
      style: theme.textTheme.bodyLarge,
      onFieldSubmitted: (_) => _handleLogin(),
      decoration: InputDecoration(
        labelText: 'Password',
        hintText: 'Inserisci la tua password',
        prefixIcon: Padding(
          padding: EdgeInsets.all(3.w),
          child: CustomIconWidget(
            iconName: 'lock',
            size: 5.w,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        suffixIcon: IconButton(
          icon: CustomIconWidget(
            iconName: _isPasswordVisible ? 'visibility' : 'visibility_off',
            size: 5.w,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        filled: true,
        fillColor: theme.colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
        ),
      ),
      validator: _validatePassword,
    );
  }

  /// Builds forgot password button
  Widget _buildForgotPasswordButton(ThemeData theme) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _isLoading ? null : _handleForgotPassword,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
          minimumSize: Size(20.w, 6.h),
        ),
        child: Text(
          'Password dimenticata?',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Builds error message display
  Widget _buildErrorMessage(ThemeData theme) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'error',
            size: 5.w,
            color: theme.colorScheme.error,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Text(
              _errorMessage!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds login button
  Widget _buildLoginButton(ThemeData theme) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        padding: EdgeInsets.symmetric(vertical: 2.h),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        minimumSize: Size(double.infinity, 7.h),
      ),
      child: _isLoading
          ? SizedBox(
              height: 5.w,
              width: 5.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.onPrimary,
                ),
              ),
            )
          : Text(
              'Accedi',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ),
            ),
    );
  }

  /// Builds registration prompt
  Widget _buildRegistrationPrompt(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Nuovo utente? ',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        TextButton(
          onPressed: _isLoading ? null : _navigateToRegistration,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
            minimumSize: Size(20.w, 6.h),
          ),
          child: Text(
            'Registrati',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
