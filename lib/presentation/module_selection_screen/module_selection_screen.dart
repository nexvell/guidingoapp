import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../widgets/custom_app_bar.dart';
import './widgets/module_card_widget.dart';
import './widgets/progress_summary_widget.dart';

/// Module Selection Screen - Displays available learning modules with progress tracking
/// Implements progressive skill building with lock/unlock states and completion indicators
class ModuleSelectionScreen extends StatefulWidget {
  const ModuleSelectionScreen({super.key});

  @override
  State<ModuleSelectionScreen> createState() => _ModuleSelectionScreenState();
}

class _ModuleSelectionScreenState extends State<ModuleSelectionScreen> {
  bool _isLoading = false;
  bool _isRefreshing = false;

  // Mock data for modules with Italian content
  final List<Map<String, dynamic>> _modules = [
    {
      "id": "segnali",
      "title": "Segnali Stradali",
      "description":
          "Impara a riconoscere e comprendere tutti i segnali stradali italiani",
      "icon": "traffic",
      "progress": 0.35,
      "completedLessons": 7,
      "totalLessons": 20,
      "estimatedTime": "2-3 ore",
      "isLocked": false,
      "isActive": true,
      "difficulty": "Principiante",
      "color": 0xFF4A90E2,
    },
    {
      "id": "precedenza",
      "title": "Precedenza",
      "description": "Regole di precedenza agli incroci e nelle rotatorie",
      "icon": "merge_type",
      "progress": 0.0,
      "completedLessons": 0,
      "totalLessons": 15,
      "estimatedTime": "1-2 ore",
      "isLocked": true,
      "isActive": false,
      "difficulty": "Intermedio",
      "unlockRequirement": "Completa 15 lezioni in Segnali Stradali",
      "color": 0xFF7B68EE,
    },
    {
      "id": "limiti",
      "title": "Limiti di Velocità",
      "description": "Limiti di velocità su diverse strade e condizioni",
      "icon": "speed",
      "progress": 0.0,
      "completedLessons": 0,
      "totalLessons": 12,
      "estimatedTime": "1 ora",
      "isLocked": true,
      "isActive": false,
      "difficulty": "Principiante",
      "unlockRequirement": "Completa Segnali Stradali",
      "color": 0xFFF39C12,
    },
    {
      "id": "distanze",
      "title": "Distanze di Sicurezza",
      "description": "Calcolo e mantenimento delle distanze di sicurezza",
      "icon": "social_distance",
      "progress": 0.0,
      "completedLessons": 0,
      "totalLessons": 10,
      "estimatedTime": "45 minuti",
      "isLocked": true,
      "isActive": false,
      "difficulty": "Intermedio",
      "unlockRequirement": "Completa Limiti di Velocità",
      "color": 0xFF27AE60,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  Future<void> _loadModules() async {
    setState(() => _isLoading = true);
    // Simulate loading from Supabase
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshModules() async {
    setState(() => _isRefreshing = true);
    HapticFeedback.mediumImpact();
    // Simulate refresh from Supabase
    await Future.delayed(const Duration(milliseconds: 1200));
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

    // Navigate to lesson selection screen
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

  void _showLockedModuleDialog(Map<String, dynamic> module) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              Icons.lock_rounded,
              color: theme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text('Modulo Bloccato', style: theme.textTheme.titleLarge),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              module["unlockRequirement"] ??
                  "Completa i moduli precedenti per sbloccare",
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 20,
                    color: theme.colorScheme.primary,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Continua a studiare per sbloccare questo modulo!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                      ),
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
            // Handle bar
            Center(
              child: Container(
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.3,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: 3.h),
            // Module icon and title
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: Color(
                      module["color"] as int,
                    ).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getIconData(module["icon"] as String),
                    size: 28,
                    color: Color(module["color"] as int),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module["title"] as String,
                        style: theme.textTheme.titleLarge,
                      ),
                      Text(
                        module["difficulty"] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            // Description
            Text('Descrizione', style: theme.textTheme.titleMedium),
            SizedBox(height: 1.h),
            Text(
              module["description"] as String,
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 3.h),
            // Learning objectives
            Text(
              'Obiettivi di Apprendimento',
              style: theme.textTheme.titleMedium,
            ),
            SizedBox(height: 1.h),
            _buildObjectiveItem(
              theme,
              'Riconoscere tutti i segnali della categoria',
            ),
            _buildObjectiveItem(
              theme,
              'Comprendere il significato e le applicazioni',
            ),
            _buildObjectiveItem(
              theme,
              'Superare gli esercizi con almeno 80% di precisione',
            ),
            SizedBox(height: 3.h),
            // Stats
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Lezioni',
                    '${module["totalLessons"]}',
                    Icons.school_rounded,
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: _buildStatCard(
                    theme,
                    'Tempo',
                    module["estimatedTime"] as String,
                    Icons.schedule_rounded,
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            // Close button
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
          Icon(
            Icons.check_circle_rounded,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          SizedBox(width: 2.w),
          Expanded(child: Text(text, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
  ) {
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
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
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
        child: _isLoading ? _buildLoadingState(theme) : _buildContent(theme),
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return ListView.separated(
      padding: EdgeInsets.all(4.w),
      itemCount: 3,
      separatorBuilder: (context, index) => SizedBox(height: 2.h),
      itemBuilder: (context, index) => Container(
        height: 20.h,
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(
            alpha: 0.5,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return RefreshIndicator(
      onRefresh: _refreshModules,
      color: theme.colorScheme.primary,
      child: CustomScrollView(
        slivers: [
          // Header section
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(4.w, 3.h, 4.w, 2.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scegli un Modulo',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'Impara passo dopo passo per padroneggiare la teoria',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Module cards
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final module = _modules[index];
                return Padding(
                  padding: EdgeInsets.only(bottom: 2.h),
                  child: ModuleCardWidget(
                    module: module,
                    onTap: () => _handleModuleTap(module),
                    onLongPress: () => _handleModuleLongPress(module),
                  ),
                );
              }, childCount: _modules.length),
            ),
          ),
          // Progress summary
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 4.h),
              child: ProgressSummaryWidget(
                totalModules: _modules.length,
                completedModules: _modules
                    .where((m) => (m["progress"] as double) >= 1.0)
                    .length,
                overallProgress:
                    _modules.fold<double>(
                      0.0,
                      (sum, m) => sum + (m["progress"] as double),
                    ) /
                    _modules.length,
                nextRecommendedModule: _modules.firstWhere(
                  (m) =>
                      m["isLocked"] == false && (m["progress"] as double) < 1.0,
                  orElse: () => _modules.first,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
