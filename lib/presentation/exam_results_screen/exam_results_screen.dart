import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import '../../core/mistake_tracker_service.dart';

import './widgets/action_buttons_widget.dart';
import './widgets/error_list_widget.dart';
import './widgets/exam_history_widget.dart';
import './widgets/results_header_widget.dart';

/// Exam Results Screen - Displays comprehensive exam performance analysis
/// with pass/fail status and detailed error review
class ExamResultsScreen extends StatefulWidget {
  const ExamResultsScreen({super.key});

  @override
  State<ExamResultsScreen> createState() => _ExamResultsScreenState();
}

class _ExamResultsScreenState extends State<ExamResultsScreen> {
  late bool _passed;
  late int _errorCount;
  late int _correctCount;
  late int _totalQuestions;
  late Duration _duration;
  List<String> _lastExamWrongQuestionIds = [];
  MistakeTrackerService? _mistakeTracker;
  bool _isLoading = false;
  List<Map<String, dynamic>> _errors = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;

    if (args != null) {
      _passed = args['passed'] as bool? ?? false;
      _errorCount = args['errorCount'] as int? ?? 0;
      _correctCount = args['correctCount'] as int? ?? 0;
      _totalQuestions = args['totalQuestions'] as int? ?? 35;
      _duration = args['duration'] as Duration? ?? Duration.zero;
      _lastExamWrongQuestionIds =
          (args['lastExamWrongQuestionIds'] as List<String>?) ?? [];
      _mistakeTracker = args['mistakeTracker'] as MistakeTrackerService?;

      print(
        '📊 Exam Results - Passed: $_passed, Errors: $_errorCount/$_totalQuestions',
      );
      print(
        '🔍 Wrong question IDs available: ${_lastExamWrongQuestionIds.length}',
      );
    }
  }

  void _trainMyMistakes() {
    if (_lastExamWrongQuestionIds.isEmpty) {
      print('⚠️ No wrong questions from last exam to train');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nessun errore da ripassare da questo esame'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    print(
      '🚀 Starting "Train my mistakes" with ${_lastExamWrongQuestionIds.length} questions from last exam',
    );

    // Navigate to Ripasso screen with wrong questions from this exam
    Navigator.pushNamed(
      context,
      '/review-screen',
      arguments: {
        'mode': 'exam_review',
        'questionIds': _lastExamWrongQuestionIds,
        'mistakeTracker': _mistakeTracker,
      },
    );
  }

  void _handleRetakeExam() {
    HapticFeedback.selectionClick();
    // Navigate back to exam setup screen
    Navigator.pushReplacementNamed(context, '/official-exam-screen');
  }

  void _handleGoHome() {
    HapticFeedback.selectionClick();
    // Navigate to home screen
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home-screen',
      (route) => false,
    );
  }

  void _handleShare() {
    HapticFeedback.selectionClick();
    final correctAnswers = _totalQuestions - _errorCount;
    final scorePercentage = (correctAnswers / _totalQuestions * 100).round();

    Share.share(
      'Ho appena completato un esame simulato su Guidingo! '
      'Risultato: $scorePercentage% ($_errorCount errori su $_totalQuestions domande). '
      '${_passed ? "Esame superato! 🎉" : "Continuo a studiare! 📚"}',
      subject: 'I miei progressi su Guidingo',
    );
  }

  Future<void> _handleRefresh() async {
    HapticFeedback.selectionClick();
    setState(() {
      _isLoading = true;
    });
    // Simulate loading delay
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Risultati Esame'),
        leading: IconButton(
          icon: Icon(Icons.close_rounded),
          onPressed: _handleGoHome,
          tooltip: 'Chiudi',
        ),
        actions: [
          if (_passed && !_isLoading)
            IconButton(
              icon: Icon(Icons.share_rounded),
              onPressed: _handleShare,
              tooltip: 'Condividi risultati',
            ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      theme.colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Analisi dei risultati...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _handleRefresh,
              color: theme.colorScheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // Results header with pass/fail status
                    ResultsHeaderWidget(
                      isPassed: _passed,
                      errorCount: _errorCount,
                      totalQuestions: _totalQuestions,
                    ),
                    SizedBox(height: 2.h),

                    // Error list
                    ErrorListWidget(errors: _errors),
                    SizedBox(height: 2.h),

                    // Exam history and suggestions
                    ExamHistoryWidget(
                      isPassed: _passed,
                      errorCount: _errorCount,
                      totalQuestions: _totalQuestions,
                    ),
                    SizedBox(height: 10.h), // Space for action buttons
                  ],
                ),
              ),
            ),
      bottomNavigationBar: _isLoading
          ? null
          : ActionButtonsWidget(
              hasErrors: _errors.isNotEmpty,
              onTrainErrors: _trainMyMistakes,
              onRetakeExam: _handleRetakeExam,
              onGoHome: _handleGoHome,
            ),
    );
  }
}