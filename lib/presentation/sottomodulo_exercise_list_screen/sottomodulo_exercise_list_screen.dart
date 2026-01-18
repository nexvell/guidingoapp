import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/progress_store.dart';
import '../../routes/app_routes.dart';
import './widgets/exercise_tile_widget.dart';
import './widgets/sottomodulo_progress_header.dart';

class SottomoduloExerciseListScreen extends StatefulWidget {
  const SottomoduloExerciseListScreen({super.key});

  @override
  State<SottomoduloExerciseListScreen> createState() =>
      _SottomoduloExerciseListScreenState();
}

class _SottomoduloExerciseListScreenState
    extends State<SottomoduloExerciseListScreen> {
  final ProgressStore _progressStore = ProgressStore();
  late String _moduleId;
  late String _sectionId;
  late String _sottomoduloTitle;
  final int _totalExercises = 15;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _progressStore.initialize();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        // CRITICAL FIX: Ensure moduleId and sectionId are consistently strings
        final rawModuleId = args['moduleId'];
        final rawSectionId = args['sectionId'];

        _moduleId = rawModuleId?.toString() ?? 'default_module';
        _sectionId = rawSectionId?.toString() ?? 'default_section';
        _sottomoduloTitle = args['title'] ?? 'Sottomodulo';

        print(
          '📋 Sottomodulo initialized - ModuleID: $_moduleId (type: ${_moduleId.runtimeType}), SectionID: $_sectionId (type: ${_sectionId.runtimeType})',
        );

        // DIAGNOSTIC: Print current progress state
        final completedCount = _progressStore.getCompletedCount(
          _moduleId,
          _sectionId,
        );
        print(
          '📊 Current progress: $completedCount/$_totalExercises completed',
        );
      }
      _isInitialized = true;
    }
  }

  void _onExerciseTap(int exerciseNumber) {
    HapticFeedback.selectionClick();

    // DIAGNOSTIC: Log unlock status
    final isUnlocked = _progressStore.isQuizUnlocked(
      _moduleId,
      _sectionId,
      exerciseNumber,
    );
    final isCompleted = _progressStore.isQuizCompleted(
      _moduleId,
      _sectionId,
      exerciseNumber,
    );
    print(
      '🔓 Quiz $exerciseNumber - Unlocked: $isUnlocked, Completed: $isCompleted',
    );

    // Check if exercise is unlocked
    if (!isUnlocked) {
      print('🔒 Quiz $exerciseNumber is locked, showing message');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Completa Quiz ${exerciseNumber - 1} per sbloccare questo esercizio',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    print('🚀 Navigating to Quiz $exerciseNumber with args:');
    print('   - moduleId: $_moduleId');
    print('   - sectionId: $_sectionId');
    print('   - exerciseNumber: $exerciseNumber');

    // Navigate to exercise player
    Navigator.pushNamed(
      context,
      AppRoutes.exercisePlayer,
      arguments: {
        'moduleId': _moduleId,
        'sectionId': _sectionId,
        'exerciseNumber': exerciseNumber,
        'sottomoduloTitle': _sottomoduloTitle,
        'totalExercises': _totalExercises,
        'mode': 'sottomodulo',
      },
    ).then((completed) {
      print('🔙 Returned from Quiz $exerciseNumber, completed: $completed');

      // ALWAYS refresh state when returning, regardless of completion
      setState(() {
        // Force rebuild to show updated progress
        final newCompletedCount = _progressStore.getCompletedCount(
          _moduleId,
          _sectionId,
        );
        print(
          '📊 Updated progress after return: $newCompletedCount/$_totalExercises',
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final completedCount = _progressStore.getCompletedCount(
      _moduleId,
      _sectionId,
    );
    final progress = completedCount / _totalExercises;

    // DIAGNOSTIC: Log build state
    print(
      '🎨 Building with progress: $completedCount/$_totalExercises (${(progress * 100).toStringAsFixed(0)}%)',
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: theme.colorScheme.onSurface,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _sottomoduloTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress header
            SottomoduloProgressHeader(
              completedExercises: completedCount,
              totalExercises: _totalExercises,
              progress: progress,
            ),

            // Exercise list
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                itemCount: _totalExercises,
                itemBuilder: (context, index) {
                  final exerciseNumber = index + 1;
                  final isCompleted = _progressStore.isQuizCompleted(
                    _moduleId,
                    _sectionId,
                    exerciseNumber,
                  );
                  final isUnlocked = _progressStore.isQuizUnlocked(
                    _moduleId,
                    _sectionId,
                    exerciseNumber,
                  );

                  return Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: ExerciseTileWidget(
                      exercise: {
                        'id': exerciseNumber,
                        'title': 'Quiz $exerciseNumber',
                        'type': 'Quiz',
                        'estimatedTime': '5-10 min',
                        'state': isCompleted
                            ? 'completed'
                            : (isUnlocked ? 'current' : 'locked'),
                        'isLocked': !isUnlocked,
                      },
                      onTap: () => _onExerciseTap(exerciseNumber),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
