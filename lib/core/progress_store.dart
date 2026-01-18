import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// ProgressStore - Manages quiz unlocking and completion persistence
/// Ensures sequential quiz unlocking and progress persistence across app restarts
class ProgressStore extends ChangeNotifier {
  static final ProgressStore _instance = ProgressStore._internal();
  factory ProgressStore() => _instance;
  ProgressStore._internal();

  static const String _progressKey = 'quiz_progress_store';

  // Structure: Map<moduleId, Map<sectionId, Map<quizId, bool>>>
  Map<String, Map<String, Map<int, bool>>> _progress = {};

  Future<void> initialize() async {
    print('🔧 Initializing ProgressStore...');
    final prefs = await SharedPreferences.getInstance();
    final progressJson = prefs.getString(_progressKey);

    if (progressJson != null) {
      final Map<String, dynamic> decoded = json.decode(progressJson);
      _progress = decoded.map(
        (moduleKey, moduleValue) => MapEntry(
          moduleKey,
          (moduleValue as Map<String, dynamic>).map(
            (sectionKey, sectionValue) => MapEntry(
              sectionKey,
              (sectionValue as Map<String, dynamic>).map(
                (quizKey, quizValue) =>
                    MapEntry(int.parse(quizKey), quizValue as bool),
              ),
            ),
          ),
        ),
      );
      print('✅ Loaded progress from storage: ${_progress.length} modules');
    } else {
      print('📋 No existing progress found, starting fresh');
    }

    notifyListeners();
  }

  /// Check if a specific quiz is completed
  bool isQuizCompleted(String moduleId, String sectionId, int quizId) {
    final result = _progress[moduleId]?[sectionId]?[quizId] ?? false;
    print('🔍 isQuizCompleted($moduleId/$sectionId/$quizId) = $result');
    return result;
  }

  /// Mark a quiz as completed
  Future<void> setQuizCompleted(
    String moduleId,
    String sectionId,
    int quizId, {
    bool completed = true,
  }) async {
    print(
      '💾 Setting quiz completed: $moduleId/$sectionId/$quizId = $completed',
    );

    if (!_progress.containsKey(moduleId)) {
      _progress[moduleId] = {};
      print('   Created new module entry: $moduleId');
    }
    if (!_progress[moduleId]!.containsKey(sectionId)) {
      _progress[moduleId]![sectionId] = {};
      print('   Created new section entry: $sectionId');
    }

    _progress[moduleId]![sectionId]![quizId] = completed;

    await _saveProgress();
    notifyListeners();

    print('✅ Quiz completion saved and notified');
  }

  /// Get count of completed quizzes in a section
  int getCompletedCount(String moduleId, String sectionId) {
    final sectionProgress = _progress[moduleId]?[sectionId];
    if (sectionProgress == null) {
      print('📊 getCompletedCount($moduleId/$sectionId) = 0 (no data)');
      return 0;
    }
    final count = sectionProgress.values.where((completed) => completed).length;
    print(
      '📊 getCompletedCount($moduleId/$sectionId) = $count/${sectionProgress.length}',
    );
    return count;
  }

  /// Check if a quiz is unlocked (Quiz 1 always unlocked, others require previous quiz completion)
  bool isQuizUnlocked(String moduleId, String sectionId, int quizId) {
    // Quiz 1 is always unlocked
    if (quizId == 1) {
      print(
        '🔓 isQuizUnlocked($moduleId/$sectionId/$quizId) = true (Quiz 1 always unlocked)',
      );
      return true;
    }

    // Quiz K is unlocked only if Quiz K-1 is completed
    final prevCompleted = isQuizCompleted(moduleId, sectionId, quizId - 1);
    print(
      '🔓 isQuizUnlocked($moduleId/$sectionId/$quizId) = $prevCompleted (depends on Quiz ${quizId - 1})',
    );
    return prevCompleted;
  }

  /// Get the next unlocked quiz number (returns null if all completed)
  int? getNextUnlockedQuiz(
    String moduleId,
    String sectionId,
    int totalQuizzes,
  ) {
    for (int i = 1; i <= totalQuizzes; i++) {
      if (!isQuizCompleted(moduleId, sectionId, i) &&
          isQuizUnlocked(moduleId, sectionId, i)) {
        return i;
      }
    }
    return null; // All completed
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = _progress.map(
      (moduleKey, moduleValue) => MapEntry(
        moduleKey,
        moduleValue.map(
          (sectionKey, sectionValue) => MapEntry(
            sectionKey,
            sectionValue.map(
              (quizKey, quizValue) => MapEntry(quizKey.toString(), quizValue),
            ),
          ),
        ),
      ),
    );
    await prefs.setString(_progressKey, json.encode(encoded));
    print('💾 Progress saved to SharedPreferences');
  }

  /// Reset all progress (for testing)
  Future<void> clearAll() async {
    _progress.clear();
    await _saveProgress();
    notifyListeners();
  }
}
