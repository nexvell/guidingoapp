import 'package:flutter/material.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Visual representation of lesson progression path
class LessonPathVisualizationWidget extends StatelessWidget {
  final List<Map<String, dynamic>> lessons;
  final double moduleProgress;

  const LessonPathVisualizationWidget({
    super.key,
    required this.lessons,
    required this.moduleProgress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withValues(alpha: 0.3),
            colorScheme.secondaryContainer.withValues(alpha: 0.3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'route',
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Percorso di Apprendimento',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Path visualization
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: lessons.length,
              itemBuilder: (context, index) {
                final lesson = lessons[index];
                final isLast = index == lessons.length - 1;

                return Row(
                  children: [
                    _buildPathNode(lesson, theme, colorScheme),
                    if (!isLast)
                      _buildPathConnector(
                        lessons[index],
                        lessons[index + 1],
                        colorScheme,
                      ),
                  ],
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Progress summary
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progresso Totale',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(moduleProgress * 100).toInt()}%',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomIconWidget(
                        iconName: 'emoji_events',
                        color: colorScheme.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Continua così!',
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPathNode(
    Map<String, dynamic> lesson,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isLocked = lesson["isLocked"] == true;
    final status = lesson["status"] as String;

    Color nodeColor;
    IconData nodeIcon;

    if (isLocked) {
      nodeColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
      nodeIcon = Icons.lock;
    } else if (status == "completed") {
      nodeColor = const Color(0xFF27AE60);
      nodeIcon = Icons.check_circle;
    } else if (status == "in_progress") {
      nodeColor = colorScheme.primary;
      nodeIcon = Icons.play_circle_filled;
    } else {
      nodeColor = colorScheme.outline;
      nodeIcon = Icons.circle_outlined;
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: nodeColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: nodeColor, width: 2),
          ),
          child: CustomIconWidget(
            iconName: nodeIcon.toString().split('.').last,
            color: nodeColor,
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 80,
          child: Text(
            lesson["title"] as String,
            style: theme.textTheme.bodySmall?.copyWith(
              color: isLocked
                  ? colorScheme.onSurfaceVariant.withValues(alpha: 0.7)
                  : colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildPathConnector(
    Map<String, dynamic> currentLesson,
    Map<String, dynamic> nextLesson,
    ColorScheme colorScheme,
  ) {
    final isCurrentCompleted = currentLesson["status"] == "completed";
    final isNextLocked = nextLesson["isLocked"] == true;

    final connectorColor = isCurrentCompleted && !isNextLocked
        ? colorScheme.primary
        : colorScheme.outline.withValues(alpha: 0.3);

    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.only(bottom: 48),
      color: connectorColor,
    );
  }
}
