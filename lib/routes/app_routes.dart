import 'package:flutter/material.dart';
import '../presentation/exercise_player_screen/exercise_player_screen.dart';
import '../presentation/splash_screen/splash_screen.dart';
import '../presentation/exam_results_screen/exam_results_screen.dart';
import '../presentation/official_exam_screen/official_exam_screen.dart';
import '../presentation/premium_placeholder_screen/premium_placeholder_screen.dart';
import '../presentation/login_screen/login_screen.dart';
import '../presentation/lives_depleted_screen/lives_depleted_screen.dart';
import '../presentation/module_selection_screen/module_selection_screen.dart';
import '../presentation/home_screen/home_screen.dart';
import '../presentation/lesson_selection_screen/lesson_selection_screen.dart';
import '../presentation/registration_screen/registration_screen.dart';
import '../presentation/review_screen/review_screen.dart';
import '../presentation/progress_screen/progress_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';
import '../presentation/sottomodulo_exercise_list_screen/sottomodulo_exercise_list_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String exercisePlayer = '/exercise-player-screen';
  static const String splash = '/splash-screen';
  static const String examResults = '/exam-results-screen';
  static const String officialExam = '/official-exam-screen';
  static const String premiumPlaceholder = '/premium-placeholder-screen';
  static const String login = '/login-screen';
  static const String livesDepleted = '/lives-depleted-screen';
  static const String moduleSelection = '/module-selection-screen';
  static const String home = '/home-screen';
  static const String lessonSelection = '/lesson-selection-screen';
  static const String registration = '/registration-screen';
  static const String review = '/review-screen';
  static const String progress = '/progress-screen';
  static const String settings = '/settings-screen';
  static const String sottomoduloExerciseList =
      '/sottomodulo-exercise-list-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const SplashScreen(),
    exercisePlayer: (context) => const ExercisePlayerScreen(),
    splash: (context) => const SplashScreen(),
    examResults: (context) => const ExamResultsScreen(),
    officialExam: (context) => const OfficialExamScreen(),
    premiumPlaceholder: (context) => const PremiumPlaceholderScreen(),
    login: (context) => const LoginScreen(),
    livesDepleted: (context) => const LivesDepletedScreen(),
    moduleSelection: (context) => const ModuleSelectionScreen(),
    home: (context) => const HomeScreen(),
    lessonSelection: (context) => const LessonSelectionScreen(),
    registration: (context) => const RegistrationScreen(),
    review: (context) => const ReviewScreen(),
    progress: (context) => const ProgressScreen(),
    settings: (context) => const SettingsScreen(),
    sottomoduloExerciseList: (context) => const SottomoduloExerciseListScreen(),
    // TODO: Add your other routes here
  };
}
