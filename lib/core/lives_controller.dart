import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

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

    // Initialize timezone database
    tz.initializeTimeZones();

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
    final rome = tz.getLocation('Europe/Rome');
    final now = tz.TZDateTime.now(rome);
    final today = tz.TZDateTime(rome, now.year, now.month, now.day);

    if (_lastResetDate == null) {
      _lastResetDate = today;
      await _saveToPrefs();
      return;
    }

    final lastResetDay = tz.TZDateTime.from(_lastResetDate!, rome);

    // If last reset was before today, reset lives
    if (lastResetDay.isBefore(today)) {
      _currentLives = maxLives;
      _lastResetDate = today;
      await _saveToPrefs();
      notifyListeners();
    }
  }

  DateTime getNextResetTime() {
    final rome = tz.getLocation('Europe/Rome');
    final now = tz.TZDateTime.now(rome);
    final tomorrow = tz.TZDateTime(rome, now.year, now.month, now.day + 1);
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
    final rome = tz.getLocation('Europe/Rome');
    final now = tz.TZDateTime.now(rome);
    _currentLives = maxLives;
    _lastResetDate = tz.TZDateTime(rome, now.year, now.month, now.day);
    await _saveToPrefs();
    notifyListeners();
  }
}
