import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/attempts_tracker.dart';
import '../../core/data/impara_questions.dart';
import '../../core/lives_controller.dart';
import '../../core/mistake_tracker_service.dart';
import '../../core/progress_store.dart';
import '../../routes/app_routes.dart';
import './widgets/exercise_header_widget.dart';
import './widgets/feedback_bottom_sheet.dart';
import './widgets/match_widget.dart';
import './widgets/multiple_choice_widget.dart';
import './widgets/progress_bar_widget.dart';
import './widgets/true_false_widget.dart';

/// Exercise Player Screen - Immersive learning experience with three exercise types
class ExercisePlayerScreen extends StatefulWidget {
  const ExercisePlayerScreen({super.key});

  @override
  State<ExercisePlayerScreen> createState() => _ExercisePlayerScreenState();
}

class _ExercisePlayerScreenState extends State<ExercisePlayerScreen> {
  final AttemptsTracker _attemptsTracker = AttemptsTracker();
  final LivesController _livesController = LivesController();
  final ProgressStore _progressStore = ProgressStore();

  int currentExerciseIndex = 0;
  bool isAnswered = false;
  dynamic selectedAnswer;
  String _mode = 'impara';
  List<Map<String, dynamic>> _exercises = [];

  bool _enableContinuousFlow = false;
  String? _sottomoduloTitle;
  int? _currentExerciseNumber;
  int? _totalExercisesInSottomodulo;
  String? _moduleId;
  String? _sectionId;

  MistakeTrackerService? _mistakeTracker;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

      // Get MistakeTracker if passed (for Ripasso mode)
      _mistakeTracker = args?['mistakeTracker'] as MistakeTrackerService?;

      _isInitialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    print('🔧 Initializing Exercise Player...');

    await _attemptsTracker.initialize();
    await _livesController.initialize();
    await _progressStore.initialize();

    // Get arguments to determine mode and questions
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args =
          ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

      print('📦 Arguments received: $args');

      if (args != null) {
        _mode = args['mode'] ?? 'impara';

        // CRITICAL FIX: Convert moduleId and sectionId to strings to prevent type errors
        final rawModuleId = args['moduleId'];
        final rawSectionId = args['sectionId'];

        _moduleId = rawModuleId?.toString();
        _sectionId = rawSectionId?.toString();
        _currentExerciseNumber = args['exerciseNumber'] as int?;

        print(
          '🎯 Loading quiz - Mode: $_mode, ModuleID: $_moduleId (type: ${_moduleId.runtimeType}), SectionID: $_sectionId (type: ${_sectionId.runtimeType}), ExerciseNum: $_currentExerciseNumber',
        );

        _enableContinuousFlow = args['enableContinuousFlow'] ?? false;
        _sottomoduloTitle = args['sottomoduloTitle'];
        _totalExercisesInSottomodulo = args['totalExercises'];

        // Log what we extracted
        print(
          '📋 Extracted - ModuleID: $_moduleId, SectionID: $_sectionId, ExerciseNum: $_currentExerciseNumber',
        );

        if (args['questions'] != null) {
          // Ripasso mode with pre-selected questions
          _exercises = List<Map<String, dynamic>>.from(args['questions']);
          print(
            '✅ Loaded ${_exercises.length} pre-selected questions for $_mode',
          );
        }
      }

      // If no questions provided, use centralized question bank
      if (_exercises.isEmpty) {
        _exercises = ImparaQuestions.getRandomQuestions(10);
        print(
          '✅ Loaded ${_exercises.length} random questions from centralized bank',
        );
      }

      // DIAGNOSTIC: Check if questions have proper IDs
      if (_exercises.isNotEmpty) {
        print(
          '🔍 First question ID: ${_exercises.first['id']}, Type: ${_exercises.first['type']}',
        );
      }

      // Log exercise types for debugging
      final types = _exercises.map((e) => e['type']).toSet();
      print('📋 Exercise types in session: $types');

      if (mounted) setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_exercises.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currentExercise = _exercises[currentExerciseIndex];
    final progress = (currentExerciseIndex + 1) / _exercises.length;

