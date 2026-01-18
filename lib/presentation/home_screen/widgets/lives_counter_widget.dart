import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../core/lives_controller.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Lives counter widget displaying remaining daily lives with heart icons
class LivesCounterWidget extends StatelessWidget {
  final int currentLives;
  final int maxLives;
  final DateTime? resetTime;

  LivesCounterWidget({
    super.key,
    required this.currentLives,
    this.maxLives = LivesController.maxLives,
    this.resetTime,
  });

  String _getResetTimeText() {
    if (resetTime == null) return '';
    final now = DateTime.now();
    final difference = resetTime!.difference(now);

    if (difference.inHours > 0) {
      return 'Reset tra ${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return 'Reset tra ${difference.inMinutes}m';
    }
    return 'Reset a breve';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLowLives = currentLives <= 2;
    final isDepleted = currentLives == 0;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Vite Disponibili',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (resetTime != null)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 2.w,
                    vertical: 0.5.h,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getResetTimeText(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 1.5.h),
          Row(
            children: [
              ...List.generate(
                maxLives,
                (index) => Padding(
                  padding: EdgeInsets.only(right: 1.w),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: CustomIconWidget(
                      iconName: index < currentLives
                          ? 'favorite'
                          : 'favorite_border',
                      color: index < currentLives
                          ? (isLowLives
                                ? const Color(0xFFE74C3C)
                                : const Color(0xFFF39C12))
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                      size: 24,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                '$currentLives/$maxLives',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDepleted
                      ? const Color(0xFFE74C3C)
                      : (isLowLives
                            ? const Color(0xFFF39C12)
                            : theme.colorScheme.primary),
                ),
              ),
            ],
          ),
          if (isDepleted) ...[
            SizedBox(height: 1.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: const Color(0xFFE74C3C).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'info_outline',
                    color: const Color(0xFFE74C3C),
                    size: 16,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      'Torna domani per nuove vite!',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFE74C3C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
