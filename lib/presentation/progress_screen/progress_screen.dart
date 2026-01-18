import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/lives_controller.dart';
import '../../core/attempts_tracker.dart';
import '../../widgets/custom_bottom_bar.dart';

/// Progress Screen - Stats and progress tracking
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final LivesController _livesController = LivesController();
  final AttemptsTracker _attemptsTracker = AttemptsTracker();

  // Mock stats data
  int _totalQuestionsAttempted = 0;
  int _correctAnswers = 0;
  int _streakDays = 7;
  int _totalXP = 450;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    await _livesController.initialize();
    await _attemptsTracker.initialize();

    if (mounted) {
      setState(() {
        _totalQuestionsAttempted = _attemptsTracker.attempts.length;
        _correctAnswers = _attemptsTracker.attempts
            .where((a) => a.isCorrect)
            .length;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accuracy = _totalQuestionsAttempted > 0
        ? ((_correctAnswers / _totalQuestionsAttempted) * 100).round()
        : 0;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        title: Text(
          'Progresso',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Stats summary
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primary.withValues(alpha: 0.15),
                      colorScheme.secondary.withValues(alpha: 0.15),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: colorScheme.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'Statistiche Generali',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem(
                          theme,
                          Icons.check_circle,
                          _correctAnswers.toString(),
                          'Corrette',
                          Colors.green,
                        ),
                        _buildStatItem(
                          theme,
                          Icons.format_list_numbered,
                          _totalQuestionsAttempted.toString(),
                          'Totali',
                          colorScheme.primary,
                        ),
                        _buildStatItem(
                          theme,
                          Icons.percent,
                          '$accuracy%',
                          'Precisione',
                          Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(height: 3.h),

              // Lives section
              Text(
                'Vite Giornaliere',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 1.h),
              ListenableBuilder(
                listenable: _livesController,
                builder: (context, _) {
                  return _buildInfoCard(
                    theme,
                    Icons.favorite,
                    '${_livesController.currentLives} / ${_livesController.maxLivesCount}',
                    'Vite rimanenti',
                    Colors.red,
                  );
                },
              ),

              SizedBox(height: 2.h),

              // Streak section
              Text(
                'Serie',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 1.h),
              _buildInfoCard(
                theme,
                Icons.local_fire_department,
                '$_streakDays giorni',
                'Serie attuale',
                Colors.orange,
              ),

              SizedBox(height: 2.h),

              // XP section
              Text(
                'Esperienza',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 1.h),
              _buildInfoCard(
                theme,
                Icons.star,
                '$_totalXP XP',
                'Punti esperienza totali',
                Colors.amber,
              ),

              SizedBox(height: 2.h),

              // Ripasso progress
              Text(
                'Ripasso di Oggi',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 1.h),
              ListenableBuilder(
                listenable: _attemptsTracker,
                builder: (context, _) {
                  return _buildInfoCard(
                    theme,
                    Icons.refresh,
                    '${_attemptsTracker.dailyRipassoProgress} / ${AttemptsTracker.maxDailyRipasso}',
                    'Domande completate oggi',
                    const Color(0xFF7B68EE),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: '/progress-screen',
        onNavigate: (route) {
          if (route != '/progress-screen') {
            Navigator.pushReplacementNamed(context, route);
          }
        },
      ),
    );
  }

  Widget _buildStatItem(
    ThemeData theme,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 32),
        ),
        SizedBox(height: 1.h),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(
    ThemeData theme,
    IconData icon,
    String value,
    String description,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
