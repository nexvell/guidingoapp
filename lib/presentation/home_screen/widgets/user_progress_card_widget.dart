import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// User progress card displaying XP, streak, and motivational message
class UserProgressCardWidget extends StatelessWidget {
  final int currentXP;
  final int targetXP;
  final int streakDays;
  final String motivationalMessage;

  UserProgressCardWidget({
    super.key,
    required this.currentXP,
    required this.targetXP,
    required this.streakDays,
    required this.motivationalMessage,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressPercent = targetXP > 0
        ? (currentXP / targetXP).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Il Tuo Progresso',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      motivationalMessage,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF39C12).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'local_fire_department',
                      color: const Color(0xFFF39C12),
                      size: 20,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '$streakDays',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFF39C12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'XP',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '$currentXP / $targetXP',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    LinearPercentIndicator(
                      padding: EdgeInsets.zero,
                      lineHeight: 8,
                      percent: progressPercent,
                      backgroundColor:
                          theme.colorScheme.surfaceContainerHighest,
                      progressColor: theme.colorScheme.primary,
                      barRadius: const Radius.circular(4),
                      animation: true,
                      animationDuration: 800,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
