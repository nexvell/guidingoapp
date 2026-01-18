import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Widget displaying expandable feature comparison between free and premium plans
class FeatureComparisonWidget extends StatefulWidget {
  const FeatureComparisonWidget({super.key});

  @override
  State<FeatureComparisonWidget> createState() =>
      _FeatureComparisonWidgetState();
}

class _FeatureComparisonWidgetState extends State<FeatureComparisonWidget> {
  final Set<int> _expandedSections = {};

  final List<Map<String, dynamic>> _comparisonData = [
    {
      'category': 'Apprendimento',
      'features': [
        {'name': 'Vite giornaliere', 'free': '6 vite', 'premium': 'Illimitate'},
        {'name': 'Accesso alle lezioni', 'free': 'Tutte', 'premium': 'Tutte'},
        {'name': 'Ripasso intelligente', 'free': 'Base', 'premium': 'Avanzato'},
        {
          'name': 'Esami ufficiali',
          'free': 'Limitati',
          'premium': 'Illimitati',
        },
      ],
    },
    {
      'category': 'Statistiche e Progressi',
      'features': [
        {
          'name': 'Tracciamento progressi',
          'free': 'Base',
          'premium': 'Dettagliato',
        },
        {'name': 'Analisi performance', 'free': 'No', 'premium': 'Sì'},
        {'name': 'Grafici avanzati', 'free': 'No', 'premium': 'Sì'},
        {'name': 'Confronto con altri', 'free': 'No', 'premium': 'Sì'},
      ],
    },
    {
      'category': 'Esperienza Utente',
      'features': [
        {'name': 'Pubblicità', 'free': 'Sì', 'premium': 'No'},
        {'name': 'Accesso offline', 'free': 'No', 'premium': 'Sì'},
        {'name': 'Download lezioni', 'free': 'No', 'premium': 'Sì'},
        {'name': 'Supporto prioritario', 'free': 'No', 'premium': 'Sì'},
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Confronto Dettagliato',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Column(
              children: [
                _buildComparisonHeader(theme),
                ..._comparisonData.asMap().entries.map((entry) {
                  final index = entry.key;
                  final section = entry.value;
                  return _buildComparisonSection(theme, section, index);
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonHeader(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Funzionalità',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              'Gratuito',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              'Premium',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonSection(
    ThemeData theme,
    Map<String, dynamic> section,
    int sectionIndex,
  ) {
    final isExpanded = _expandedSections.contains(sectionIndex);
    final features = section['features'] as List<Map<String, String>>;

    return Column(
      children: [
        InkWell(
          onTap: () {
            setState(() {
              if (isExpanded) {
                _expandedSections.remove(sectionIndex);
              } else {
                _expandedSections.add(sectionIndex);
              }
            });
          },
          child: Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    section['category'] as String,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: CustomIconWidget(
                    iconName: 'keyboard_arrow_down',
                    color: theme.colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: const SizedBox.shrink(),
          secondChild: Column(
            children: features.map((feature) {
              return _buildFeatureRow(theme, feature);
            }).toList(),
          ),
          crossFadeState: isExpanded
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          duration: const Duration(milliseconds: 200),
        ),
      ],
    );
  }

  Widget _buildFeatureRow(ThemeData theme, Map<String, String> feature) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              feature['name'] ?? '',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: _buildFeatureValue(theme, feature['free'] ?? '', false),
          ),
          Expanded(
            child: _buildFeatureValue(theme, feature['premium'] ?? '', true),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureValue(ThemeData theme, String value, bool isPremium) {
    final isCheckmark =
        value == 'Sì' ||
        value == 'Illimitate' ||
        value == 'Illimitati' ||
        value == 'Tutte';
    final isCross = value == 'No';

    return Center(
      child: isCheckmark
          ? CustomIconWidget(
              iconName: 'check_circle',
              color: isPremium
                  ? theme.colorScheme.primary
                  : const Color(0xFF27AE60),
              size: 20,
            )
          : isCross
          ? CustomIconWidget(
              iconName: 'cancel',
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              size: 20,
            )
          : Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isPremium
                    ? theme.colorScheme.primary
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: isPremium ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
    );
  }
}
