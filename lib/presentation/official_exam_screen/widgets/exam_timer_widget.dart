import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Timer widget for official exam screen
class ExamTimerWidget extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;

  const ExamTimerWidget({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
  });

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Color _getTimerColor(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final percentage = remainingSeconds / totalSeconds;

    if (percentage <= 0.1) {
      return const Color(0xFFE74C3C); // Critical - red
    } else if (percentage <= 0.25) {
      return const Color(0xFFF39C12); // Warning - orange
    } else {
      return colorScheme.primary; // Normal - blue
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final timerColor = _getTimerColor(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
      decoration: BoxDecoration(
        color: timerColor.withValues(alpha: 0.08),
        border: Border(
          bottom: BorderSide(
            color: colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(iconName: 'schedule', color: timerColor, size: 20),
          SizedBox(width: 2.w),
          Text(
            _formatTime(remainingSeconds),
            style: theme.textTheme.titleLarge?.copyWith(
              color: timerColor,
              fontWeight: FontWeight.w600,
              fontFeatures: [const FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}
