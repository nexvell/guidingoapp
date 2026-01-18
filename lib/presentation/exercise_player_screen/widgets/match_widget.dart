import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

/// Match exercise widget with tap-to-pair functionality
class MatchWidget extends StatefulWidget {
  final String question;
  final List<Map<String, String>> pairs;
  final Function(List<Map<String, int>>) onComplete;

  MatchWidget({
    super.key,
    required this.question,
    required this.pairs,
    required this.onComplete,
  });

  @override
  State<MatchWidget> createState() => _MatchWidgetState();
}

class _MatchWidgetState extends State<MatchWidget> {
  int? selectedLeftIndex;
  int? selectedRightIndex;
  List<Map<String, int>> matches = [];
  Set<int> matchedLeftIndices = {};
  Set<int> matchedRightIndices = {};

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
            widget.question,
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
        // Match pairs
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.w),
            child: Row(
              children: [
                // Left column
                Expanded(
                  child: ListView.separated(
                    itemCount: widget.pairs.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 1.5.h),
                    itemBuilder: (context, index) {
                      return _buildMatchItem(
                        context: context,
                        text: widget.pairs[index]['left'] ?? '',
                        index: index,
                        isLeft: true,
                        isSelected: selectedLeftIndex == index,
                        isMatched: matchedLeftIndices.contains(index),
                        colorScheme: colorScheme,
                      );
                    },
                  ),
                ),
                SizedBox(width: 4.w),
                // Right column
                Expanded(
                  child: ListView.separated(
                    itemCount: widget.pairs.length,
                    separatorBuilder: (context, index) =>
                        SizedBox(height: 1.5.h),
                    itemBuilder: (context, index) {
                      return _buildMatchItem(
                        context: context,
                        text: widget.pairs[index]['right'] ?? '',
                        index: index,
                        isLeft: false,
                        isSelected: selectedRightIndex == index,
                        isMatched: matchedRightIndices.contains(index),
                        colorScheme: colorScheme,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchItem({
    required BuildContext context,
    required String text,
    required int index,
    required bool isLeft,
    required bool isSelected,
    required bool isMatched,
    required ColorScheme colorScheme,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isMatched
            ? null
            : () {
                HapticFeedback.selectionClick();
                _handleTap(index, isLeft);
              },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          constraints: BoxConstraints(minHeight: 7.h),
          padding: EdgeInsets.all(4.w),
          decoration: BoxDecoration(
            color: isMatched
                ? const Color(0xFF27AE60).withValues(alpha: 0.12)
                : isSelected
                ? colorScheme.primary.withValues(alpha: 0.12)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isMatched
                  ? const Color(0xFF27AE60)
                  : isSelected
                  ? colorScheme.primary
                  : colorScheme.outline.withValues(alpha: 0.2),
              width: isMatched || isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.inter(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: isMatched
                    ? const Color(0xFF27AE60)
                    : colorScheme.onSurface,
                height: 1.3,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  void _handleTap(int index, bool isLeft) {
    setState(() {
      if (isLeft) {
        selectedLeftIndex = selectedLeftIndex == index ? null : index;
      } else {
        selectedRightIndex = selectedRightIndex == index ? null : index;
      }

      // Check if both sides are selected
      if (selectedLeftIndex != null && selectedRightIndex != null) {
        // Check if match is correct
        if (selectedLeftIndex == selectedRightIndex) {
          // Correct match
          HapticFeedback.mediumImpact();
          matches.add({
            'left': selectedLeftIndex!,
            'right': selectedRightIndex!,
          });
          matchedLeftIndices.add(selectedLeftIndex!);
          matchedRightIndices.add(selectedRightIndex!);

          // Check if all pairs are matched
          if (matches.length == widget.pairs.length) {
            Future.delayed(const Duration(milliseconds: 500), () {
              widget.onComplete(matches);
            });
          }
        } else {
          // Incorrect match - vibrate
          HapticFeedback.heavyImpact();
        }

        // Reset selection
        selectedLeftIndex = null;
        selectedRightIndex = null;
      }
    });
  }
}
