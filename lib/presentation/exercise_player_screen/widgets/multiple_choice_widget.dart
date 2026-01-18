import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

/// Multiple choice exercise widget with four option cards
class MultipleChoiceWidget extends StatelessWidget {
  final String question;
  final List<String> options;
  final Function(int) onAnswer;
  final int? selectedOption;

  const MultipleChoiceWidget({
    super.key,
    required this.question,
    required this.options,
    required this.onAnswer,
    this.selectedOption,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Question text
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
          child: Text(
            question,
            style: GoogleFonts.inter(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(height: 2.h),
        // Options list
        Expanded(
          child: ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
            itemCount: options.length,
            separatorBuilder: (context, index) => SizedBox(height: 1.5.h),
            itemBuilder: (context, index) {
              return _buildOptionCard(
                context: context,
                option: options[index],
                index: index,
                colorScheme: colorScheme,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildOptionCard({
    required BuildContext context,
    required String option,
    required int index,
    required ColorScheme colorScheme,
  }) {
    final isSelected = selectedOption == index;
    final optionLabel = String.fromCharCode(65 + index); // A, B, C, D

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: selectedOption == null
            ? () {
                HapticFeedback.selectionClick();
                onAnswer(index);
              }
            : null,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: BoxConstraints(minHeight: 7.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary.withValues(alpha: 0.12)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.2),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              // Option label (A, B, C, D)
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    optionLabel,
                    style: GoogleFonts.inter(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? colorScheme.onPrimary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              // Option text
              Expanded(
                child: Text(
                  option,
                  style: GoogleFonts.inter(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurface,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
