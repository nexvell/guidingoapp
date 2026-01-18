import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/lesson_card_widget.dart';
import './widgets/lesson_path_visualization_widget.dart';
import './widgets/lesson_preview_bottom_sheet.dart';

/// Lesson Selection Screen displays individual lessons within selected module
/// using engaging, game-like progression visualization
class LessonSelectionScreen extends StatefulWidget {
  const LessonSelectionScreen({super.key});

  @override
  State<LessonSelectionScreen> createState() => _LessonSelectionScreenState();
}

class _LessonSelectionScreenState extends State<LessonSelectionScreen> {
  bool _isLoading = false;
  String _selectedModuleName = "Segnali";

  // Mock lesson data for "Segnali" module
  final List<Map<String, dynamic>> _lessons = [
    {
      "id": 1,
      "title": "I 3 segnali base",
      "exerciseCount": 15,
      "completedExercises": 8,
      "totalExercises": 15,
      "difficulty": 1,
      "status": "in_progress",
      "isLocked": false,
      "estimatedDuration": "10 min",
      "exerciseTypes": ["Vero/Falso", "Scelta Multipla"],
      "learningObjectives": [
        "Riconoscere i segnali di pericolo",
        "Comprendere i segnali di divieto",
        "Identificare i segnali di obbligo",
      ],
    },
    {
      "id": 2,
      "title": "Segnali di pericolo",
      "exerciseCount": 20,
      "completedExercises": 20,
      "totalExercises": 20,
      "difficulty": 2,
      "status": "completed",
      "isLocked": false,
      "estimatedDuration": "15 min",
      "exerciseTypes": ["Vero/Falso", "Scelta Multipla", "Abbinamento"],
      "learningObjectives": [
        "Riconoscere tutti i segnali di pericolo",
        "Comprendere il significato di ogni segnale",
        "Applicare le regole corrette",
      ],
    },
    {
      "id": 3,
      "title": "Segnali di divieto",
      "exerciseCount": 18,
      "completedExercises": 0,
      "totalExercises": 18,
      "difficulty": 2,
      "status": "locked",
      "isLocked": true,
      "requiredLesson": "Segnali di pericolo",
      "estimatedDuration": "12 min",
      "exerciseTypes": ["Vero/Falso", "Scelta Multipla"],
      "learningObjectives": [
        "Identificare i segnali di divieto",
        "Comprendere le restrizioni",
        "Rispettare le limitazioni",
      ],
    },
    {
      "id": 4,
      "title": "Segnali di obbligo",
      "exerciseCount": 16,
      "completedExercises": 0,
      "totalExercises": 16,
      "difficulty": 2,
      "status": "locked",
      "isLocked": true,
      "requiredLesson": "Segnali di divieto",
      "estimatedDuration": "12 min",
      "exerciseTypes": ["Vero/Falso", "Scelta Multipla", "Abbinamento"],
      "learningObjectives": [
        "Riconoscere i segnali di obbligo",
        "Comprendere le azioni obbligatorie",
        "Applicare le regole",
      ],
    },
    {
      "id": 5,
      "title": "Segnali di precedenza",
      "exerciseCount": 22,
      "completedExercises": 0,
      "totalExercises": 22,
      "difficulty": 3,
      "status": "locked",
      "isLocked": true,
      "requiredLesson": "Segnali di obbligo",
      "estimatedDuration": "18 min",
      "exerciseTypes": ["Vero/Falso", "Scelta Multipla", "Abbinamento"],
      "learningObjectives": [
        "Comprendere le regole di precedenza",
        "Identificare i segnali di precedenza",
        "Applicare le regole in situazioni complesse",
      ],
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadLessonData();
  }

  Future<void> _loadLessonData() async {
    setState(() => _isLoading = true);
    // Simulate loading from Supabase
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshLessons() async {
    HapticFeedback.lightImpact();
    await _loadLessonData();
  }

  void _navigateToExercisePlayer(Map<String, dynamic> lesson) {
    if (lesson["isLocked"] == true) {
      _showLockedLessonMessage(lesson);
      return;
    }

    HapticFeedback.mediumImpact();

    // MODIFIED: Navigate to sottomodulo exercise list instead of direct exercise player
    Navigator.pushNamed(
      context,
      AppRoutes.sottomoduloExerciseList,
      arguments: {
        'sottomoduloTitle': lesson["title"],
        'sottomoduloId': lesson["id"].toString(),
        'totalExercises': lesson["totalExercises"] ?? 15,
        'completedExercises': lesson["completedExercises"] ?? 0,
        'moduleId': 1,
        'moduleName': _selectedModuleName,
      },
    );
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

  double _calculateModuleProgress() {
    int totalCompleted = 0;
    int totalExercises = 0;

    for (var lesson in _lessons) {
      totalCompleted += (lesson["completedExercises"] as int);
      totalExercises += (lesson["totalExercises"] as int);
    }

    return totalExercises > 0 ? totalCompleted / totalExercises : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final moduleProgress = _calculateModuleProgress();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back_ios_new',
            color: colorScheme.onSurface,
            size: 20,
          ),
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
              _selectedModuleName,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '${(moduleProgress * 100).toInt()}% completato',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
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
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState(colorScheme)
            : _buildLessonList(),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: '/lesson-selection-screen',
      ),
    );
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) => Container(
        height: 140,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLessonList() {
    return RefreshIndicator(
      onRefresh: _refreshLessons,
      color: Theme.of(context).colorScheme.primary,
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                if (index >= _lessons.length) {
                  return _buildCompletionStats();
                }

                final lesson = _lessons[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: LessonCardWidget(
                    lesson: lesson,
                    onTap: () => _navigateToExercisePlayer(lesson),
                    onLongPress: () => _showLessonPreview(lesson),
                  ),
                );
              }, childCount: _lessons.length + 1),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: LessonPathVisualizationWidget(
                lessons: _lessons,
                moduleProgress: _calculateModuleProgress(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionStats() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final completedLessons = _lessons
        .where((l) => l["status"] == "completed")
        .length;
    final totalLessons = _lessons.length;

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primary.withValues(alpha: 0.1),
            colorScheme.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CustomIconWidget(
                iconName: 'emoji_events',
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Progresso del Modulo',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: 'check_circle',
                label: 'Completate',
                value: '$completedLessons/$totalLessons',
                color: const Color(0xFF27AE60),
                theme: theme,
              ),
              Container(
                width: 1,
                height: 40,
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
              _buildStatItem(
                icon: 'school',
                label: 'In Corso',
                value:
                    '${_lessons.where((l) => l["status"] == "in_progress").length}',
                color: const Color(0xFFF39C12),
                theme: theme,
              ),
              Container(
                width: 1,
                height: 40,
                color: colorScheme.outline.withValues(alpha: 0.2),
              ),
              _buildStatItem(
                icon: 'lock',
                label: 'Bloccate',
                value: '${_lessons.where((l) => l["isLocked"] == true).length}',
                color: colorScheme.onSurfaceVariant,
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String icon,
    required String label,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        CustomIconWidget(iconName: icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
