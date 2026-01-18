import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

import './error_card_widget.dart';

/// Scrollable list widget displaying all incorrect questions
class ErrorListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> errors;

  const ErrorListWidget({super.key, required this.errors});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (errors.isEmpty) {
      return Container(
        padding: EdgeInsets.all(5.w),
        child: Column(
          children: [
            Icon(
              Icons.celebration_rounded,
              size: 20.w,
              color: const Color(0xFF27AE60),
            ),
            SizedBox(height: 2.h),
            Text(
              'Perfetto!',
              style: GoogleFonts.inter(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF27AE60),
                letterSpacing: 0.15,
              ),
            ),
            SizedBox(height: 1.h),
            Text(
              'Non hai commesso errori in questo esame!',
              style: GoogleFonts.inter(
                fontSize: 12.sp,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurfaceVariant,
                letterSpacing: 0.25,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          child: Row(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 5.w,
                color: const Color(0xFFE74C3C),
              ),
              SizedBox(width: 2.w),
              Text(
                'Errori da rivedere (${errors.length})',
                style: GoogleFonts.inter(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                  letterSpacing: 0.15,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 2.h),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 5.w),
          itemCount: errors.length,
          itemBuilder: (context, index) {
            return ErrorCardWidget(errorData: errors[index], index: index);
          },
        ),
      ],
    );
  }
}