    return WillPopScope(
      onWillPop: () => _showExitConfirmation(context),
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Column(
          children: [
            // Header with progress and lives
            ExerciseHeaderWidget(
              currentExercise: currentExerciseIndex + 1,
              totalExercises: _exercises.length,
              lives: _livesController.currentLives,
              onBackPressed: () => _showExitConfirmation(context),
            ),
            // Progress bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: ProgressBarWidget(progress: progress),
            ),
            // Exercise content
            Expanded(
              child: _buildExerciseContent(currentExercise, colorScheme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseContent(
    Map<String, dynamic> exercise,
    ColorScheme colorScheme,
  ) {
    final type = exercise['type'] as String;

    print('🎮 Rendering exercise type: $type');

    // Handle both 'official_tf' and 'true_false' types
    if (type == 'true_false' || type == 'official_tf') {
      return TrueFalseWidget(
        question: exercise['question'] as String,
        selectedAnswer: selectedAnswer as bool?,
        onAnswer: (answer) => _handleAnswer(answer, exercise),
      );
    }

    if (type == 'multiple_choice') {
      return MultipleChoiceWidget(
        question: exercise['question'] as String,
        options: (exercise['options'] as List).cast<String>(),
        selectedOption: selectedAnswer as int?,
        onAnswer: (index) => _handleAnswer(index, exercise),
      );
    }

    if (type == 'match') {
      return MatchWidget(
        question: exercise['question'] as String,
        pairs: (exercise['pairs'] as List)
            .map(
              (pair) => (pair as Map<String, dynamic>).cast<String, String>(),
            )
            .toList(),
        onComplete: (matches) => _handleMatchComplete(matches, exercise),
      );
    }

    // If unsupported type, log and show error
    print(
      '❌ UNSUPPORTED EXERCISE TYPE: $type for question ID ${exercise['id']}',
    );
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          SizedBox(height: 2.h),
          Text(
            'Tipo di esercizio non supportato',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          SizedBox(height: 1.h),
          Text('Tipo: $type', style: Theme.of(context).textTheme.bodySmall),
          SizedBox(height: 3.h),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Torna indietro'),
          ),
        ],
      ),
    );
  }

  void _handleAnswer(dynamic answer, Map<String, dynamic> exercise) async {
    if (isAnswered) return;

    setState(() {
      selectedAnswer = answer;
      isAnswered = true;
    });

    final isCorrect = _checkAnswer(answer, exercise);

    print(
      '📝 Answer recorded - QuizID: ${exercise['id']}, Correct: $isCorrect, Mode: $_mode',
    );
    print(
      '📍 Current context - ModuleID: $_moduleId, SectionID: $_sectionId, ExerciseNum: $_currentExerciseNumber',
    );

    // Record attempt in tracker
    await _attemptsTracker.recordAttempt(
      exerciseId: exercise['id'].toString(),
      isCorrect: isCorrect,
      mode: _mode,
    );

    // Record mistake if wrong (FIXED: always initialize tracker)
    if (!isCorrect) {
      if (_mistakeTracker == null) {
        _mistakeTracker = MistakeTrackerService();
        await _mistakeTracker!.initialize();
      }
      await _mistakeTracker!.recordMistake(exercise['id'].toString());
      print('❌ Mistake recorded in MistakeTracker: ${exercise['id']}');

      _livesController.decrementLife();
      HapticFeedback.heavyImpact();

      if (_livesController.currentLives == 0) {
        _showLivesDepletedDialog();
        return;
      }
    } else {
      HapticFeedback.mediumImpact();

      // Mark as correct in MistakeTracker for mastery tracking
      if (_mistakeTracker != null) {
        await _mistakeTracker!.recordCorrectAnswer(exercise['id'].toString());
      }
    }

    // Show feedback bottom sheet
    Future.delayed(const Duration(milliseconds: 300), () {
      FeedbackBottomSheet.show(
        context: context,
        isCorrect: isCorrect,
        explanation: exercise['why_it'] as String,
        tip: exercise['tip_it'] as String?,
        onContinue: _moveToNextExercise,
      );
    });
  }

  void _handleMatchComplete(
    List<Map<String, int>> matches,
    Map<String, dynamic> exercise,
  ) async {
    if (isAnswered) return;

    setState(() {
      selectedAnswer = matches;
      isAnswered = true;
    });

    // For match exercises, check if all pairs are correct
    final isCorrect = matches.length == (exercise['pairs'] as List).length;

    // Record attempt in tracker
    await _attemptsTracker.recordAttempt(
      exerciseId: exercise['id'].toString(),
      isCorrect: isCorrect,
      mode: _mode,
    );

    if (!isCorrect) {
      _livesController.decrementLife();
      HapticFeedback.heavyImpact();

      if (_livesController.currentLives == 0) {
        _showLivesDepletedDialog();
        return;
      }
    } else {
      HapticFeedback.mediumImpact();
    }

    // Show feedback bottom sheet
    Future.delayed(const Duration(milliseconds: 300), () {
      FeedbackBottomSheet.show(
        context: context,
        isCorrect: isCorrect,
        explanation: exercise['why_it'] as String,
        tip: exercise['tip_it'] as String?,
        onContinue: _moveToNextExercise,
      );
    });
  }

  bool _checkAnswer(dynamic answer, Map<String, dynamic> exercise) {
    final type = exercise['type'] as String;

    switch (type) {
      case 'true_false':
        return answer == exercise['correct_answer'];
      case 'multiple_choice':
        return answer == exercise['correct_answer'];
      default:
        return false;
    }
  }

  void _moveToNextExercise() async {
    if (currentExerciseIndex < _exercises.length - 1) {
      setState(() {
        currentExerciseIndex++;
        isAnswered = false;
        selectedAnswer = null;
      });
    } else {
      // CRITICAL FIX: Ensure we're in sottomodulo mode AND have proper IDs
      print(
        '🏁 Quiz completed - Mode: $_mode, ModuleID: $_moduleId, SectionID: $_sectionId, ExerciseNum: $_currentExerciseNumber',
      );

      if (_mode == 'sottomodulo' &&
          _moduleId != null &&
          _sectionId != null &&
          _currentExerciseNumber != null) {
        // Mark quiz as completed in ProgressStore
        print(
          '💾 Marking quiz $_currentExerciseNumber as completed for $_moduleId/$_sectionId',
        );
        await _progressStore.setQuizCompleted(
          _moduleId!,
          _sectionId!,
          _currentExerciseNumber!,
        );

        // Verify it was saved
        final wasCompleted = _progressStore.isQuizCompleted(
          _moduleId!,
          _sectionId!,
          _currentExerciseNumber!,
        );
        print('✅ Verification - Quiz marked completed: $wasCompleted');

        _handleSottomoduloCompletion();
      } else {
        print(
          '⚠️ Not saving progress - Mode: $_mode, Missing IDs: moduleId=$_moduleId, sectionId=$_sectionId, exerciseNum=$_currentExerciseNumber',
        );

        // Update ripasso progress if in ripasso mode
        if (_mode == 'ripasso') {
          _attemptsTracker.incrementRipassoProgress();
        }
        _showCompletionDialog();
      }
    }
  }

  // NEW: Handle sottomodulo exercise completion
  void _handleSottomoduloCompletion() {
    final currentExercise = _currentExerciseNumber ?? 1;
    final totalExercises = _totalExercisesInSottomodulo ?? 15;

    // Check if next exercise is available
    final nextExercise = _progressStore.getNextUnlockedQuiz(
      _moduleId!,
      _sectionId!,
      totalExercises,
    );

    if (nextExercise != null && nextExercise <= totalExercises) {
      // More exercises available - navigate to next exercise
      _showNextExerciseDialog(nextExercise);
    } else {
      // All exercises completed
      _showSottomoduloCompletionDialog();
    }
  }

  // NEW: Show dialog for next exercise
  void _showNextExerciseDialog(int nextExerciseNumber) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Esercizio completato!'),
        content: Text('Ottimo lavoro! Pronto per il Quiz $nextExerciseNumber?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Return to exercise list
            },
            child: const Text('TORNA ALLA LISTA'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              // Navigate to next exercise immediately
              Navigator.pushReplacementNamed(
                context,
                AppRoutes.exercisePlayer,
                arguments: {
                  'sottomoduloTitle': _sottomoduloTitle,
                  'exerciseNumber': nextExerciseNumber,
                  'totalExercises': _totalExercisesInSottomodulo,
                  'mode': 'sottomodulo',
                  'enableContinuousFlow': true,
                },
              );
            },
            child: const Text('PROSSIMO'),
          ),
        ],
      ),
    );
  }

  // NEW: Show sottomodulo completion dialog
  void _showSottomoduloCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Sottomodulo completato! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Complimenti! Hai completato tutti gli esercizi di questo sottomodulo.',
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: Color(0xFF27AE60),
                    size: 32,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    'Sottomodulo completato',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF27AE60),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(
                context,
                true,
              ); // Return to exercise list with completion flag
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF27AE60),
            ),
            child: const Text('TORNA AL MODULO'),
          ),
        ],
      ),
    );
  }

  Future<bool> _showExitConfirmation(BuildContext context) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Uscire dalla lezione?'),
        content: const Text(
          'Il tuo progresso non sarà salvato. Sei sicuro di voler uscire?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('ANNULLA'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('ESCI'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      Navigator.pop(context);
    }

    return false;
  }

  void _showLivesDepletedDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Vite esaurite'),
        content: const Text(
          'Hai esaurito tutte le vite disponibili per oggi. Torna domani per continuare!',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Lezione completata!'),
        content: const Text(
          'Complimenti! Hai completato tutti gli esercizi di questa lezione.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('TORNA ALLA HOME'),
          ),
        ],
      ),
    );
  }
}
