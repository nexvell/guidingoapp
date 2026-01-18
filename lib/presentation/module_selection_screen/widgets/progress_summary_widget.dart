import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:percent_indicator/percent_indicator.dart';

/// Progress summary widget showing overall learning progress and next recommended module
class ProgressSummaryWidget extends StatelessWidget {
  final int totalModules;
  final int completedModules;
  final double overallProgress;
  final Map<String, dynamic> nextRecommendedModule;

  const ProgressSummaryWidget({
    super.key,
    required this.totalModules,
    required this.completedModules,
    required this.overallProgress,
    required this.nextRecommendedModule,
  });

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

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.emoji_events_rounded,
                size: 24,
                color: theme.colorScheme.primary,
              ),
              SizedBox(width: 2.w),
              Text(
                'Il Tuo Progresso',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Progress bar
          Row(
            children: [
              Expanded(
                child: LinearPercentIndicator(
                  lineHeight: 12,
                  percent: overallProgress.clamp(0.0, 1.0),
                  backgroundColor: theme.colorScheme.surface.withValues(
                    alpha: 0.5,
                  ),
                  progressColor: theme.colorScheme.primary,
                  barRadius: const Radius.circular(6),
                  padding: EdgeInsets.zero,
                ),
              ),
              SizedBox(width: 3.w),
              Text(
                '${(overallProgress * 100).toInt()}%',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 1.h),
          // Stats
          Text(
            '$completedModules di $totalModules moduli completati',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 2.h),
          // Divider
          Container(
            height: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.2),
          ),
          SizedBox(height: 2.h),
          // Next recommended module
          Text(
            'Prossimo Consigliato',
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 1.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.w),
                decoration: BoxDecoration(
                  color: Color(
                    nextRecommendedModule["color"] as int,
                  ).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getIconData(nextRecommendedModule["icon"] as String),
                  size: 20,
                  color: Color(nextRecommendedModule["color"] as int),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextRecommendedModule["title"] as String,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      '${nextRecommendedModule["totalLessons"]} lezioni • ${nextRecommendedModule["estimatedTime"]}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Motivational message
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_rounded,
                  size: 20,
                  color: const Color(0xFFF39C12),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    completedModules == 0
                        ? 'Inizia il tuo viaggio verso la patente!'
                        : overallProgress >= 0.5
                        ? 'Ottimo lavoro! Continua così!'
                        : 'Stai facendo progressi fantastici!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
