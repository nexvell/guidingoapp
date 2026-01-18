import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Tracks user mistakes across all quiz modes (Learn, Official Exam, Ripasso)
/// Implements mastery rule: correct 2 times in a row to remove from review
class MistakeTrackerService {
  static const String _storageKey = 'mistake_tracker_data';

  // Internal storage: questionId -> MistakeRecord
  final Map<String, MistakeRecord> _mistakes = {};

  bool _isInitialized = false;

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    final data = _mistakes.map((key, value) => MapEntry(key, value.toJson()));
    await prefs.setString(_storageKey, json.encode(data));
  }

  Future<void> initialize() async {
    if (_isInitialized) {
      print('⚠️ MistakeTrackerService already initialized, skipping');
      return;
    }

    print('🔧 Initializing MistakeTrackerService...');

    final prefs = await SharedPreferences.getInstance();
    final jsonData = prefs.getString(_storageKey);

    if (jsonData != null && jsonData.isNotEmpty) {
      try {
        final Map<String, dynamic> data = json.decode(jsonData);
        for (final entry in data.entries) {
          _mistakes[entry.key] = MistakeRecord.fromJson(entry.value);
        }
        print('✅ Loaded ${_mistakes.length} mistakes from storage');
      } catch (e) {
        print('⚠️ Error loading mistakes: $e');
      }
    } else {
      print('📋 No existing mistakes found');
    }

    _isInitialized = true;
  }

  /// Record a mistake when user answers wrong
  Future<void> recordMistake(String questionId) async {
    await initialize(); // Ensure initialized

    print('❌ Recording mistake for question $questionId');

    if (_mistakes.containsKey(questionId)) {
      // Existing mistake - increment count and reset consecutive correct
      _mistakes[questionId]!.wrongCount++;
      _mistakes[questionId]!.lastWrongAt = DateTime.now();
      _mistakes[questionId]!.consecutiveCorrectCount = 0;
      print(
        '   Updated: wrongCount=${_mistakes[questionId]!.wrongCount}, consecutive reset',
      );
    } else {
      // New mistake
      _mistakes[questionId] = MistakeRecord(
        questionId: questionId,
        wrongCount: 1,
        lastWrongAt: DateTime.now(),
        consecutiveCorrectCount: 0,
        lastSeenAt: DateTime.now(),
      );
      print('   New mistake recorded');
    }

    await _save();
  }

  /// Record correct answer for mastery tracking
  Future<void> recordCorrectAnswer(String questionId) async {
    await initialize(); // Ensure initialized

    if (_mistakes.containsKey(questionId)) {
      _mistakes[questionId]!.consecutiveCorrectCount++;
      _mistakes[questionId]!.lastSeenAt = DateTime.now();

      print(
        '✅ Correct answer for question $questionId - consecutive: ${_mistakes[questionId]!.consecutiveCorrectCount}',
      );

      // Mastery rule: 2 correct in a row = remove from review
      if (_mistakes[questionId]!.consecutiveCorrectCount >= 2) {
        _mistakes.remove(questionId);
        print('🎉 Question $questionId mastered! Removed from review.');
      }

      await _save();
    }
  }

  /// Get list of question IDs that need review (not yet mastered)
  List<String> getQuestionsToReview() {
    final questions = _mistakes.entries
        .map((e) => e.value)
        .where((record) => record.consecutiveCorrectCount < 2)
        .toList();

    // Sort by wrongCount (desc) and lastWrongAt (desc)
    questions.sort((a, b) {
      final countCompare = b.wrongCount.compareTo(a.wrongCount);
      if (countCompare != 0) return countCompare;
      return b.lastWrongAt.compareTo(a.lastWrongAt);
    });

    final ids = questions.map((r) => r.questionId).toList();
    print('📋 getQuestionsToReview returning ${ids.length} questions');
    return ids;
  }

  /// Get top N mistakes for Ripasso session
  List<String> getTopMistakes({int limit = 10}) {
    final allToReview = getQuestionsToReview();
    return allToReview.take(limit).toList();
  }

  /// Get total mistake count (for UI display)
  int get mistakeCount {
    return _mistakes.values
        .where((record) => record.consecutiveCorrectCount < 2)
        .length;
  }

  /// Clear all mistakes (for testing)
  Future<void> clearAll() async {
    _mistakes.clear();
    await _save();
    print('🗑️ All mistakes cleared');
  }

  /// Debug: Print current state
  void printDebugInfo() {
    print('📊 MistakeTracker Debug Info:');
    print('   Total mistakes: ${_mistakes.length}');
    print('   Needs review: $mistakeCount');
    print('   Initialized: $_isInitialized');
    for (final entry in _mistakes.entries) {
      print(
        '   Q${entry.key}: wrong=${entry.value.wrongCount}, consecutive=${entry.value.consecutiveCorrectCount}',
      );
    }
  }
}

/// Internal record for tracking mistake data
class MistakeRecord {
  final String questionId;
  int wrongCount;
  DateTime lastWrongAt;
  int consecutiveCorrectCount;
  DateTime lastSeenAt;

  MistakeRecord({
    required this.questionId,
    required this.wrongCount,
    required this.lastWrongAt,
    required this.consecutiveCorrectCount,
    required this.lastSeenAt,
  });

  Map<String, dynamic> toJson() => {
    'questionId': questionId,
    'wrongCount': wrongCount,
    'lastWrongAt': lastWrongAt.toIso8601String(),
    'consecutiveCorrectCount': consecutiveCorrectCount,
    'lastSeenAt': lastSeenAt.toIso8601String(),
  };

  factory MistakeRecord.fromJson(Map<String, dynamic> json) => MistakeRecord(
    questionId: json['questionId'] as String,
    wrongCount: json['wrongCount'] as int,
    lastWrongAt: DateTime.parse(json['lastWrongAt'] as String),
    consecutiveCorrectCount: json['consecutiveCorrectCount'] as int,
    lastSeenAt: DateTime.parse(json['lastSeenAt'] as String),
  );
}