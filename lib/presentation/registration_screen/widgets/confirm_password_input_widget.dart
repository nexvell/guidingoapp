import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Confirm password input field with matching validation
class ConfirmPasswordInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isPasswordVisible;
  final VoidCallback onVisibilityToggle;
  final String? errorText;

  const ConfirmPasswordInputWidget({
    super.key,
    required this.controller,
    required this.isPasswordVisible,
    required this.onVisibilityToggle,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Conferma Password',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: controller,
          obscureText: !isPasswordVisible,
          textInputAction: TextInputAction.done,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Conferma la password',
            hintStyle: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
            ),
            prefixIcon: Padding(
              padding: EdgeInsets.all(3.w),
              child: CustomIconWidget(
                iconName: 'lock',
                size: 5.w,
                color: errorText != null
                    ? const Color(0xFFE74C3C)
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),
            suffixIcon: IconButton(
              icon: CustomIconWidget(
                iconName: isPasswordVisible ? 'visibility_off' : 'visibility',
                size: 5.w,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              onPressed: onVisibilityToggle,
            ),
            filled: true,
            fillColor: theme.colorScheme.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: theme.colorScheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFE74C3C),
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE74C3C), width: 2),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 4.w,
              vertical: 2.h,
            ),
          ),
        ),
        if (errorText != null) ...[
          SizedBox(height: 0.5.h),
          Padding(
            padding: EdgeInsets.only(left: 2.w),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'error',
                  size: 4.w,
                  color: const Color(0xFFE74C3C),
                ),
                SizedBox(width: 1.w),
                Expanded(
                  child: Text(
                    errorText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFFE74C3C),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
