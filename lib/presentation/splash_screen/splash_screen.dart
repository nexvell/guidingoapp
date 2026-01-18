import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';

/// Splash Screen provides branded app launch experience while initializing
/// core services and determining user navigation path for DuoLipatente.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  bool _isInitializing = true;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeApp();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOutCubic),
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  Future<void> _initializeApp() async {
    try {
      // Simulate initialization tasks
      await Future.wait([
        _checkAuthentication(),
        _loadUserPreferences(),
        _syncExerciseData(),
        _prepareCachedContent(),
      ]);

      // Wait for minimum splash duration
      await Future.delayed(const Duration(milliseconds: 2500));

      if (mounted) {
        _navigateToNextScreen();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = 'Errore di inizializzazione';
        });

        // Show retry option after 5 seconds
        await Future.delayed(const Duration(seconds: 5));
        if (mounted && _hasError) {
          _showRetryOption();
        }
      }
    }
  }

  Future<void> _checkAuthentication() async {
    // Simulate Supabase authentication check
    await Future.delayed(const Duration(milliseconds: 800));
  }

  Future<void> _loadUserPreferences() async {
    // Simulate loading user preferences
    await Future.delayed(const Duration(milliseconds: 600));
  }

  Future<void> _syncExerciseData() async {
    // Simulate syncing exercise data
    await Future.delayed(const Duration(milliseconds: 700));
  }

  Future<void> _prepareCachedContent() async {
    // Simulate preparing cached content for offline access
    await Future.delayed(const Duration(milliseconds: 500));
  }

  void _navigateToNextScreen() {
    // Simulate authentication check result
    final bool isAuthenticated = false; // Mock value
    final bool isNewUser = true; // Mock value

    String targetRoute;
    if (isAuthenticated) {
      targetRoute = '/home-screen';
    } else if (isNewUser) {
      targetRoute = '/registration-screen';
    } else {
      targetRoute = '/login-screen';
    }

    Navigator.pushReplacementNamed(context, targetRoute);
  }

  void _showRetryOption() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          'Errore di Connessione',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          'Impossibile connettersi al server. Verifica la tua connessione internet e riprova.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _hasError = false;
                _errorMessage = '';
              });
              _initializeApp();
            },
            child: const Text('Riprova'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final size = MediaQuery.of(context).size;

    // Set system UI overlay style
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
      ),
    );

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.primaryContainer,
              colorScheme.secondary,
            ],
            stops: const [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    ScaleTransition(
                      scale: _scaleAnimation,
                      child: _buildLogo(colorScheme),
                    ),
                    const SizedBox(height: 24),
                    _buildAppName(theme),
                    const Spacer(flex: 2),
                    _buildLoadingIndicator(colorScheme),
                    const SizedBox(height: 48),
                    if (_hasError) _buildErrorMessage(theme),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(ColorScheme colorScheme) {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: 'directions_car',
          size: 64,
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildAppName(ThemeData theme) {
    return Column(
      children: [
        Text(
          'Guidingo',
          style: theme.textTheme.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Impara la Patente B',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white.withValues(alpha: 0.9),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator(ColorScheme colorScheme) {
    return _isInitializing && !_hasError
        ? SizedBox(
            width: 32,
            height: 32,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.9),
              ),
            ),
          )
        : const SizedBox.shrink();
  }

  Widget _buildErrorMessage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Text(
        _errorMessage,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}
