import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

/// Navigation widget for official exam screen showing question grid
class ExamNavigationWidget extends StatelessWidget {
  final int currentIndex;
  final int totalQuestions;
  final Map<int, bool?> answeredQuestions;
  final Map<int, bool> isCorrectMap;
  final Function(int) onNavigate;

  const ExamNavigationWidget({
    super.key,
    required this.currentIndex,
    required this.totalQuestions,
    required this.answeredQuestions,
    required this.isCorrectMap,
    required this.onNavigate,
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
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress indicator
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: Row(
                children: [
                  Text(
                    'Progresso: ${answeredQuestions.length}/$totalQuestions',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: answeredQuestions.length / totalQuestions,
                      backgroundColor: colorScheme.surfaceContainerHighest,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        colorScheme.primary,
                      ),
                      minHeight: 4,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),

            // Question grid
            Container(
              height: 12.h,
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
              child: GridView.builder(
                scrollDirection: Axis.horizontal,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                itemCount: totalQuestions,
                itemBuilder: (context, index) {
                  return _buildQuestionDot(context, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionDot(BuildContext context, int index) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isAnswered = answeredQuestions.containsKey(index);
    final isCurrent = index == currentIndex;
    final isCorrect = isCorrectMap[index];

    Color backgroundColor;
    Color borderColor;
    Color textColor;

    if (isCurrent) {
      backgroundColor = colorScheme.primary;
      borderColor = colorScheme.primary;
      textColor = colorScheme.onPrimary;
    } else if (isAnswered) {
      if (isCorrect == true) {
        backgroundColor = const Color(0xFF27AE60).withValues(alpha: 0.12);
        borderColor = const Color(0xFF27AE60);
        textColor = const Color(0xFF27AE60);
      } else if (isCorrect == false) {
        backgroundColor = const Color(0xFFE74C3C).withValues(alpha: 0.12);
        borderColor = const Color(0xFFE74C3C);
        textColor = const Color(0xFFE74C3C);
      } else {
        backgroundColor = colorScheme.primaryContainer;
        borderColor = colorScheme.primary;
        textColor = colorScheme.onPrimaryContainer;
      }
    } else {
      backgroundColor = colorScheme.surface;
      borderColor = colorScheme.outline;
      textColor = colorScheme.onSurfaceVariant;
    }

    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onNavigate(index);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor, width: isCurrent ? 2 : 1),
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: theme.textTheme.labelLarge?.copyWith(
                color: textColor,
                fontWeight: isCurrent ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
