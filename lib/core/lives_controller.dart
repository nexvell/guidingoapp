import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Global Lives Controller for managing lives across all screens
/// Lives are synced across Home, Impara, Ripasso, and Esame modes
/// Resets daily at midnight Europe/Rome timezone
class LivesController extends ChangeNotifier {
  static final LivesController _instance = LivesController._internal();
  factory LivesController() => _instance;
  LivesController._internal();

  static const int maxLives = 8;
  static const String _livesKey = 'user_lives';
  static const String _lastResetKey = 'last_reset_date';

  int _currentLives = maxLives;
  DateTime? _lastResetDate;
  bool _isInitialized = false;

  int get currentLives => _currentLives;
  int get maxLivesCount => maxLives;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    _currentLives = prefs.getInt(_livesKey) ?? maxLives;

    final lastResetString = prefs.getString(_lastResetKey);
    if (lastResetString != null) {
      _lastResetDate = DateTime.parse(lastResetString);
    }

    // Check if we need to reset lives
    await _checkAndResetIfNeeded();
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _checkAndResetIfNeeded() async {
    final now = _getRomeDateTime();
    final today = DateTime(now.year, now.month, now.day);

    if (_lastResetDate == null) {
      _lastResetDate = today;
      await _saveToPrefs();
      return;
    }

    final lastResetDay = DateTime(
      _lastResetDate!.year,
      _lastResetDate!.month,
      _lastResetDate!.day,
    );

    // If last reset was before today, reset lives
    if (lastResetDay.isBefore(today)) {
      _currentLives = maxLives;
      _lastResetDate = today;
      await _saveToPrefs();
      notifyListeners();
    }
  }

  DateTime _getRomeDateTime() {
    // Europe/Rome timezone is UTC+1 (UTC+2 during DST)
    // Approximation: Add 1 hour to UTC (2 hours during summer)
    final utcNow = DateTime.now().toUtc();
    final month = utcNow.month;

    // Simple DST check: March-October is typically DST in Europe
    final isDst = month >= 3 && month <= 10;
    final offset = isDst ? 2 : 1;

    return utcNow.add(Duration(hours: offset));
  }

  DateTime getNextResetTime() {
    final now = _getRomeDateTime();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    return tomorrow;
  }

  Future<void> decrementLife() async {
    if (_currentLives > 0) {
      _currentLives--;
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> addLife() async {
    if (_currentLives < maxLives) {
      _currentLives++;
      await _saveToPrefs();
      notifyListeners();
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_livesKey, _currentLives);
    if (_lastResetDate != null) {
      await prefs.setString(_lastResetKey, _lastResetDate!.toIso8601String());
    }
  }

  Future<void> reset() async {
    _currentLives = maxLives;
    _lastResetDate = _getRomeDateTime();
    await _saveToPrefs();
    notifyListeners();
  }
}
