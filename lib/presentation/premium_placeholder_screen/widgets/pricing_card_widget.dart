import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget displaying subscription pricing options with monthly/yearly toggle
class PricingCardWidget extends StatelessWidget {
  final String selectedPlan;
  final Function(String) onPlanChanged;
  final VoidCallback onUpgradePressed;

  const PricingCardWidget({
    super.key,
    required this.selectedPlan,
    required this.onPlanChanged,
    required this.onUpgradePressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withValues(alpha: 0.1),
            theme.colorScheme.secondary.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          _buildPlanToggle(theme),
          SizedBox(height: 3.h),
          _buildPriceDisplay(theme),
          SizedBox(height: 3.h),
          _buildUpgradeButton(theme),
          SizedBox(height: 2.h),
          _buildSecondaryButton(theme),
        ],
      ),
    );
  }

  Widget _buildPlanToggle(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(child: _buildToggleOption(theme, 'Mensile', 'monthly')),
          Expanded(
            child: _buildToggleOption(
              theme,
              'Annuale',
              'yearly',
              badge: 'Risparmia 30%',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleOption(
    ThemeData theme,
    String label,
    String value, {
    String? badge,
  }) {
    final isSelected = selectedPlan == value;

    return GestureDetector(
      onTap: () => onPlanChanged(value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isSelected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurface,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (badge != null) ...[
              SizedBox(height: 0.5.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.3.h),
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.onPrimary.withValues(alpha: 0.2)
                      : theme.colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  badge,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceDisplay(ThemeData theme) {
    final monthlyPrice = '9,99';
    final yearlyPrice = '69,99';
    final yearlyMonthlyEquivalent = '5,83';

    final displayPrice = selectedPlan == 'monthly' ? monthlyPrice : yearlyPrice;
    final period = selectedPlan == 'monthly' ? 'mese' : 'anno';

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '€',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              displayPrice,
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            SizedBox(width: 2.w),
            Padding(
              padding: EdgeInsets.only(top: 1.h),
              child: Text(
                '/$period',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
        if (selectedPlan == 'yearly') ...[
          SizedBox(height: 1.h),
          Text(
            'Solo €$yearlyMonthlyEquivalent al mese',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildUpgradeButton(ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      height: 6.h,
      child: ElevatedButton(
        onPressed: onUpgradePressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          elevation: 4,
          shadowColor: theme.colorScheme.primary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Prova Gratis 7 Giorni',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 2.w),
            CustomIconWidget(
              iconName: 'arrow_forward',
              color: theme.colorScheme.onPrimary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(ThemeData theme) {
    return TextButton(
      onPressed: () {
        HapticFeedback.lightImpact();
        Navigator.pop(theme as BuildContext);
      },
      child: Text(
        'Forse più tardi',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}
