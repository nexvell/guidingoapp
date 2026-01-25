import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Tracks user attempts for Ripasso functionality
/// Stores which exercises user has attempted and their correctness
class AttemptsTracker extends ChangeNotifier {
  static final AttemptsTracker _instance = AttemptsTracker._internal();
  factory AttemptsTracker() => _instance;
  AttemptsTracker._internal();

  static const String _attemptsKey = 'user_attempts';
  static const String _dailyRipassoKey = 'daily_ripasso_date';
  static const String _ripassoProgressKey = 'ripasso_progress';
  static const String _lastShownQuestionsKey = 'last_shown_questions';

  final List<ExerciseAttempt> _attempts = [];
  DateTime? _lastRipassoDate;
  int _dailyRipassoProgress = 0;
  final List<String> _recentlyShownQuestions = [];

  List<ExerciseAttempt> get attempts => List.unmodifiable(_attempts);
  int get dailyRipassoProgress => _dailyRipassoProgress;
  static const int maxDailyRipasso = 10;
  static const int recentQuestionsBuffer = 5;

  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // Load attempts
    final attemptsJson = prefs.getString(_attemptsKey);
    if (attemptsJson != null) {
      final List<dynamic> decoded = json.decode(attemptsJson);
      _attempts.clear();
      _attempts.addAll(
        decoded.map((e) => ExerciseAttempt.fromJson(e)).toList(),
      );
    }

    // Load recently shown questions
    final recentJson = prefs.getString(_lastShownQuestionsKey);
    if (recentJson != null) {
      final List<dynamic> decoded = json.decode(recentJson);
      _recentlyShownQuestions.clear();
      _recentlyShownQuestions.addAll(decoded.cast<String>());
    }

    // Load ripasso date and progress
    final ripassoDateString = prefs.getString(_dailyRipassoKey);
    if (ripassoDateString != null) {
      _lastRipassoDate = DateTime.parse(ripassoDateString);
    }
    _dailyRipassoProgress = prefs.getInt(_ripassoProgressKey) ?? 0;

    // Check if we need to reset daily ripasso
    await _checkAndResetDailyRipasso();
    notifyListeners();
  }

  Future<void> _checkAndResetDailyRipasso() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastRipassoDate == null) {
      _lastRipassoDate = today;
      await _saveToPrefs();
      return;
    }

    final lastResetDay = DateTime(
      _lastRipassoDate!.year,
      _lastRipassoDate!.month,
      _lastRipassoDate!.day,
    );

    // Reset if last ripasso was before today
    if (lastResetDay.isBefore(today)) {
      _dailyRipassoProgress = 0;
      _lastRipassoDate = today;
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> recordAttempt({
    required String exerciseId,
    required bool isCorrect,
    required String mode,
  }) async {
    final attempt = ExerciseAttempt(
      exerciseId: exerciseId,
      isCorrect: isCorrect,
      timestamp: DateTime.now(),
      mode: mode,
    );

    _attempts.add(attempt);

    // Track recently shown questions for Impara
    if (!_recentlyShownQuestions.contains(exerciseId)) {
      _recentlyShownQuestions.add(exerciseId);
      if (_recentlyShownQuestions.length > recentQuestionsBuffer) {
        _recentlyShownQuestions.removeAt(0);
      }
    }

    await _saveToPrefs();
    notifyListeners();
  }

  Future<void> incrementRipassoProgress() async {
    if (_dailyRipassoProgress < maxDailyRipasso) {
      _dailyRipassoProgress++;
      await _saveToPrefs();
      notifyListeners();
    }
  }

  List<String> getAttemptedExerciseIds() {
    return _attempts.map((a) => a.exerciseId).toSet().toList();
  }

  List<String> getWrongExerciseIds() {
    return _attempts
        .where((a) => !a.isCorrect)
        .map((a) => a.exerciseId)
        .toSet()
        .toList();
  }

  bool hasAttempted(String exerciseId) {
    return _attempts.any((a) => a.exerciseId == exerciseId);
  }

  bool wasRecentlyShown(String exerciseId) {
    return _recentlyShownQuestions.contains(exerciseId);
  }

  /// Smart question selection for Impara mode
  /// Priority: 1) Unseen questions, 2) Previously wrong, 3) Avoid recent
  List<Map<String, dynamic>> selectQuestionsForImpara(
    List<Map<String, dynamic>> allQuestions,
    int count,
  ) {
    final attemptedIds = getAttemptedExerciseIds();
    final wrongIds = getWrongExerciseIds().toSet();

    // Separate questions by attempt status
    final unseen = allQuestions
        .where((q) => !attemptedIds.contains(q['id'].toString()))
        .toList();
    final previouslyWrong = allQuestions
        .where((q) => wrongIds.contains(q['id'].toString()))
        .toList();
    final others = allQuestions
        .where(
          (q) =>
              attemptedIds.contains(q['id'].toString()) &&
              !wrongIds.contains(q['id'].toString()),
        )
        .toList();

    final selected = <Map<String, dynamic>>[];

    // Priority 1: Unseen questions (up to 60% of session)
    unseen.shuffle();
    final unseenCount = (count * 0.6).ceil();
    selected.addAll(unseen.take(unseenCount));

    // Priority 2: Previously wrong questions
    if (selected.length < count) {
      previouslyWrong.shuffle();
      selected.addAll(previouslyWrong.take(count - selected.length));
    }

    // Priority 3: Other attempted questions (avoid recently shown)
    if (selected.length < count) {
      final notRecent = others
          .where((q) => !wasRecentlyShown(q['id'].toString()))
          .toList();
      notRecent.shuffle();
      selected.addAll(notRecent.take(count - selected.length));
    }

    // Final fallback: any questions if still not enough
    if (selected.length < count) {
      final remaining = allQuestions
          .where((q) => !selected.contains(q))
          .toList();
      remaining.shuffle();
      selected.addAll(remaining.take(count - selected.length));
    }

    // Shuffle final selection to avoid predictable patterns
    selected.shuffle();
    return selected.take(count).toList();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();

    // Save attempts
    final attemptsJson = json.encode(_attempts.map((a) => a.toJson()).toList());
    await prefs.setString(_attemptsKey, attemptsJson);

    // Save recently shown questions
    final recentJson = json.encode(_recentlyShownQuestions);
    await prefs.setString(_lastShownQuestionsKey, recentJson);

    // Save ripasso data
    if (_lastRipassoDate != null) {
      await prefs.setString(
        _dailyRipassoKey,
        _lastRipassoDate!.toIso8601String(),
      );
    }
    await prefs.setInt(_ripassoProgressKey, _dailyRipassoProgress);
  }

  Future<void> reset() async {
    _attempts.clear();
    _recentlyShownQuestions.clear();
    _dailyRipassoProgress = 0;
    _lastRipassoDate = DateTime.now();
    await _saveToPrefs();
    notifyListeners();
  }
}

class ExerciseAttempt {
  final String exerciseId;
  final bool isCorrect;
  final DateTime timestamp;
  final String mode;

  ExerciseAttempt({
    required this.exerciseId,
    required this.isCorrect,
    required this.timestamp,
    required this.mode,
  });

  Map<String, dynamic> toJson() => {
    'exerciseId': exerciseId,
    'isCorrect': isCorrect,
    'timestamp': timestamp.toIso8601String(),
    'mode': mode,
  };

  factory ExerciseAttempt.fromJson(Map<String, dynamic> json) =>
      ExerciseAttempt(
        exerciseId: json['exerciseId'],
        isCorrect: json['isCorrect'],
        timestamp: DateTime.parse(json['timestamp']),
        mode: json['mode'],
      );
}
