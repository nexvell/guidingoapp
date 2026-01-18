import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../core/data/impara_questions.dart';
import '../../core/mistake_tracker_service.dart';
import './widgets/exam_header_widget.dart';
import './widgets/exam_question_widget.dart';
import './widgets/exam_timer_widget.dart';

/// Official Exam Screen - 35 questions, no answer reveal, auto-advance
class OfficialExamScreen extends StatefulWidget {
  const OfficialExamScreen({super.key});

  @override
  State<OfficialExamScreen> createState() => _OfficialExamScreenState();
}

class _OfficialExamScreenState extends State<OfficialExamScreen> {
  // Exam configuration
  final int _totalQuestions = 35;
  int _currentQuestionIndex = 0;
  int _errorCount = 0;
  final int _maxErrors = 4;

  // Timer state
  late DateTime _examStartTime;
  int _remainingSeconds = 1800; // 30 minutes
  bool _isTimerRunning = true;

  // Question state
  final Map<int, bool?> _userAnswers = {};
  late List<Map<String, dynamic>> _examQuestions;

  final MistakeTrackerService _mistakeTracker = MistakeTrackerService();
  List<String> _lastExamWrongQuestionIds =
      []; // Store last exam's wrong question IDs

  @override
  void initState() {
    super.initState();
    _examStartTime = DateTime.now();
    _initializeExamQuestions();
    _startTimer();
    _mistakeTracker.initialize();
  }

