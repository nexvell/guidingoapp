import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Password input field with strength indicator
class PasswordInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final bool isPasswordVisible;
  final VoidCallback onVisibilityToggle;
  final String? errorText;
  final double passwordStrength;
  final String passwordStrengthText;
  final Color passwordStrengthColor;

  const PasswordInputWidget({
    super.key,
    required this.controller,
    required this.isPasswordVisible,
    required this.onVisibilityToggle,
    this.errorText,
    required this.passwordStrength,
    required this.passwordStrengthText,
    required this.passwordStrengthColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 1.h),
        TextField(
          controller: controller,
          obscureText: !isPasswordVisible,
          textInputAction: TextInputAction.next,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: 'Inserisci la password',
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
        if (controller.text.isNotEmpty) ...[
          SizedBox(height: 1.h),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: passwordStrength,
                    backgroundColor: theme.colorScheme.outline.withValues(
                      alpha: 0.2,
                    ),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      passwordStrengthColor,
                    ),
                    minHeight: 0.5.h,
                  ),
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                passwordStrengthText,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: passwordStrengthColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
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
