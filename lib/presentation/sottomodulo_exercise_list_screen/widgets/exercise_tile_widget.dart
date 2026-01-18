import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Exercise Tile Widget - Individual exercise card with state-based styling
class ExerciseTileWidget extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final VoidCallback onTap;

  const ExerciseTileWidget({
    super.key,
    required this.exercise,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final state = exercise['state'] as String;
    final isLocked = exercise['isLocked'] as bool;

    // Determine colors based on state
    Color buttonColor;
    Color iconColor;
    IconData icon;
    String buttonText;

    switch (state) {
      case 'completed':
        buttonColor = const Color(0xFF27AE60); // Green
        iconColor = Colors.white;
        icon = Icons.check_circle_rounded;
        buttonText = 'Ripeti';
        break;
      case 'current':
        buttonColor = const Color(0xFF4A90E2); // Blue
        iconColor = Colors.white;
        icon = Icons.play_circle_filled_rounded;
        buttonText = 'Continua';
        break;
      case 'locked':
      default:
        buttonColor = colorScheme.surfaceContainerHighest; // Grey
        iconColor = colorScheme.onSurfaceVariant;
        icon = Icons.lock_rounded;
        buttonText = 'Bloccato';
    }

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(
            alpha: isLocked ? 0.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: state == 'current'
                ? buttonColor.withValues(alpha: 0.5)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            // Exercise number badge
            Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                color: buttonColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  '${exercise['id']}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: buttonColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            SizedBox(width: 3.w),
            // Exercise info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise['title'] as String,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isLocked
                          ? colorScheme.onSurfaceVariant
                          : colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  Row(
                    children: [
                      Icon(
                        Icons.quiz_rounded,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        exercise['type'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Icon(
                        Icons.access_time_rounded,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        exercise['estimatedTime'] as String,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Action button
            Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon, size: 20, color: iconColor),
                  if (!isLocked) ...[
                    SizedBox(width: 1.w),
                    Text(
                      buttonText,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
