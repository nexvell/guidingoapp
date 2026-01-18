import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Header widget for official exam screen showing progress and error count
class ExamHeaderWidget extends StatelessWidget {
  final int currentQuestion;
  final int totalQuestions;
  final int errorCount;
  final int maxErrors;
  final Future<bool> Function() onExit;

  const ExamHeaderWidget({
    super.key,
    required this.currentQuestion,
    required this.totalQuestions,
    required this.errorCount,
    required this.maxErrors,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          child: Row(
            children: [
              // Exit button
              IconButton(
                onPressed: () {
                  HapticFeedback.lightImpact();
                  onExit();
                },
                icon: CustomIconWidget(
                  iconName: 'close',
                  color: colorScheme.onSurface,
                  size: 24,
                ),
                tooltip: 'Esci dall\'esame',
              ),

              SizedBox(width: 2.w),

              // Question counter
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Esame Ufficiale',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      'Domanda $currentQuestion / $totalQuestions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Error counter
              Container(
                padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: errorCount > maxErrors - 2
                      ? const Color(0xFFE74C3C).withValues(alpha: 0.12)
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CustomIconWidget(
                      iconName: 'close',
                      color: errorCount > maxErrors - 2
                          ? const Color(0xFFE74C3C)
                          : colorScheme.error,
                      size: 16,
                    ),
                    SizedBox(width: 1.w),
                    Text(
                      '$errorCount/$maxErrors',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: errorCount > maxErrors - 2
                            ? const Color(0xFFE74C3C)
                            : colorScheme.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
