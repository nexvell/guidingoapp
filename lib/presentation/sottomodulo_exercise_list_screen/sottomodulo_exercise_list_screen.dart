
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
  String _moduleId = '';
  String _sottomoduloId = '';
  String _sottomoduloTitle = '';
  List<int> _questionIds = const [];
  bool _isInitialized = false;
  bool _hasValidArgs = false;

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
        _hasValidArgs = _moduleId.isNotEmpty &&
            _sottomoduloId.isNotEmpty &&
            _sottomoduloTitle.isNotEmpty &&
            _questionIds.isNotEmpty;
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

    if (!_hasValidArgs) {
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
            'Sottomodulo non disponibile',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.warning_amber_rounded, size: 48, color: theme.colorScheme.error),
                SizedBox(height: 2.h),
                Text(
                  'Non siamo riusciti a caricare gli esercizi di questo sottomodulo. Torna indietro e riprova.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 3.h),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Torna alle lezioni'),
                ),
              ],
            ),
          ),
        ),
      );
    }

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
