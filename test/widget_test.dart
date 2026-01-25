
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:guidingo/main.dart';
import 'package:guidingo/core/progress_store.dart';
import 'package:guidingo/presentation/splash_screen/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App smoke test: loads splash screen', (WidgetTester tester) async {
    // Set up a mock for SharedPreferences, which ProgressStore depends on.
    SharedPreferences.setMockInitialValues({});
    
    // Create and initialize the ProgressStore.
    final progressStore = ProgressStore();
    await progressStore.initialize();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(
      supabaseInitialized: true,
      progressStore: progressStore,
    ));
    
    // Wait for any animations/transitions to complete.
    await tester.pumpAndSettle();

    // Verify that the SplashScreen is being shown.
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}
