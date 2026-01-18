import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ExerciseCardWidget extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final VoidCallback onTap;
  final VoidCallback onMarkAsReviewed;
  final VoidCallback onPostpone;

  const ExerciseCardWidget({
    super.key,
    required this.exercise,
    required this.onTap,
    required this.onMarkAsReviewed,
    required this.onPostpone,
  });

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'overdue':
        return const Color(0xFFE74C3C);
      case 'due_today':
        return const Color(0xFFF39C12);
      case 'optional':
        return const Color(0xFF27AE60);
      default:
        return const Color(0xFF7F8C8D);
    }
  }

  String _getDifficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'overdue':
        return 'In ritardo';
      case 'due_today':
        return 'Da ripassare oggi';
      case 'optional':
        return 'Ripasso opzionale';
      default:
        return 'Normale';
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'true_false':
        return Icons.check_circle_outline;
      case 'multiple_choice':
        return Icons.radio_button_checked;
      case 'match':
        return Icons.compare_arrows;
      default:
        return Icons.help_outline;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'true_false':
        return 'Vero/Falso';
      case 'multiple_choice':
        return 'Scelta multipla';
      case 'match':
        return 'Abbinamento';
      default:
        return 'Esercizio';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final difficulty = exercise["difficulty"] as String;
    final difficultyColor = _getDifficultyColor(difficulty);

    return Slidable(
      key: ValueKey(exercise["id"]),
      startActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              HapticFeedback.mediumImpact();
              onMarkAsReviewed();
            },
            backgroundColor: const Color(0xFF27AE60),
            foregroundColor: Colors.white,
            icon: Icons.check,
            label: 'Rivisto',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const StretchMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              HapticFeedback.mediumImpact();
              onPostpone();
            },
            backgroundColor: const Color(0xFFF39C12),
            foregroundColor: Colors.white,
            icon: Icons.schedule,
            label: 'Domani',
            borderRadius: BorderRadius.circular(12),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: difficultyColor.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: theme.colorScheme.shadow.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
                decoration: BoxDecoration(
                  color: difficultyColor.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: difficultyColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Text(
                      _getDifficultyLabel(difficulty),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: difficultyColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    CustomIconWidget(
                      iconName: 'schedule',
                      color: theme.colorScheme.onSurfaceVariant,
                      size: 14,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '${exercise["daysSinceReview"]} giorni fa',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(3.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (exercise["image"] != null) ...[
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CustomImageWidget(
                              imageUrl: exercise["image"] as String,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                              semanticLabel:
                                  exercise["semanticLabel"] as String? ??
                                  "Exercise image",
                            ),
                          ),
                          SizedBox(width: 3.w),
                        ],
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exercise["question"] as String,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: 1.h),
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'school',
                                    color: theme.colorScheme.primary,
                                    size: 14,
                                  ),
                                  SizedBox(width: 1.w),
                                  Expanded(
                                    child: Text(
                                      exercise["sourceLesson"] as String,
                                      style: theme.textTheme.labelSmall
                                          ?.copyWith(
                                            color: theme.colorScheme.primary,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: _getTypeIcon(
                                  exercise["type"] as String,
                                ).toString().split('.').last,
                                color: theme.colorScheme.primary,
                                size: 14,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                _getTypeLabel(exercise["type"] as String),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondaryContainer
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CustomIconWidget(
                                iconName: 'timer',
                                color: theme.colorScheme.secondary,
                                size: 14,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                exercise["estimatedTime"] as String,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.secondary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        CustomIconWidget(
                          iconName: 'chevron_right',
                          color: theme.colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
