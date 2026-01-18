import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/data/impara_questions.dart';
import '../../core/lives_controller.dart';
import '../../core/mistake_tracker_service.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/empty_state_widget.dart';
import './widgets/exercise_card_widget.dart';

/// Ripasso Screen - Shows mistakes from MistakeTrackerService
class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final MistakeTrackerService _mistakeTracker = MistakeTrackerService();
  final LivesController _livesController = LivesController();

  bool _isLoading = true;
  List<Map<String, dynamic>> _ripassoQuestions = [];
  String _reviewMode = 'all'; // 'all' or 'exam_review'
  List<String>? _specificQuestionIds; // For exam review mode

  @override
  void initState() {
    super.initState();
    _loadRipassoData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Check if coming from exam results with specific questions
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _reviewMode = args['mode'] as String? ?? 'all';
      _specificQuestionIds = args['questionIds'] as List<String>?;

      print(
        '📋 Review mode: $_reviewMode, Specific questions: ${_specificQuestionIds?.length ?? 0}',
      );

      if (_specificQuestionIds != null && _specificQuestionIds!.isNotEmpty) {
        _loadSpecificQuestions(_specificQuestionIds!);
        return;
      }
    }
  }

  Future<void> _loadSpecificQuestions(List<String> questionIds) async {
    setState(() => _isLoading = true);

    await _mistakeTracker.initialize();
    await _livesController.initialize();

    print('🔍 Loading specific questions for exam review: $questionIds');

    final ripassoQuestions = <Map<String, dynamic>>[];
    final allQuestions = ImparaQuestions.getAllQuestions();

    for (final questionId in questionIds) {
      final question = allQuestions.firstWhere((q) {
        final qId = q['id'];
        return qId.toString() == questionId || qId == int.tryParse(questionId);
      }, orElse: () => <String, dynamic>{});

      if (question.isNotEmpty) {
        ripassoQuestions.add(question);
        print('✅ Found question ID $questionId for exam review');
      } else {
        print('❌ Question ID $questionId not found in centralized bank');
      }

      // Max 10 questions per session
      if (ripassoQuestions.length >= 10) break;
    }

    print(
      '📊 Exam review session built with ${ripassoQuestions.length} questions',
    );

    setState(() {
      _ripassoQuestions = ripassoQuestions;
      _isLoading = false;
    });
  }

  Future<void> _loadRipassoData() async {
    setState(() => _isLoading = true);

    await _mistakeTracker.initialize();
    await _livesController.initialize();

    print('🔍 Loading Ripasso data...');

    // Get questions that need review from MistakeTrackerService
    final questionIdsToReview = _mistakeTracker.getQuestionsToReview();
    print(
      '📋 Question IDs to review: ${questionIdsToReview.length} - $questionIdsToReview',
    );

    // Build ripasso from centralized question bank
    final ripassoQuestions = <Map<String, dynamic>>[];
    final allQuestions = ImparaQuestions.getAllQuestions();

    for (final questionId in questionIdsToReview) {
      // Try to find question by ID (as int or string)
      final question = allQuestions.firstWhere((q) {
        final qId = q['id'];
        return qId.toString() == questionId || qId == int.tryParse(questionId);
      }, orElse: () => <String, dynamic>{});

      if (question.isNotEmpty) {
        ripassoQuestions.add(question);
        print(
          '✅ Found question ID $questionId: ${question['question']?.substring(0, 50)}...',
        );
      } else {
        print('❌ Question ID $questionId not found in centralized bank');
      }

      // Max 10 questions per session
      if (ripassoQuestions.length >= 10) break;
    }

    print('📊 Ripasso session built with ${ripassoQuestions.length} questions');

    setState(() {
      _ripassoQuestions = ripassoQuestions;
      _isLoading = false;
    });
  }

  void _startRipasso() {
    if (_livesController.currentLives <= 0) {
      Navigator.pushNamed(context, '/lives-depleted-screen');
      return;
    }

    print('🚀 Starting Ripasso with ${_ripassoQuestions.length} questions');

    HapticFeedback.selectionClick();
    Navigator.pushNamed(
      context,
      '/exercise-player-screen',
      arguments: {
        'mode': 'ripasso',
        'questions': _ripassoQuestions,
        'mistakeTracker': _mistakeTracker,
      },
    ).then((_) {
      // Reload after returning from ripasso
      print('🔄 Returned from Ripasso, reloading data...');
      if (_reviewMode == 'exam_review' && _specificQuestionIds != null) {
        // For exam review, go back to exam results or home
        Navigator.pop(context);
      } else {
        _loadRipassoData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
          onPressed: () {
            // Return to Home root by resetting navigation stack
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home-screen',
              (Route<dynamic> route) => false,
            );
          },
        ),
        title: Text(
          'Ripasso di Oggi',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: theme.colorScheme.primary,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading ? _buildLoadingState(theme) : _buildContent(theme),
      bottomNavigationBar: CustomBottomBar(
        currentRoute: '/review-screen',
        onNavigate: (route) {
          HapticFeedback.selectionClick();
          if (route == '/home-screen') {
            // Ensure Home navigation resets stack
            Navigator.pushNamedAndRemoveUntil(
              context,
              route,
              (Route<dynamic> route) => false,
            );
          } else {
            Navigator.pushNamed(context, route);
          }
        },
      ),
    );
  }

  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: theme.colorScheme.primary),
          SizedBox(height: 2.h),
          Text(
            'Preparo il tuo ripasso...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_ripassoQuestions.isEmpty) {
      return EmptyStateWidget(
        onStartNewLesson: () {
          HapticFeedback.selectionClick();
          Navigator.pushNamed(context, '/module-selection-screen');
        },
      );
    }

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mistakes counter
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.error,
                    size: 32,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Errori da ripassare (${_mistakeTracker.mistakeCount})',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 0.5.h),
                        Text(
                          'Rispondi correttamente 2 volte per rimuoverli',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 3.h),

            // Start button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startRipasso,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Inizia Ripasso',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            SizedBox(height: 3.h),

            Text(
              'Domande da ripassare (${_ripassoQuestions.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),

            SizedBox(height: 2.h),

            // Questions preview list
            Expanded(
              child: ListView.builder(
                itemCount: _ripassoQuestions.length,
                itemBuilder: (context, index) {
                  final question = _ripassoQuestions[index];
                  return Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: ExerciseCardWidget(
                      exercise: question,
                      onTap: _startRipasso,
                      onMarkAsReviewed: () {},
                      onPostpone: () {},
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
