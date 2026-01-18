import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Exam history summary and improvement suggestions widget
class ExamHistoryWidget extends StatelessWidget {
  final bool isPassed;
  final int errorCount;
  final int totalQuestions;

  const ExamHistoryWidget({
    super.key,
    required this.isPassed,
    required this.errorCount,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CustomIconWidget(
                iconName: 'insights',
                size: 5.w,
                color: colorScheme.primary,
              ),
              SizedBox(width: 2.w),
              Text(
                'Suggerimenti per migliorare',
                style: GoogleFonts.inter(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.primary,
                  letterSpacing: 0.15,
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),

          // Suggestions based on performance
          ..._buildSuggestions(context),
        ],
      ),
    );
  }

  List<Widget> _buildSuggestions(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final suggestions = <Widget>[];

    if (isPassed) {
      suggestions.add(
        _buildSuggestionItem(
          context,
          'Ottimo lavoro! Continua a ripassare per mantenere le conoscenze fresche.',
          Icons.star_rounded,
        ),
      );
      suggestions.add(SizedBox(height: 1.5.h));
      suggestions.add(
        _buildSuggestionItem(
          context,
          'Prova a fare altri esami simulati per aumentare la tua sicurezza.',
          Icons.trending_up_rounded,
        ),
      );
    } else {
      if (errorCount > 10) {
        suggestions.add(
          _buildSuggestionItem(
            context,
            'Concentrati sulle lezioni base prima di riprovare l\'esame.',
            Icons.school_rounded,
          ),
        );
        suggestions.add(SizedBox(height: 1.5.h));
      }
      suggestions.add(
        _buildSuggestionItem(
          context,
          'Usa la funzione "Allena i miei errori" per rivedere le domande sbagliate.',
          Icons.fitness_center_rounded,
        ),
      );
      suggestions.add(SizedBox(height: 1.5.h));
      suggestions.add(
        _buildSuggestionItem(
          context,
          'Ripassa ogni giorno con "Ripasso di oggi" per migliorare la memorizzazione.',
          Icons.calendar_today_rounded,
        ),
      );
    }

    return suggestions;
  }

  Widget _buildSuggestionItem(
    BuildContext context,
    String text,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(icon, size: 4.w, color: colorScheme.primary),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 11.sp,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
              letterSpacing: 0.25,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
