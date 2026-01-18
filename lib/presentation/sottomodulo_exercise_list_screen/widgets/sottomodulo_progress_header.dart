import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

/// Sottomodulo Progress Header - Shows overall completion progress
class SottomoduloProgressHeader extends StatelessWidget {
  final int completedExercises;
  final int totalExercises;
  final double progress;

  const SottomoduloProgressHeader({
    super.key,
    required this.completedExercises,
    required this.totalExercises,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.08),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Progress ring
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 20.w,
                height: 20.w,
                child: CircularProgressIndicator(
                  value: progress,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    colorScheme.primary,
                  ),
                  strokeWidth: 8,
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$completedExercises',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    'di $totalExercises',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 2.h),
          // Progress text
          Text(
            completedExercises == totalExercises
                ? 'Sottomodulo completato! 🎉'
                : completedExercises == 0
                ? 'Inizia il primo quiz'
                : 'Continua il tuo percorso',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 1.h),
          // Motivational message
          Text(
            completedExercises == totalExercises
                ? 'Ottimo lavoro! Pronto per il prossimo sottomodulo?'
                : '${totalExercises - completedExercises} esercizi rimanenti',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
