import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

/// Individual error card widget with expandable details
class ErrorCardWidget extends StatefulWidget {
  final Map<String, dynamic> errorData;
  final int index;

  const ErrorCardWidget({
    super.key,
    required this.errorData,
    required this.index,
  });

  @override
  State<ErrorCardWidget> createState() => _ErrorCardWidgetState();
}

class _ErrorCardWidgetState extends State<ErrorCardWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final question = widget.errorData['question'] as String? ?? '';
    final correctAnswer = widget.errorData['correctAnswer'] as String? ?? '';
    final userAnswer = widget.errorData['userAnswer'] as String? ?? '';
    final explanation = widget.errorData['explanation'] as String? ?? '';
    final imageUrl = widget.errorData['imageUrl'] as String?;

    return Container(
      margin: EdgeInsets.only(bottom: 2.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE74C3C).withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with question number
                Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE74C3C).withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${widget.index + 1}',
                          style: GoogleFonts.inter(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFE74C3C),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        'Domanda ${widget.index + 1}',
                        style: GoogleFonts.inter(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                          letterSpacing: 0.15,
                        ),
                      ),
                    ),
                    CustomIconWidget(
                      iconName: _isExpanded ? 'expand_less' : 'expand_more',
                      size: 6.w,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
                SizedBox(height: 2.h),

                // Question text
                Text(
                  question,
                  style: GoogleFonts.inter(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w400,
                    color: colorScheme.onSurface,
                    letterSpacing: 0.25,
                    height: 1.5,
                  ),
                  maxLines: _isExpanded ? null : 2,
                  overflow: _isExpanded ? null : TextOverflow.ellipsis,
                ),

                // Question image if available
                if (imageUrl != null && imageUrl.isNotEmpty) ...[
                  SizedBox(height: 2.h),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: CustomImageWidget(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      height: 20.h,
                      fit: BoxFit.cover,
                      semanticLabel: 'Immagine della domanda d\'esame',
                    ),
                  ),
                ],

                // Expanded content
                if (_isExpanded) ...[
                  SizedBox(height: 2.h),
                  Divider(
                    color: colorScheme.outline.withValues(alpha: 0.2),
                    height: 1,
                  ),
                  SizedBox(height: 2.h),

                  // User's answer
                  _buildAnswerRow(
                    context,
                    'La tua risposta:',
                    userAnswer,
                    false,
                  ),
                  SizedBox(height: 1.5.h),

                  // Correct answer
                  _buildAnswerRow(
                    context,
                    'Risposta corretta:',
                    correctAnswer,
                    true,
                  ),

                  // Explanation
                  if (explanation.isNotEmpty) ...[
                    SizedBox(height: 2.h),
                    Container(
                      padding: EdgeInsets.all(3.w),
                      decoration: BoxDecoration(
                        color: colorScheme.primaryContainer.withValues(
                          alpha: 0.3,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'lightbulb',
                                size: 4.w,
                                color: colorScheme.primary,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                'Spiegazione',
                                style: GoogleFonts.inter(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
                                  letterSpacing: 0.15,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            explanation,
                            style: GoogleFonts.inter(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w400,
                              color: colorScheme.onSurface,
                              letterSpacing: 0.25,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerRow(
    BuildContext context,
    String label,
    String answer,
    bool isCorrect,
  ) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomIconWidget(
          iconName: isCorrect ? 'check_circle' : 'cancel',
          size: 5.w,
          color: isCorrect ? const Color(0xFF27AE60) : const Color(0xFFE74C3C),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w500,
                  color: colorScheme.onSurfaceVariant,
                  letterSpacing: 0.4,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                answer,
                style: GoogleFonts.inter(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: isCorrect
                      ? const Color(0xFF27AE60)
                      : const Color(0xFFE74C3C),
                  letterSpacing: 0.15,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
