import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import './core/attempts_tracker.dart';
import './core/lives_controller.dart';
import './core/progress_store.dart';
import './presentation/splash_screen/splash_screen.dart';
import './services/supabase_service.dart';
import 'core/app_export.dart';
import 'widgets/custom_error_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations first
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  runApp(const AppBootstrap());
}

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  bool _isReady = false;
  bool _supabaseInitialized = false;
  String? _errorMessage;
  ProgressStore? _progressStore;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    final progressStore = ProgressStore();

    try {
      await progressStore.initialize();
    } catch (e) {
      _errorMessage = 'Errore durante il caricamento dei dati locali.';
      debugPrint('Failed to initialize ProgressStore: $e');
    }

    try {
      await SupabaseService.initialize().timeout(
        const Duration(seconds: 10),
      );
      _supabaseInitialized = true;
    } catch (e) {
      _errorMessage ??= 'Impossibile connettersi. Controlla la connessione.';
      debugPrint('Failed to initialize Supabase: $e');
    }

    if (_supabaseInitialized) {
      await LivesController().initialize();
      await AttemptsTracker().initialize();
    }

    if (mounted) {
      setState(() {
        _progressStore = progressStore;
        _isReady = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isReady || _progressStore == null) {
      return MaterialApp(
        title: 'Guidingo',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const _BootstrapLoadingScreen(),
        debugShowCheckedModeBanner: false,
      );
    }

    return MyApp(
      supabaseInitialized: _supabaseInitialized,
      progressStore: _progressStore!,
      errorMessage: _errorMessage,
    );
  }
}

class MyApp extends StatelessWidget {
  final bool supabaseInitialized;
  final ProgressStore progressStore;
  final String? errorMessage;

  const MyApp({
    super.key,
    required this.supabaseInitialized,
    required this.progressStore,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: progressStore,
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return MaterialApp(
            title: 'Guidingo',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: ThemeMode.system,
            home: supabaseInitialized
                ? const SplashScreen()
                : CustomErrorWidget(
                    errorMessage: errorMessage ??
                        'Impossibile connettersi. Controlla la tua connessione e riavvia l\'app.',
                  ),
            routes: AppRoutes.routes,
            debugShowCheckedModeBanner: false, // Optional: clean up the UI
          );
        },
      ),
    );
  }
}

class _BootstrapLoadingScreen extends StatelessWidget {
  const _BootstrapLoadingScreen();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              colorScheme.primary,
              colorScheme.primaryContainer,
              colorScheme.secondary,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.directions_car,
                  size: 64,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
                const SizedBox(height: 16),
                Text(
                  'Guidingo',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
