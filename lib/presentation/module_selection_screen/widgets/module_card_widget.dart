import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:percent_indicator/percent_indicator.dart';

/// Reusable module card widget displaying module information and progress
class ModuleCardWidget extends StatelessWidget {
  final Map<String, dynamic> module;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const ModuleCardWidget({
    super.key,
    required this.module,
    required this.onTap,
    required this.onLongPress,
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
    final isLocked = module["isLocked"] as bool;
    final isActive = module["isActive"] as bool;
    final progress = module["progress"] as double;
    final moduleColor = Color(module["color"] as int);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: isActive
                ? moduleColor.withValues(alpha: 0.08)
                : theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive
                  ? moduleColor.withValues(alpha: 0.3)
                  : theme.colorScheme.outline.withValues(alpha: 0.2),
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: moduleColor.withValues(alpha: 0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with icon and lock/progress
              Row(
                children: [
                  // Module icon
                  Container(
                    padding: EdgeInsets.all(3.w),
                    decoration: BoxDecoration(
                      color: isLocked
                          ? theme.colorScheme.surfaceContainerHighest
                          : moduleColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getIconData(module["icon"] as String),
                      size: 28,
                      color: isLocked
                          ? theme.colorScheme.onSurfaceVariant
                          : moduleColor,
                    ),
                  ),
                  const Spacer(),
                  // Lock icon or progress indicator
                  if (isLocked)
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.lock_rounded,
                        size: 20,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    )
                  else
                    CircularPercentIndicator(
                      radius: 24,
                      lineWidth: 4,
                      percent: progress,
                      center: Text(
                        '${(progress * 100).toInt()}%',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: moduleColor,
                        ),
                      ),
                      progressColor: moduleColor,
                      backgroundColor: moduleColor.withValues(alpha: 0.2),
                      circularStrokeCap: CircularStrokeCap.round,
                    ),
                ],
              ),
              SizedBox(height: 2.h),
              // Module title
              Text(
                module["title"] as String,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isLocked
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.5.h),
              // Module description
              Text(
                module["description"] as String,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 2.h),
              // Stats row
              Row(
                children: [
                  // Lessons count
                  Icon(
                    Icons.school_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    '${module["completedLessons"]}/${module["totalLessons"]} lezioni',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: 4.w),
                  // Estimated time
                  Icon(
                    Icons.schedule_rounded,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    module["estimatedTime"] as String,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              // Action button or unlock requirement
              if (!isLocked) ...[
                SizedBox(height: 2.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isActive
                          ? moduleColor
                          : theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                    ),
                    child: Text(
                      isActive ? 'Continua' : 'Inizia',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(2.w),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          module["unlockRequirement"] as String? ?? "Bloccato",
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
