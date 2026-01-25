import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guidingo/core/data/app_data.dart';
import 'package:guidingo/core/progress_store.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/lesson_card_widget.dart';
import './widgets/lesson_path_visualization_widget.dart';
import './widgets/lesson_preview_bottom_sheet.dart';

class LessonSelectionScreen extends StatefulWidget {
  const LessonSelectionScreen({super.key});

  @override
  State<LessonSelectionScreen> createState() => _LessonSelectionScreenState();
}

class _LessonSelectionScreenState extends State<LessonSelectionScreen> {
  bool _isLoading = true;
  String _moduleId = '';
  String _moduleTitle = '';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _moduleId = args['moduleId'] as String;
      _moduleTitle = args['moduleTitle'] as String;
    }
    _loadLessonData();
  }

  Future<void> _loadLessonData() async {
    // This can be used for any initial async operations if needed
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshLessons() async {
    HapticFeedback.lightImpact();
    setState(() {}); // Re-trigger build to re-calculate progress
  }

  void _navigateToExercisePlayer(Map<String, dynamic> lesson, String moduleId) {
    if (lesson["isLocked"] == true) {
      _showLockedLessonMessage(lesson);
      return;
    }

    HapticFeedback.mediumImpact();

    Navigator.pushNamed(
      context,
      AppRoutes.sottomoduloExerciseList,
      arguments: {
        'sottomoduloTitle': lesson["title"],
        'sottomoduloId': lesson["id"].toString(),
        'totalExercises': lesson["totalExercises"],
        'completedExercises': lesson["completedExercises"],
        'moduleId': moduleId,
        'moduleName': _moduleTitle,
        'questionIds': lesson['questionIds'],
      },
    ).then((_) => setState(() {})); // Refresh on return
  }

  void _showLockedLessonMessage(Map<String, dynamic> lesson) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Completa "${lesson["requiredLesson"]}" per sbloccare questa lezione',
          style: const TextStyle(fontSize: 14),
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showLessonPreview(Map<String, dynamic> lesson) {
    HapticFeedback.selectionClick();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LessonPreviewBottomSheet(lesson: lesson),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState(colorScheme)
            : Consumer<ProgressStore>(
                builder: (context, progressStore, child) {
                  final lessons = AppData.getLessonsForModule(_moduleId);
                  final processedLessons = _processLessons(lessons, progressStore, _moduleId);

                  final totalModuleExercises = processedLessons.fold<int>(0, (sum, l) => sum + (l['totalExercises'] as int));
                  final completedModuleExercises = processedLessons.fold<int>(0, (sum, l) => sum + (l['completedExercises'] as int));
                  final moduleProgress = totalModuleExercises > 0 ? completedModuleExercises / totalModuleExercises : 0.0;

                  return NestedScrollView(
                    headerSliverBuilder: (context, innerBoxIsScrolled) => [
                      SliverAppBar(
                        pinned: true,
                        floating: true,
                        backgroundColor: colorScheme.surface,
                        elevation: 0,
                        leading: IconButton(
                          icon: Icon(Icons.arrow_back_ios_new_rounded, color: colorScheme.onSurface, size: 20),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          tooltip: 'Indietro',
                        ),
                        title: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _moduleTitle,
                              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600, color: colorScheme.onSurface),
                            ),
                            const SizedBox(height: 2),
                            Text('${(moduleProgress * 100).toInt()}% completato', style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                          ],
                        ),
                        bottom: PreferredSize(
                          preferredSize: const Size.fromHeight(4),
                          child: LinearProgressIndicator(
                            value: moduleProgress,
                            backgroundColor: colorScheme.surfaceContainerHighest,
                            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                            minHeight: 4,
                          ),
                        ),
                      ),
                    ],
                    body: _buildLessonList(processedLessons),
                  );
                },
              ),
      ),
      bottomNavigationBar: CustomBottomBar(currentRoute: '/lesson-selection-screen'),
    );
  }

  List<Map<String, dynamic>> _processLessons(List<Map<String, dynamic>> lessons, ProgressStore progressStore, String moduleId) {
    List<Map<String, dynamic>> processed = [];
    bool previousLessonCompleted = true;

    for (var lessonData in lessons) {
      final lessonId = lessonData['id'] as String;
      final questionIds = lessonData['questionIds'] as List<int>;
      final totalExercises = questionIds.length;
      final completedExercises = questionIds.where((qid) => progressStore.isQuizCompleted(moduleId, lessonId, qid)).length;

      final isLocked = !previousLessonCompleted;
      final status = (completedExercises == totalExercises && totalExercises > 0)
          ? "completed"
          : (completedExercises > 0 ? "in_progress" : (isLocked ? "locked" : "not_started"));

      processed.add({
        ...lessonData,
        "totalExercises": totalExercises,
        "completedExercises": completedExercises,
        "isLocked": isLocked,
        "status": status,
        "requiredLesson": lessons.indexOf(lessonData) > 0 ? lessons[lessons.indexOf(lessonData) - 1]['title'] : null,
         "exerciseCount": totalExercises, // Add this for compatibility if needed
        "estimatedDuration": "10-15 min", // Can be made dynamic
      });

      previousLessonCompleted = (status == "completed");
    }
    return processed;
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => Container(
        height: 140,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withAlpha(77),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildLessonList(List<Map<String, dynamic>> lessons) {
    return RefreshIndicator(
      onRefresh: _refreshLessons,
      color: Theme.of(context).colorScheme.primary,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final lesson = lessons[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: LessonCardWidget(
                      lesson: lesson,
                      onTap: () => _navigateToExercisePlayer(lesson, _moduleId),
                      onLongPress: () => _showLessonPreview(lesson),
                    ),
                  );
                },
                childCount: lessons.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: LessonPathVisualizationWidget(
                lessons: lessons,
                moduleProgress: 0, // This widget might need to be updated or removed
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ... Rest of the helper widgets like _buildCompletionStats can be removed or adapted
}
