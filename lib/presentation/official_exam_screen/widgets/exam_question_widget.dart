import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_image_widget.dart';

/// Question widget for official exam screen
class ExamQuestionWidget extends StatelessWidget {
  final Map<String, dynamic> question;
  final int questionNumber;
  final bool? userAnswer;
  final Function(bool) onAnswer;

  const ExamQuestionWidget({
    super.key,
    required this.question,
    required this.questionNumber,
    required this.userAnswer,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasAnswered = userAnswer != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Question number badge
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Domanda $questionNumber',
            style: theme.textTheme.labelLarge?.copyWith(
              color: colorScheme.onPrimaryContainer,
            ),
          ),
        ),

        SizedBox(height: 2.h),

        // Question image (if available)
        if (question["image"] != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: CustomImageWidget(
              imageUrl: question["image"] as String,
              width: double.infinity,
              height: 25.h,
              fit: BoxFit.cover,
              semanticLabel:
                  question["semanticLabel"] as String? ?? "Traffic sign image",
            ),
          ),
          SizedBox(height: 2.h),
        ],

        // Question text
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outline.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            question["question"] as String,
            style: theme.textTheme.bodyLarge?.copyWith(
              height: 1.5,
              fontSize: 16.sp,
            ),
          ),
        ),

        SizedBox(height: 3.h),

        // Answer buttons
        Row(
          children: [
            Expanded(
              child: _buildAnswerButton(
                context: context,
                label: 'VERO',
                value: true,
                isSelected: userAnswer == true,
                isDisabled: hasAnswered,
                onTap: () => onAnswer(true),
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: _buildAnswerButton(
                context: context,
                label: 'FALSO',
                value: false,
                isSelected: userAnswer == false,
                isDisabled: hasAnswered,
                onTap: () => onAnswer(false),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAnswerButton({
    required BuildContext context,
    required String label,
    required bool value,
    required bool isSelected,
    required bool isDisabled,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    Color backgroundColor;
    Color textColor;
    Color borderColor;

    if (isSelected) {
      backgroundColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
      borderColor = colorScheme.primary;
    } else if (isDisabled) {
      backgroundColor = colorScheme.surfaceContainerHighest.withValues(
        alpha: 0.5,
      );
      textColor = colorScheme.onSurfaceVariant.withValues(alpha: 0.5);
      borderColor = colorScheme.outline.withValues(alpha: 0.2);
    } else {
      backgroundColor = colorScheme.surface;
      textColor = colorScheme.onSurface;
      borderColor = colorScheme.outline;
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: isDisabled
            ? null
            : () {
                HapticFeedback.selectionClick();
                onTap();
              },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 6.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 2),
          ),
          child: Center(
            child: Text(
              label,
              style: theme.textTheme.titleMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
