import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/benefit_card_widget.dart';
import './widgets/feature_comparison_widget.dart';
import './widgets/pricing_card_widget.dart';
import './widgets/testimonial_carousel_widget.dart';

/// Premium Placeholder Screen showcasing future subscription benefits
/// with compelling value proposition and upgrade pathway optimized for mobile conversion
class PremiumPlaceholderScreen extends StatefulWidget {
  const PremiumPlaceholderScreen({super.key});

  @override
  State<PremiumPlaceholderScreen> createState() =>
      _PremiumPlaceholderScreenState();
}

class _PremiumPlaceholderScreenState extends State<PremiumPlaceholderScreen> {
  bool _isLoading = false;
  String _selectedPlan = 'yearly'; // 'monthly' or 'yearly'

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: 'Premium',
        style: CustomAppBarStyle.centered,
        automaticallyImplyLeading: true,
        onBackPressed: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
      ),
      body: SafeArea(
        child: _isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: theme.colorScheme.primary,
                ),
              )
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildPremiumHeader(theme),
                    SizedBox(height: 3.h),
                    _buildBenefitsSection(theme),
                    SizedBox(height: 4.h),
                    PricingCardWidget(
                      selectedPlan: _selectedPlan,
                      onPlanChanged: (plan) {
                        HapticFeedback.selectionClick();
                        setState(() {
                          _selectedPlan = plan;
                        });
                      },
                      onUpgradePressed: _handleUpgrade,
                    ),
                    SizedBox(height: 3.h),
                    TestimonialCarouselWidget(),
                    SizedBox(height: 4.h),
                    FeatureComparisonWidget(),
                    SizedBox(height: 3.h),
                    _buildCurrentPlanStatus(theme),
                    SizedBox(height: 2.h),
                    _buildFooterLinks(theme),
                    SizedBox(height: 4.h),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildPremiumHeader(ThemeData theme) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
      child: Column(
        children: [
          CustomIconWidget(
            iconName: 'workspace_premium',
            color: theme.colorScheme.onPrimary,
            size: 60,
          ),
          SizedBox(height: 2.h),
          Text(
            'Diventa Premium',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          Text(
            'Sblocca tutte le funzionalità e impara senza limiti',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsSection(ThemeData theme) {
    final benefits = [
      {
        'icon': 'favorite',
        'title': 'Vite Illimitate',
        'description': 'Impara senza interruzioni, nessun limite giornaliero',
        'free': '6 vite/giorno',
        'premium': 'Illimitate',
      },
      {
        'icon': 'bar_chart',
        'title': 'Statistiche Avanzate',
        'description': 'Analisi dettagliate del tuo progresso e performance',
        'free': 'Base',
        'premium': 'Avanzate',
      },
      {
        'icon': 'cloud_download',
        'title': 'Accesso Offline',
        'description':
            'Scarica le lezioni e studia ovunque, anche senza internet',
        'free': 'Solo online',
        'premium': 'Offline completo',
      },
      {
        'icon': 'block',
        'title': 'Esperienza Senza Pubblicità',
        'description': 'Concentrati solo sullo studio, zero distrazioni',
        'free': 'Con pubblicità',
        'premium': 'Senza pubblicità',
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 2.w),
            child: Text(
              'Vantaggi Premium',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 2.h),
          ...benefits.map(
            (benefit) => Padding(
              padding: EdgeInsets.only(bottom: 2.h),
              child: BenefitCardWidget(
                icon: benefit['icon'] as String,
                title: benefit['title'] as String,
                description: benefit['description'] as String,
                freeFeature: benefit['free'] as String,
                premiumFeature: benefit['premium'] as String,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentPlanStatus(ThemeData theme) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'account_circle',
                color: theme.colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 3.w),
              Text(
                'Piano Attuale: Gratuito',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildUsageStatistic(theme, 'Vite utilizzate oggi', '4 / 6', 0.67),
          SizedBox(height: 1.5.h),
          _buildUsageStatistic(theme, 'Lezioni completate', '12 / 50', 0.24),
          SizedBox(height: 1.5.h),
          _buildUsageStatistic(theme, 'Giorni di streak', '7 giorni', null),
        ],
      ),
    );
  }

  Widget _buildUsageStatistic(
    ThemeData theme,
    String label,
    String value,
    double? progress,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        if (progress != null) ...[
          SizedBox(height: 1.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: theme.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                theme.colorScheme.primary,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFooterLinks(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.w),
      child: Column(
        children: [
          TextButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              _showInfoDialog(
                'Privacy Policy',
                'La tua privacy è importante per noi. Tutti i tuoi dati sono protetti e utilizzati solo per migliorare la tua esperienza di apprendimento.',
              );
            },
            child: Text(
              'Privacy Policy',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              HapticFeedback.selectionClick();
              _showInfoDialog(
                'Termini e Condizioni',
                'Utilizzando Guidingo Premium, accetti i nostri termini di servizio. L\'abbonamento si rinnova automaticamente e può essere annullato in qualsiasi momento.',
              );
            },
            child: Text(
              'Termini e Condizioni',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          SizedBox(height: 1.h),
          Text(
            'Ripristina acquisti',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  void _handleUpgrade() {
    HapticFeedback.mediumImpact();
    setState(() {
      _isLoading = true;
    });

    // Simulate subscription process
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _showUpgradeDialog();
      }
    });
  }

  void _showUpgradeDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CustomIconWidget(
              iconName: 'info',
              color: theme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Text(
                'Funzionalità in Arrivo',
                style: theme.textTheme.titleLarge,
              ),
            ),
          ],
        ),
        content: Text(
          'L\'abbonamento Premium sarà disponibile presto! Stiamo lavorando per offrirti la migliore esperienza di apprendimento possibile.',
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text(
              'OK',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String content) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: theme.textTheme.titleLarge),
        content: Text(content, style: theme.textTheme.bodyMedium),
        actions: [
          TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              Navigator.pop(context);
            },
            child: Text(
              'Chiudi',
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
