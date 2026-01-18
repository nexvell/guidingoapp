import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Large action button for main learning modes
class ActionButtonWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String iconName;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;
  final String? badgeText;
  final bool isDisabled;

  const ActionButtonWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.iconName,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
    this.badgeText,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isDisabled
              ? null
              : () {
                  HapticFeedback.selectionClick();
                  onTap();
                },
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            constraints: BoxConstraints(minHeight: 12.h),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isDisabled
                  ? []
                  : [
                      BoxShadow(
                        color: backgroundColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: textColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: CustomIconWidget(
                    iconName: iconName,
                    color: textColor,
                    size: 32,
                  ),
                ),
                SizedBox(width: 4.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: textColor.withValues(alpha: 0.8),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (badgeText != null) ...[
                  SizedBox(width: 2.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.h,
                    ),
                    decoration: BoxDecoration(
                      color: textColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      badgeText!,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: backgroundColor,
                      ),
                    ),
                  ),
                ],
                SizedBox(width: 2.w),
                CustomIconWidget(
                  iconName: 'arrow_forward_ios',
                  color: textColor,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
