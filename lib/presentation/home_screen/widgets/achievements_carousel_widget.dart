import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Horizontal carousel displaying recent achievements and tips
class AchievementsCarouselWidget extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const AchievementsCarouselWidget({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Text(
            'Consigli e Traguardi',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
        SizedBox(height: 1.5.h),
        SizedBox(
          height: 14.h,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final isAchievement = item['type'] == 'achievement';

              return Container(
                width: 70.w,
                margin: EdgeInsets.only(right: 3.w),
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isAchievement
                        ? [
                            const Color(0xFF7B68EE).withValues(alpha: 0.15),
                            const Color(0xFF4A90E2).withValues(alpha: 0.15),
                          ]
                        : [
                            const Color(0xFF27AE60).withValues(alpha: 0.15),
                            const Color(0xFF2ECC71).withValues(alpha: 0.15),
                          ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isAchievement
                        ? const Color(0xFF7B68EE).withValues(alpha: 0.3)
                        : const Color(0xFF27AE60).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(2.w),
                      decoration: BoxDecoration(
                        color: isAchievement
                            ? const Color(0xFF7B68EE).withValues(alpha: 0.2)
                            : const Color(0xFF27AE60).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: CustomIconWidget(
                        iconName: item['icon'] as String,
                        color: isAchievement
                            ? const Color(0xFF7B68EE)
                            : const Color(0xFF27AE60),
                        size: 24,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item['title'] as String,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.onSurface,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            item['description'] as String,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
