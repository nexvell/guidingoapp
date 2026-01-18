import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

/// Action buttons widget for exam results screen
class ActionButtonsWidget extends StatelessWidget {
  final bool hasErrors;
  final VoidCallback onTrainErrors;
  final VoidCallback onRetakeExam;
  final VoidCallback onGoHome;

  const ActionButtonsWidget({
    super.key,
    required this.hasErrors,
    required this.onTrainErrors,
    required this.onRetakeExam,
    required this.onGoHome,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Primary action - Train errors (only if there are errors)
            if (hasErrors)
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton(
                  onPressed: () {
                    HapticFeedback.mediumImpact();
                    onTrainErrors();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7B68EE),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: const Color(0xFF7B68EE).withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fitness_center_rounded, size: 5.w),
                      SizedBox(width: 2.w),
                      Text(
                        'Allena i miei errori',
                        style: GoogleFonts.inter(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (hasErrors) SizedBox(height: 2.h),

            // Secondary actions row
            Row(
              children: [
                // Retake exam button
                Expanded(
                  child: SizedBox(
                    height: 6.h,
                    child: OutlinedButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        onRetakeExam();
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(
                          color: colorScheme.primary,
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.refresh_rounded, size: 5.w),
                          SizedBox(width: 2.w),
                          Flexible(
                            child: Text(
                              'Rifai esame',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 3.w),

                // Go home button
                Expanded(
                  child: SizedBox(
                    height: 6.h,
                    child: TextButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        onGoHome();
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.onSurfaceVariant,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home_rounded, size: 5.w),
                          SizedBox(width: 2.w),
                          Flexible(
                            child: Text(
                              'Torna a casa',
                              style: GoogleFonts.inter(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
