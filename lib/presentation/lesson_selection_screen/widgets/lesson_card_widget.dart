import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Individual lesson card with game-like progression visualization
class LessonCardWidget extends StatelessWidget {
  final Map<String, dynamic> lesson;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const LessonCardWidget({
    super.key,
    required this.lesson,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLocked = lesson["isLocked"] == true;
    final status = lesson["status"] as String;
    final completedExercises = lesson["completedExercises"] as int;
    final totalExercises = lesson["totalExercises"] as int;
    final progress = totalExercises > 0
        ? completedExercises / totalExercises
        : 0.0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        onLongPress();
      },
      child: Container(
        constraints: const BoxConstraints(minHeight: 140),
        decoration: BoxDecoration(
          color: isLocked
              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isLocked
                ? colorScheme.outline.withValues(alpha: 0.2)
                : status == "completed"
                ? const Color(0xFF27AE60).withValues(alpha: 0.3)
                : status == "in_progress"
                ? colorScheme.primary.withValues(alpha: 0.3)
                : colorScheme.outline.withValues(alpha: 0.2),
            width: 2,
          ),
          boxShadow: isLocked
              ? []
              : [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // Progress background
            if (!isLocked && progress > 0)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary.withValues(alpha: 0.1),
                              colorScheme.primary.withValues(alpha: 0.05),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            // Content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Status icon
                      _buildStatusIcon(status, isLocked, colorScheme),
                      const SizedBox(width: 12),

                      // Title and exercise count
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              lesson["title"] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isLocked
                                    ? colorScheme.onSurfaceVariant
                                    : colorScheme.onSurface,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${lesson["exerciseCount"]} esercizi',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Difficulty stars
                      _buildDifficultyStars(
                        lesson["difficulty"] as int,
                        isLocked,
                        colorScheme,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Progress bar or lock message
                  if (isLocked)
                    _buildLockedMessage(lesson, theme, colorScheme)
                  else if (status == "completed")
                    _buildCompletedActions(theme, colorScheme)
                  else
                    _buildProgressSection(
                      completedExercises,
                      totalExercises,
                      progress,
                      theme,
                      colorScheme,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIcon(
    String status,
    bool isLocked,
    ColorScheme colorScheme,
  ) {
    if (isLocked) {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: CustomIconWidget(
          iconName: 'lock',
          color: colorScheme.onSurfaceVariant,
          size: 24,
        ),
      );
    }

    if (status == "completed") {
      return Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF27AE60).withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: CustomIconWidget(
          iconName: 'check_circle',
          color: const Color(0xFF27AE60),
          size: 24,
        ),
      );
    }

    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: CustomIconWidget(
        iconName: 'school',
        color: colorScheme.primary,
        size: 24,
      ),
    );
  }

  Widget _buildDifficultyStars(
    int difficulty,
    bool isLocked,
    ColorScheme colorScheme,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        3,
        (index) => Padding(
          padding: const EdgeInsets.only(left: 2),
          child: CustomIconWidget(
            iconName: index < difficulty ? 'star' : 'star_border',
            color: isLocked
                ? colorScheme.onSurfaceVariant.withValues(alpha: 0.5)
                : const Color(0xFFF39C12),
            size: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildLockedMessage(
    Map<String, dynamic> lesson,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: 'info_outline',
            color: colorScheme.onSurfaceVariant,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Completa "${lesson["requiredLesson"]}" per sbloccare',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletedActions(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF27AE60).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CustomIconWidget(
                  iconName: 'check_circle',
                  color: const Color(0xFF27AE60),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Completato',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: const Color(0xFF27AE60),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            'Ripeti',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection(
    int completed,
    int total,
    double progress,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$completed / $total esercizi',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              completed > 0 ? 'Continua' : 'Inizia',
              style: theme.textTheme.labelLarge?.copyWith(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
