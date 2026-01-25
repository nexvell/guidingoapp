import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guidingo/core/data/app_data.dart';
import 'package:guidingo/core/progress_store.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_app_bar.dart';
import './widgets/module_card_widget.dart';
import './widgets/progress_summary_widget.dart';

class ModuleSelectionScreen extends StatefulWidget {
  const ModuleSelectionScreen({super.key});

  @override
  State<ModuleSelectionScreen> createState() => _ModuleSelectionScreenState();
}

class _ModuleSelectionScreenState extends State<ModuleSelectionScreen> {
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    // Data is now loaded dynamically in the build method
    // This can be used for any initial async operations if needed in the future
    await Future.delayed(const Duration(milliseconds: 200)); // Simulate initial load
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshModules() async {
    setState(() => _isRefreshing = true);
    HapticFeedback.mediumImpact();
    // Re-trigger the build and data processing
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  void _handleModuleTap(Map<String, dynamic> module) {
    HapticFeedback.selectionClick();

    if (module["isLocked"] == true) {
      _showLockedModuleDialog(module);
      return;
    }

    Navigator.pushNamed(
      context,
      '/lesson-selection-screen',
      arguments: {'moduleId': module["id"], 'moduleTitle': module["title"]},
    );
  }

  void _handleModuleLongPress(Map<String, dynamic> module) {
    HapticFeedback.mediumImpact();
    _showModuleDetailsBottomSheet(module);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Impara',
        style: CustomAppBarStyle.standard,
        automaticallyImplyLeading: true,
        showBottomBorder: true,
        onBackPressed: () => Navigator.pop(context),
      ),
      body: SafeArea(
        child: _isLoading
            ? _buildLoadingState(theme)
            : Consumer<ProgressStore>(
                builder: (context, progressStore, child) {
                  return _buildContent(theme, progressStore);
                },
              ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme, ProgressStore progressStore) {
    final modulesData = AppData.modules.map((module) {
      final moduleId = module['id'] as String;
      final lessons = AppData.getLessonsForModule(moduleId);

      int totalQuestions = 0;
      int completedQuestions = 0;
      int completedLessons = 0;

      for (var lesson in lessons) {
        final lessonId = lesson['id'] as String;
        final questionIds = lesson['questionIds'] as List<int>;
        final lessonTotal = questionIds.length;
        final lessonCompleted = questionIds
            .where((qid) => progressStore.isQuizCompleted(moduleId, lessonId, qid))
            .length;
        
        totalQuestions += lessonTotal;
        completedQuestions += lessonCompleted;

        if (lessonCompleted == lessonTotal && lessonTotal > 0) {
          completedLessons++;
        }
      }

      final progress = totalQuestions > 0 ? completedQuestions / totalQuestions : 0.0;
      
      // Locking logic (example: first module always unlocked)
      final isFirstModule = AppData.modules.first['id'] == moduleId;
      bool isLocked = !isFirstModule;
      
      if (!isFirstModule) {
        // Unlock if the previous module is fully completed
        final previousModuleIndex = AppData.modules.indexWhere((m) => m['id'] == moduleId) - 1;
        if (previousModuleIndex >= 0) {
            final prevModule = AppData.modules[previousModuleIndex];
            final prevModuleId = prevModule['id'] as String;
            final prevLessons = AppData.getLessonsForModule(prevModuleId);
            int prevTotalQuestions = 0;
            int prevCompletedQuestions = 0;
            for (var lesson in prevLessons) {
                final questionIds = lesson['questionIds'] as List<int>;
                prevTotalQuestions += questionIds.length;
                prevCompletedQuestions += questionIds.where((qid) => progressStore.isQuizCompleted(prevModuleId, lesson['id'], qid)).length;
            }

            if (prevTotalQuestions > 0 && prevCompletedQuestions == prevTotalQuestions) {
                isLocked = false;
            }
        }
      }


      return {
        ...module,
        "progress": progress,
        "completedLessons": completedLessons,
        "totalLessons": lessons.length,
        "isLocked": isLocked,
        "isActive": !isLocked && progress < 1.0,
        "estimatedTime": "2-3 ore", // This can be made dynamic later
      };
    }).toList();

    return RefreshIndicator(
      onRefresh: _refreshModules,
      color: theme.colorScheme.primary,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Scegli un Modulo', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                  SizedBox(height: 1.h),
                  Text('Impara passo dopo passo per padroneggiare la teoria', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final module = modulesData[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: ModuleCardWidget(
                      module: module,
                      onTap: () => _handleModuleTap(module),
                      onLongPress: () => _handleModuleLongPress(module),
                    ),
                  );
                },
                childCount: modulesData.length,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 4.h),
              child: ProgressSummaryWidget(
                totalModules: modulesData.length,
                completedModules: modulesData.where((m) => (m["progress"] as double) >= 1.0).length,
                overallProgress: modulesData.fold<double>(0.0, (sum, m) => sum + (m["progress"] as double)) / modulesData.length,
                nextRecommendedModule: modulesData.firstWhere(
                  (m) => m["isLocked"] == false && (m["progress"] as double) < 1.0,
                  orElse: () => modulesData.first,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  // Keep the rest of the widgets (_buildLoadingState, _showLockedModuleDialog, etc.) as they are
  // ...
  Widget _buildLoadingState(ThemeData theme) {
    return ListView.separated(
      padding: EdgeInsets.all(4.w),
      itemCount: 3,
      separatorBuilder: (context, index) => SizedBox(height: 2.h),
      itemBuilder: (context, index) => Container(
        height: 20.h,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withAlpha(128),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  void _showLockedModuleDialog(Map<String, dynamic> module) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.lock_rounded, color: theme.colorScheme.primary, size: 24),
            SizedBox(width: 2.w),
            Expanded(child: Text('Modulo Bloccato', style: theme.textTheme.titleLarge)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(module["unlockRequirement"] ?? "Completa i moduli precedenti per sbloccare", style: theme.textTheme.bodyMedium),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded, size: 20, color: theme.colorScheme.primary),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Continua a studiare per sbloccare questo modulo!',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Ho Capito'),
          ),
        ],
      ),
    );
  }

  void _showModuleDetailsBottomSheet(Map<String, dynamic> module) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.all(5.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(77),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Color(module["color"] as int).withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(_getIconData(module["icon"] as String), size: 28, color: Color(module["color"] as int)),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(module["title"] as String, style: theme.textTheme.titleLarge),
                      Text(module["difficulty"] as String, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Text('Descrizione', style: theme.textTheme.titleMedium),
            SizedBox(height: 1.h),
            Text(module["description"] as String, style: theme.textTheme.bodyMedium),
            SizedBox(height: 3.h),
            Text('Obiettivi di Apprendimento', style: theme.textTheme.titleMedium),
            SizedBox(height: 1.h),
            _buildObjectiveItem(theme, 'Riconoscere tutti i segnali della categoria'),
            _buildObjectiveItem(theme, 'Comprendere il significato e le applicazioni'),
            _buildObjectiveItem(theme, 'Superare gli esercizi con almeno 80% di precisione'),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(child: _buildStatCard(theme, 'Lezioni', '${module["totalLessons"]}', Icons.school_rounded)),
                SizedBox(width: 3.w),
                Expanded(child: _buildStatCard(theme, 'Tempo', module["estimatedTime"] as String, Icons.schedule_rounded)),
              ],
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Chiudi'),
              ),
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildObjectiveItem(ThemeData theme, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 1.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle_rounded, size: 20, color: theme.colorScheme.primary),
          SizedBox(width: 2.w),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildStatCard(ThemeData theme, String label, String value, IconData icon) {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: theme.colorScheme.primary),
          SizedBox(height: 1.h),
          Text(value, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'traffic_light':
        return Icons.traffic_rounded;
      case 'rule':
        return Icons.rule_rounded;
      case 'health_and_safety':
        return Icons.health_and_safety_rounded;
      case 'traffic':
        return Icons.traffic_rounded;
      case 'merge_type':
        return Icons.merge_type_rounded;
      case 'speed':
        return Icons.speed_rounded;
      case 'social_distance':
        return Icons.social_distance_rounded;
      default:
        return Icons.school_rounded;
    }
  }
}
