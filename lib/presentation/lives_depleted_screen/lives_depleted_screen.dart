import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/alternative_actions_widget.dart';
import './widgets/countdown_timer_widget.dart';
import './widgets/lives_info_card_widget.dart';

/// Lives Depleted Screen - Blocking interface when daily lives reach zero
/// Prevents exercise access while encouraging return and maintaining engagement
class LivesDepletedScreen extends StatefulWidget {
  const LivesDepletedScreen({super.key});

  @override
  State<LivesDepletedScreen> createState() => _LivesDepletedScreenState();
}

class _LivesDepletedScreenState extends State<LivesDepletedScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;
  Timer? _countdownTimer;
  Duration _timeUntilReset = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _calculateTimeUntilReset();
    _startCountdownTimer();
  }

  void _initializeAnimations() {
    _heartAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _heartScaleAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(
        parent: _heartAnimationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _calculateTimeUntilReset() {
    final now = DateTime.now().toUtc();
    final romeTime = now.add(const Duration(hours: 1)); // Europe/Rome UTC+1
    final midnight = DateTime(
      romeTime.year,
      romeTime.month,
      romeTime.day + 1,
      0,
      0,
      0,
    );
    final midnightUtc = midnight.subtract(const Duration(hours: 1));

    setState(() {
      _timeUntilReset = midnightUtc.difference(now);
    });
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeUntilReset.inSeconds <= 0) {
        _handleTimerCompletion();
        timer.cancel();
      } else {
        setState(() {
          _timeUntilReset = _timeUntilReset - const Duration(seconds: 1);
        });
      }
    });
  }

  void _handleTimerCompletion() {
    HapticFeedback.mediumImpact();
    _showCelebrationAndDismiss();
  }

  void _showCelebrationAndDismiss() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildCelebrationDialog(),
    ).then((_) {
      Navigator.pushReplacementNamed(context, '/home-screen');
    });
  }

  Widget _buildCelebrationDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: EdgeInsets.all(6.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'celebration',
              color: colorScheme.primary,
              size: 60,
            ),
            SizedBox(height: 2.h),
            Text(
              'Vite Ripristinate!',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 1.h),
            Text(
              'Le tue 6 vite sono state ripristinate. Buono studio!',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 3.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                ),
                child: const Text('Inizia a Studiare'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: colorScheme.surface.withValues(alpha: 0.95),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                colorScheme.primary.withValues(alpha: 0.05),
                colorScheme.surface,
              ],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 3.h),
                child: Column(
                  children: [
                    SizedBox(height: 2.h),
                    _buildHeader(theme, colorScheme),
                    SizedBox(height: 4.h),
                    LivesInfoCardWidget(heartAnimation: _heartScaleAnimation),
                    SizedBox(height: 3.h),
                    CountdownTimerWidget(timeUntilReset: _timeUntilReset),
                    SizedBox(height: 4.h),
                    _buildActionButtons(theme, colorScheme),
                    SizedBox(height: 3.h),
                    AlternativeActionsWidget(),
                    SizedBox(height: 3.h),
                    _buildMotivationalStats(theme, colorScheme),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        CustomIconWidget(iconName: 'block', color: colorScheme.error, size: 48),
        SizedBox(height: 1.h),
        Text(
          'Accesso Temporaneamente Bloccato',
          style: theme.textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, ColorScheme colorScheme) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.pushReplacementNamed(context, '/home-screen');
            },
            icon: CustomIconWidget(
              iconName: 'schedule',
              color: colorScheme.onPrimary,
              size: 20,
            ),
            label: const Text('Torna Domani'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 2.h),
            ),
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              HapticFeedback.selectionClick();
              Navigator.pushNamed(context, '/premium-placeholder-screen');
            },
            icon: CustomIconWidget(
              iconName: 'workspace_premium',
              color: colorScheme.primary,
              size: 20,
            ),
            label: const Text('Scopri Premium'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 2.h),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMotivationalStats(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CustomIconWidget(
                iconName: 'emoji_events',
                color: colorScheme.primary,
                size: 24,
              ),
              SizedBox(width: 2.w),
              Text(
                'I Tuoi Progressi',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildStatRow(
            theme,
            colorScheme,
            'local_fire_department',
            'Streak Attuale',
            '7 giorni',
          ),
          SizedBox(height: 1.h),
          _buildStatRow(
            theme,
            colorScheme,
            'school',
            'Lezioni Completate',
            '12 su 45',
          ),
          SizedBox(height: 1.h),
          _buildStatRow(theme, colorScheme, 'star', 'XP Totali', '2,450 XP'),
          SizedBox(height: 2.h),
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CustomIconWidget(
                  iconName: 'lightbulb',
                  color: colorScheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Text(
                    'Domani: Ripassa "Segnali di Pericolo" per mantenere il tuo streak!',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(
    ThemeData theme,
    ColorScheme colorScheme,
    String iconName,
    String label,
    String value,
  ) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: colorScheme.onSurfaceVariant,
          size: 20,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
