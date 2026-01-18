import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Bottom sheet showing answer feedback with explanation and tips
class FeedbackBottomSheet {
  static void show({
    required BuildContext context,
    required bool isCorrect,
    required String explanation,
    String? tip,
    required VoidCallback onContinue,
  }) {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      enableDrag: false,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: Container(
          constraints: BoxConstraints(maxHeight: 70.h),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: EdgeInsets.only(top: 1.h),
                width: 12.w,
                height: 0.5.h,
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(6.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Result header
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(3.w),
                            decoration: BoxDecoration(
                              color: isCorrect
                                  ? const Color(
                                      0xFF27AE60,
                                    ).withValues(alpha: 0.12)
                                  : const Color(
                                      0xFFE74C3C,
                                    ).withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: CustomIconWidget(
                              iconName: isCorrect ? 'check_circle' : 'cancel',
                              color: isCorrect
                                  ? const Color(0xFF27AE60)
                                  : const Color(0xFFE74C3C),
                              size: 32,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  isCorrect ? 'Corretto!' : 'Sbagliato',
                                  style: GoogleFonts.inter(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w700,
                                    color: isCorrect
                                        ? const Color(0xFF27AE60)
                                        : const Color(0xFFE74C3C),
                                  ),
                                ),
                                SizedBox(height: 0.5.h),
                                Text(
                                  _getRandomMotivationalMessage(isCorrect),
                                  style: GoogleFonts.inter(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w400,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      // Explanation
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'lightbulb',
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 20,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Spiegazione',
                                  style: GoogleFonts.inter(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.5.h),
                            Text(
                              explanation,
                              style: GoogleFonts.inter(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(context).colorScheme.onSurface,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Tip (if available)
                      if (tip != null && tip.isNotEmpty) ...[
                        SizedBox(height: 2.h),
                        Container(
                          padding: EdgeInsets.all(4.w),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).colorScheme.secondary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).colorScheme.secondary.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  CustomIconWidget(
                                    iconName: 'tips_and_updates',
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                    size: 20,
                                  ),
                                  SizedBox(width: 2.w),
                                  Text(
                                    'Suggerimento',
                                    style: GoogleFonts.inter(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 1.5.h),
                              Text(
                                tip,
                                style: GoogleFonts.inter(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w400,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: 3.h),
                      // Continue button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            Navigator.pop(context);
                            onContinue();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isCorrect
                                ? const Color(0xFF27AE60)
                                : Theme.of(context).colorScheme.primary,
                            padding: EdgeInsets.symmetric(vertical: 2.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Prossimo',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(width: 2.w),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _getRandomMotivationalMessage(bool isCorrect) {
    final correctMessages = [
      'Ottimo lavoro!',
      'Perfetto!',
      'Continua così!',
      'Sei sulla strada giusta!',
      'Fantastico!',
      'Eccellente!',
      'Ben fatto!',
      'Stai andando alla grande!',
    ];

    final incorrectMessages = [
      'Non preoccuparti, imparerai!',
      'Riprova, ce la farai!',
      'Ogni errore è un\'opportunità!',
      'Continua a provare!',
      'Non mollare!',
      'La pratica rende perfetti!',
      'Impara e vai avanti!',
      'Prossima volta andrà meglio!',
    ];

    final messages = isCorrect ? correctMessages : incorrectMessages;
    return messages[DateTime.now().millisecond % messages.length];
  }
}