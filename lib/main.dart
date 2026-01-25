import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import './core/attempts_tracker.dart';
import './core/lives_controller.dart';
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

  // Initialize Supabase and handle potential errors
  bool supabaseInitialized = false;
  try {
    await SupabaseService.initialize();
    supabaseInitialized = true;
  } catch (e) {
    debugPrint('Failed to initialize Supabase: $e');
    // If Supabase fails, we'll show an error screen
  }

  if (supabaseInitialized) {
    // Initialize global controllers only if Supabase is working
    await LivesController().initialize();
    await AttemptsTracker().initialize();
  }

  runApp(MyApp(supabaseInitialized: supabaseInitialized));
}

class MyApp extends StatelessWidget {
  final bool supabaseInitialized;

  const MyApp({super.key, required this.supabaseInitialized});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Guidingo',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.system,
          home: supabaseInitialized
              ? const SplashScreen()
              : const CustomErrorWidget(
                  errorMessage: 'Impossibile connettersi. Controlla la tua connessione e riavvia l'app.',
                ),
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
