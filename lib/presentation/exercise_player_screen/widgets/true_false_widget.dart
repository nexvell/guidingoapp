import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

/// True/False exercise widget with large thumb-friendly buttons
class TrueFalseWidget extends StatelessWidget {
  final String question;
  final Function(bool) onAnswer;
  final bool? selectedAnswer;

  const TrueFalseWidget({
    super.key,
    required this.question,
    required this.onAnswer,
    this.selectedAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Question text
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
              child: Text(
                question,
                style: GoogleFonts.inter(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        // Answer buttons
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
          child: Column(
            children: [
              _buildAnswerButton(
                context: context,
                label: 'VERO',
                value: true,
                colorScheme: colorScheme,
              ),
              SizedBox(height: 2.h),
              _buildAnswerButton(
                context: context,
                label: 'FALSO',
                value: false,
                colorScheme: colorScheme,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAnswerButton({
    required BuildContext context,
    required String label,
    required bool value,
    required ColorScheme colorScheme,
  }) {
    final isSelected = selectedAnswer == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: selectedAnswer == null
            ? () {
                HapticFeedback.selectionClick();
                onAnswer(value);
              }
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 8.h),
          padding: EdgeInsets.symmetric(vertical: 2.h),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary
                : colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.2),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurface,
                letterSpacing: 1.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
