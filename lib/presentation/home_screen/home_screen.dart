import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../core/lives_controller.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../widgets/custom_icon_widget.dart';
import './widgets/achievements_carousel_widget.dart';
import './widgets/action_button_widget.dart';
import './widgets/lives_counter_widget.dart';
import './widgets/user_progress_card_widget.dart';

/// Home Screen - Central hub with lives counter and action buttons
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  final LivesController _livesController = LivesController();

  // User progress data
  int _currentXP = 450;
  final int _targetXP = 1000;
  int _streakDays = 7;
  bool _isRefreshing = false;
  late AnimationController _celebrationController;

  // Mock achievements and tips data
  final List<Map<String, dynamic>> _achievementsData = [
    {
      'type': 'achievement',
      'icon': 'emoji_events',
      'title': '7 Giorni di Fila!',
      'description': 'Hai mantenuto la tua serie per una settimana intera',
    },
    {
      'type': 'tip',
      'icon': 'lightbulb',
      'title': 'Consiglio del Giorno',
      'description':
          'I segnali triangolari indicano sempre pericolo o precedenza',
    },
    {
      'type': 'achievement',
      'icon': 'school',
      'title': 'Primo Modulo Completato',
      'description': 'Hai completato tutti gli esercizi sui segnali base',
    },
    {
      'type': 'tip',
      'icon': 'tips_and_updates',
      'title': 'Strategia di Studio',
      'description': 'Ripassa gli errori ogni giorno per migliorare la memoria',
    },
  ];

  @override
  void initState() {
    super.initState();
    _celebrationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _loadUserData();
  }

  @override
  void dispose() {
    _celebrationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    await _livesController.initialize();

    // Simulate loading user data
    await Future.delayed(const Duration(milliseconds: 500));

    if (mounted) {
      setState(() {});

      // Check for streak milestones
      if (_streakDays % 7 == 0 && _streakDays > 0) {
        _celebrationController.forward();
      }
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    HapticFeedback.mediumImpact();

    await Future.delayed(const Duration(seconds: 1));
    await _livesController.initialize();

    if (mounted) {
      setState(() {
        _isRefreshing = false;
        _currentXP = 450;
        _streakDays = 7;
      });
    }

    HapticFeedback.lightImpact();
  }

  void _navigateToLearn() {
    if (_livesController.currentLives <= 0) {
      Navigator.pushNamed(context, '/lives-depleted-screen');
      return;
    }
    Navigator.pushNamed(context, '/module-selection-screen');
  }

  void _navigateToReview() {
    if (_livesController.currentLives <= 0) {
      Navigator.pushNamed(context, '/lives-depleted-screen');
      return;
    }
    Navigator.pushNamed(context, '/review-screen');
  }

  void _navigateToExam() {
    Navigator.pushNamed(context, '/official-exam-screen');
  }

  String _getMotivationalMessage() {
    if (_streakDays >= 30) {
      return 'Incredibile! Sei un campione della costanza!';
    } else if (_streakDays >= 14) {
      return 'Fantastico! Continua così per raggiungere il mese!';
    } else if (_streakDays >= 7) {
      return 'Ottimo lavoro! Una settimana di studio consecutivo!';
    } else if (_streakDays >= 3) {
      return 'Stai andando alla grande! Continua così!';
    }
    return 'Inizia oggi la tua serie di studio!';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          color: theme.colorScheme.primary,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Sticky header with lives counter
              SliverAppBar(
                floating: true,
                pinned: true,
                elevation: 0,
                backgroundColor: theme.colorScheme.surface,
                expandedHeight: 18.h,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 2.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Ciao! 👋',
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 1.h),
                        ListenableBuilder(
                          listenable: _livesController,
                          builder: (context, _) {
                            return LivesCounterWidget(
                              currentLives: _livesController.currentLives,
                              maxLives: _livesController.maxLivesCount,
                              resetTime: _livesController.getNextResetTime(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Main content
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 2.h),

                      // User progress card
                      UserProgressCardWidget(
                        currentXP: _currentXP,
                        targetXP: _targetXP,
                        streakDays: _streakDays,
                        motivationalMessage: _getMotivationalMessage(),
                      ),

                      SizedBox(height: 3.h),

                      // Main action buttons
                      Text(
                        'Cosa Vuoi Fare Oggi?',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      SizedBox(height: 2.h),

                      // Impara button
                      ListenableBuilder(
                        listenable: _livesController,
                        builder: (context, _) {
                          return ActionButtonWidget(
                            title: 'Impara',
                            subtitle: 'Studia nuovi argomenti e concetti',
                            iconName: 'school',
                            backgroundColor: const Color(0xFF4A90E2),
                            textColor: Colors.white,
                            onTap: _navigateToLearn,
                            isDisabled: _livesController.currentLives <= 0,
                          );
                        },
                      ),

                      SizedBox(height: 2.h),

                      // Ripasso button
                      ListenableBuilder(
                        listenable: _livesController,
                        builder: (context, _) {
                          return ActionButtonWidget(
                            title: 'Ripasso di Oggi',
                            subtitle: '10 domande dal tuo percorso',
                            iconName: 'refresh',
                            backgroundColor: const Color(0xFF7B68EE),
                            textColor: Colors.white,
                            onTap: _navigateToReview,
                            isDisabled: _livesController.currentLives <= 0,
                          );
                        },
                      ),

                      SizedBox(height: 2.h),

                      // Esame Ufficiale button
                      ActionButtonWidget(
                        title: 'Esame Ufficiale',
                        subtitle: '35 domande - Simula l\'esame reale',
                        iconName: 'assignment',
                        backgroundColor: const Color(0xFF27AE60),
                        textColor: Colors.white,
                        onTap: _navigateToExam,
                      ),

                      SizedBox(height: 3.h),

                      // Achievements carousel
                      AchievementsCarouselWidget(items: _achievementsData),

                      SizedBox(height: 3.h),

                      // Premium placeholder CTA
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFF39C12).withValues(alpha: 0.15),
                              const Color(0xFFE74C3C).withValues(alpha: 0.15),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(
                              0xFFF39C12,
                            ).withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFF39C12,
                                ).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: CustomIconWidget(
                                iconName: 'workspace_premium',
                                color: const Color(0xFFF39C12),
                                size: 24,
                              ),
                            ),
                            SizedBox(width: 3.w),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Passa a Premium',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                  ),
                                  SizedBox(height: 0.5.h),
                                  Text(
                                    'Vite illimitate e contenuti esclusivi',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            CustomIconWidget(
                              iconName: 'arrow_forward_ios',
                              color: const Color(0xFFF39C12),
                              size: 20,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: '/home-screen',
        onNavigate: (route) {
          if (route != '/home-screen') {
            Navigator.pushNamed(context, route);
          }
        },
      ),
    );
  }
}
