import 'package:flutter/material.dart';

import '../../../core/app_export.dart';

/// Header widget showing exercise progress and lives counter
class ExerciseHeaderWidget extends StatelessWidget {
  final int currentExercise;
  final int totalExercises;
  final int lives;
  final VoidCallback onBackPressed;

  const ExerciseHeaderWidget({
    super.key,
    required this.currentExercise,
    required this.totalExercises,
    required this.lives,
    required this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            // Back button
            GestureDetector(
              onTap: onBackPressed,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: CustomIconWidget(
                  iconName: 'close',
                  color: colorScheme.onSurface,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Progress text
            Expanded(
              child: Text(
                'Esercizio $currentExercise/$totalExercises',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  letterSpacing: 0.15,
                ),
              ),
            ),
            // Lives counter
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: lives <= 2
                    ? const Color(0xFFE74C3C).withValues(alpha: 0.12)
                    : const Color(0xFFF39C12).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: 'favorite',
                    color: lives <= 2
                        ? const Color(0xFFE74C3C)
                        : const Color(0xFFF39C12),
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$lives',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: lives <= 2
                          ? const Color(0xFFE74C3C)
                          : const Color(0xFFF39C12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
