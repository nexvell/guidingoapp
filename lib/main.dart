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

  // Initialize Supabase and handle potential errors
  bool supabaseInitialized = false;
  try {
    await SupabaseService.initialize();
    supabaseInitialized = true;
  } catch (e) {
    debugPrint('Failed to initialize Supabase: $e');
  }

  // Create and initialize ProgressStore
  final progressStore = ProgressStore();
  await progressStore.initialize();

  if (supabaseInitialized) {
    // Initialize other global controllers
    await LivesController().initialize();
    await AttemptsTracker().initialize();
  }

  runApp(MyApp(
    supabaseInitialized: supabaseInitialized,
    progressStore: progressStore,
  ));
}

class MyApp extends StatelessWidget {
  final bool supabaseInitialized;
  final ProgressStore progressStore;

  const MyApp({
    super.key,
    required this.supabaseInitialized,
    required this.progressStore,
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
                : const CustomErrorWidget(
                    errorMessage:
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
