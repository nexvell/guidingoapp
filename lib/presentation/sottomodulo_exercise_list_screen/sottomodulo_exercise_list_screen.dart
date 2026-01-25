
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
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
  late String _moduleId;
  late String _sottomoduloId;
  late String _sottomoduloTitle;
  late List<int> _questionIds;
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        _moduleId = args['moduleId'] as String;
        _sottomoduloId = args['sottomoduloId'] as String;
        _sottomoduloTitle = args['sottomoduloTitle'] as String;
        _questionIds = (args['questionIds'] as List<dynamic>).cast<int>();
      }
      _isInitialized = true;
    }
  }

  void _onExerciseTap(BuildContext context, int questionId, int index) {
    final progressStore = Provider.of<ProgressStore>(context, listen: false);
    HapticFeedback.selectionClick();

    final bool isFirst = index == 0;
    final int previousQuestionId = isFirst ? -1 : _questionIds[index - 1];
    final bool isUnlocked = isFirst || progressStore.isQuizCompleted(_moduleId, _sottomoduloId, previousQuestionId);

    if (!isUnlocked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa l\'esercizio precedente per sbloccare questo!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    Navigator.pushNamed(
      context,
      AppRoutes.exercisePlayer,
      arguments: {
        'moduleId': _moduleId,
        'sectionId': _sottomoduloId,
        'exerciseNumber': questionId, // The player uses the question ID
        'sottomoduloTitle': _sottomoduloTitle,
        'totalExercises': _questionIds.length,
        'mode': 'sottomodulo',
        'questionIds': _questionIds, // Pass the list for context if needed
      },
    ).then((_) => setState(() {})); // Refresh on return
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<ProgressStore>(
      builder: (context, progressStore, child) {
        final completedCount = _questionIds
            .where((id) => progressStore.isQuizCompleted(_moduleId, _sottomoduloId, id))
            .length;
        final totalExercises = _questionIds.length;
        final progress = totalExercises > 0 ? completedCount / totalExercises : 0.0;

        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: theme.colorScheme.onSurface),
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
                SottomoduloProgressHeader(
                  completedExercises: completedCount,
                  totalExercises: totalExercises,
                  progress: progress,
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                    itemCount: totalExercises,
                    itemBuilder: (context, index) {
                      final questionId = _questionIds[index];
                      final isCompleted = progressStore.isQuizCompleted(_moduleId, _sottomoduloId, questionId);
                      
                      final bool isFirst = index == 0;
                      final int previousQuestionId = isFirst ? -1 : _questionIds[index - 1];
                      final bool isUnlocked = isFirst || progressStore.isQuizCompleted(_moduleId, _sottomoduloId, previousQuestionId);

                      return Padding(
                        padding: EdgeInsets.only(bottom: 2.h),
                        child: ExerciseTileWidget(
                          exercise: {
                            'id': questionId,
                            'title': 'Esercizio ${index + 1}',
                            'type': 'Quiz',
                            'estimatedTime': '5 min',
                            'state': isCompleted
                                ? 'completed'
                                : (isUnlocked ? 'current' : 'locked'),
                            'isLocked': !isUnlocked,
                          },
                          onTap: () => _onExerciseTap(context, questionId, index),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
