import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Results header widget displaying pass/fail status with score visualization
class ResultsHeaderWidget extends StatefulWidget {
  final bool isPassed;
  final int errorCount;
  final int totalQuestions;

  const ResultsHeaderWidget({
    super.key,
    required this.isPassed,
    required this.errorCount,
    required this.totalQuestions,
  });

  @override
  State<ResultsHeaderWidget> createState() => _ResultsHeaderWidgetState();
}

class _ResultsHeaderWidgetState extends State<ResultsHeaderWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final correctAnswers = widget.totalQuestions - widget.errorCount;
    final scorePercentage = (correctAnswers / widget.totalQuestions * 100)
        .round();

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 4.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: widget.isPassed
              ? [
                  const Color(0xFF27AE60).withValues(alpha: 0.15),
                  colorScheme.surface,
                ]
              : [
                  const Color(0xFFE74C3C).withValues(alpha: 0.15),
                  colorScheme.surface,
                ],
        ),
      ),
      child: Column(
        children: [
          // Animated icon
          ScaleTransition(
            scale: _scaleAnimation,
            child: Container(
              width: 25.w,
              height: 25.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isPassed
                    ? const Color(0xFF27AE60).withValues(alpha: 0.12)
                    : const Color(0xFFE74C3C).withValues(alpha: 0.12),
              ),
              child: Center(
                child: CustomIconWidget(
                  iconName: widget.isPassed ? 'check_circle' : 'cancel',
                  size: 15.w,
                  color: widget.isPassed
                      ? const Color(0xFF27AE60)
                      : const Color(0xFFE74C3C),
                ),
              ),
            ),
          ),
          SizedBox(height: 2.h),

          // Status text
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              widget.isPassed ? 'Esame Superato!' : 'Esame Non Superato',
              style: GoogleFonts.inter(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: widget.isPassed
                    ? const Color(0xFF27AE60)
                    : const Color(0xFFE74C3C),
                letterSpacing: 0.15,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 1.h),

          // Motivational message
          FadeTransition(
            opacity: _fadeAnimation,
            child: Text(
              widget.isPassed
                  ? 'Complimenti! Sei pronto per la patente!'
                  : 'Non mollare! Continua a studiare e riprova.',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.25,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 3.h),

          // Score visualization
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Score percentage
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '$scorePercentage',
                        style: GoogleFonts.inter(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w700,
                          color: widget.isPassed
                              ? const Color(0xFF27AE60)
                              : const Color(0xFFE74C3C),
                          height: 1.0,
                        ),
                      ),
                      Text(
                        '%',
                        style: GoogleFonts.inter(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w600,
                          color: widget.isPassed
                              ? const Color(0xFF27AE60)
                              : const Color(0xFFE74C3C),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 1.h),

                  // Score breakdown
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomIconWidget(
                        iconName: 'check_circle',
                        size: 4.w,
                        color: const Color(0xFF27AE60),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '$correctAnswers corrette',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                          letterSpacing: 0.4,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      CustomIconWidget(
                        iconName: 'cancel',
                        size: 4.w,
                        color: const Color(0xFFE74C3C),
                      ),
                      SizedBox(width: 1.w),
                      Text(
                        '${widget.errorCount} sbagliate',
                        style: GoogleFonts.inter(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: colorScheme.onSurface,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.h),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: correctAnswers / widget.totalQuestions,
                      minHeight: 1.h,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        widget.isPassed
                            ? const Color(0xFF27AE60)
                            : const Color(0xFFE74C3C),
                      ),
                    ),
                  ),
                  SizedBox(height: 1.h),

                  // Total questions
                  Text(
                    'su ${widget.totalQuestions} domande',
                    style: GoogleFonts.inter(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w400,
                      color: colorScheme.onSurfaceVariant,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
