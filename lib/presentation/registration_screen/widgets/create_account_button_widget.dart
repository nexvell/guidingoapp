import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Create account button with loading state
class CreateAccountButtonWidget extends StatelessWidget {
  final bool isEnabled;
  final bool isLoading;
  final VoidCallback onPressed;

  const CreateAccountButtonWidget({
    super.key,
    required this.isEnabled,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: isEnabled && !isLoading ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: isEnabled
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.12),
          foregroundColor: isEnabled
              ? theme.colorScheme.onPrimary
              : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.38),
          elevation: isEnabled ? 2 : 0,
          shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
        ),
        child: isLoading
            ? SizedBox(
                height: 2.5.h,
                width: 2.5.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.colorScheme.onPrimary,
                  ),
                ),
              )
            : Text(
                'Crea Account',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isEnabled
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.38,
                        ),
                ),
              ),
      ),
    );
  }
}