  void _initializeExamQuestions() {
    print('📚 Initializing Official Exam with centralized question bank...');

    // Get all questions from centralized bank
    final allQuestions = ImparaQuestions.getAllQuestions();

    // Shuffle and select exactly 35 questions with controlled image distribution
    final shuffled = List<Map<String, dynamic>>.from(allQuestions);
    shuffled.shuffle();

    // Separate questions with and without images
    final withImages = shuffled
        .where(
          (q) =>
              q.containsKey('image') && q['image'] != null && q['image'] != '',
        )
        .toList();
    final withoutImages = shuffled
        .where(
          (q) =>
              !q.containsKey('image') || q['image'] == null || q['image'] == '',
        )
        .toList();

    print(
      '📊 Available questions: ${allQuestions.length} (${withImages.length} with images, ${withoutImages.length} text-only)',
    );

    // Ensure 15-30% have images (target: 8-10 questions with images out of 35)
    final targetWithImages = 8; // 23% of 35
    withImages.shuffle();
    withoutImages.shuffle();

    _examQuestions = [
      ...withImages.take(targetWithImages),
      ...withoutImages.take(35 - targetWithImages),
    ];

    _examQuestions.shuffle(); // Final shuffle

    print(
      '✅ Exam initialized with ${_examQuestions.length} questions (${_examQuestions.where((q) => q.containsKey('image')).length} with images)',
    );

    // Log exercise types
    final types = _examQuestions.map((e) => e['type']).toSet();
    print('📋 Exercise types in exam: $types');
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted || !_isTimerRunning) return false;

      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _submitExam();
        }
      });

      return _isTimerRunning && _remainingSeconds > 0;
    });
  }

  void _answerQuestion(bool answer) {
    if (_userAnswers.containsKey(_currentQuestionIndex)) return;

    HapticFeedback.selectionClick();

    print(
      '✏️ Exam answer - QuestionIndex: $_currentQuestionIndex, Answer: $answer',
    );

    // Store answer WITHOUT revealing correctness
    setState(() {
      _userAnswers[_currentQuestionIndex] = answer;
    });

    // Auto-advance immediately (no delay)
    if (_currentQuestionIndex < _totalQuestions - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _submitExam();
    }
  }

  void _submitExam() async {
    _isTimerRunning = false;

    print('🏁 Submitting exam...');

    // Calculate results ONLY at the end
    final Map<int, bool> isCorrectMap = {};
    int wrongCount = 0;
    _lastExamWrongQuestionIds.clear(); // Clear previous exam's wrong questions

    for (var i = 0; i < _examQuestions.length; i++) {
      final userAnswer = _userAnswers[i];
      final correctAnswer = _examQuestions[i]["correct_answer"] as bool;

      if (userAnswer == null) {
        // Unanswered = wrong
        isCorrectMap[i] = false;
        wrongCount++;
        final questionId = _examQuestions[i]["id"].toString();
        _lastExamWrongQuestionIds.add(
          questionId,
        ); // Store for "Train my mistakes"
        await _mistakeTracker.recordMistake(questionId);
        print('❌ Unanswered question ${i + 1} - ID: $questionId');
      } else {
        final isCorrect = userAnswer == correctAnswer;
        isCorrectMap[i] = isCorrect;
        if (!isCorrect) {
          wrongCount++;
          final questionId = _examQuestions[i]["id"].toString();
          _lastExamWrongQuestionIds.add(
            questionId,
          ); // Store for "Train my mistakes"
          await _mistakeTracker.recordMistake(questionId);
          print('❌ Wrong answer Q${i + 1} - ID: $questionId');
        } else {
          print('✅ Correct answer Q${i + 1} - ID: ${_examQuestions[i]["id"]}');
        }
      }
    }

    final examDuration = DateTime.now().difference(_examStartTime);

    // CORRECT SCORING: ≤3 wrong = PASS, ≥4 wrong = FAIL
    final passed = wrongCount <= 3;

    print(
      '📊 Exam complete - Errors: $wrongCount, Result: ${passed ? "PASS" : "FAIL"}',
    );
    print('🔍 Wrong question IDs: $_lastExamWrongQuestionIds');
    print(
      '🔍 MistakeTracker now has: ${_mistakeTracker.mistakeCount} mistakes',
    );

    // Navigate to results screen
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      '/exam-results-screen',
      arguments: {
        'passed': passed,
        'errorCount': wrongCount,
        'correctCount': _totalQuestions - wrongCount,
        'totalQuestions': _totalQuestions,
        'duration': examDuration,
        'questions': _examQuestions,
        'userAnswers': _userAnswers,
        'isCorrectMap': isCorrectMap,
        'lastExamWrongQuestionIds':
            _lastExamWrongQuestionIds, // Pass to results screen
        'mistakeTracker': _mistakeTracker, // Pass tracker instance
      },
    );
  }

  Future<bool> _onWillPop() async {
    final shouldExit = await showDialog<bool>(
      context: context,
      builder: (context) => _buildExitDialog(),
    );
    return shouldExit ?? false;
  }

  Widget _buildExitDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AlertDialog(
      title: Text('Uscire dall\'esame?', style: theme.textTheme.titleLarge),
      content: Text(
        'Se esci ora, l\'esame verrà annullato e dovrai ricominciare da capo.',
        style: theme.textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(
            'Continua esame',
            style: TextStyle(color: colorScheme.primary),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context, true);
            Navigator.pop(context);
          },
          child: Text('Esci', style: TextStyle(color: colorScheme.error)),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _isTimerRunning = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (!didPop) {
          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.pop(context);
          }
        }
      },
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: ExamHeaderWidget(
            currentQuestion: _currentQuestionIndex + 1,
            totalQuestions: _totalQuestions,
            errorCount: 0, // Don't show error count during exam
            maxErrors: _maxErrors,
            onExit: _onWillPop,
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Timer
              ExamTimerWidget(
                remainingSeconds: _remainingSeconds,
                totalSeconds: 1800,
              ),

              // Question content (removed navigation widget)
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  child: ExamQuestionWidget(
                    question: _examQuestions[_currentQuestionIndex],
                    questionNumber: _currentQuestionIndex + 1,
                    userAnswer: _userAnswers[_currentQuestionIndex],
                    onAnswer: _answerQuestion,
                  ),
                ),
              ),

              // Progress indicator at bottom
              Container(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Domanda ${_currentQuestionIndex + 1} di $_totalQuestions',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
