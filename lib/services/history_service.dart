import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistoryService extends ChangeNotifier {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  static const String _historyKey = 'history_items';
  static const String _viewCountKey = 'view_counts';
  final List<String> _history = [];
  final Map<String, int> _viewCounts = {};
  static const int maxHistoryItems = 50;
  bool _isInitialized = false;

  List<String> get history => List.unmodifiable(_history);

  Future<void> init() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    final savedHistory = prefs.getStringList(_historyKey);
    if (savedHistory != null) {
      _history.addAll(savedHistory);
    }
    final savedCounts = prefs.getStringList(_viewCountKey);
    if (savedCounts != null) {
      for (var i = 0; i < savedCounts.length; i += 2) {
        _viewCounts[savedCounts[i]] = int.tryParse(savedCounts[i + 1]) ?? 0;
      }
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, _history);
    final countsList = <String>[];
    _viewCounts.forEach((key, value) {
      countsList.add(key);
      countsList.add(value.toString());
    });
    await prefs.setStringList(_viewCountKey, countsList);
  }

  int getViewCount(String wordId) {
    return _viewCounts[wordId] ?? 0;
  }

  Future<void> addToHistory(String wordId) async {
    _history.remove(wordId);
    _history.insert(0, wordId);
    if (_history.length > maxHistoryItems) {
      _history.removeLast();
    }
    _viewCounts[wordId] = (_viewCounts[wordId] ?? 0) + 1;
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> incrementViewCount(String wordId) async {
    _viewCounts[wordId] = (_viewCounts[wordId] ?? 0) + 1;
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> clearHistory() async {
    _history.clear();
    _viewCounts.clear();
    notifyListeners();
    await _saveToPrefs();
  }

  Future<void> removeFromHistory(String wordId) async {
    _history.remove(wordId);
    notifyListeners();
    await _saveToPrefs();
  }
}