import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService extends ChangeNotifier {
  static final BookmarkService _instance = BookmarkService._internal();
  factory BookmarkService() => _instance;
  BookmarkService._internal();

  static const String _bookmarksKey = 'bookmarked_items';
  final Set<String> _bookmarkedIds = {};
  bool _isInitialized = false;

  Set<String> get bookmarkedIds => _bookmarkedIds;

  Future<void> init() async {
    if (_isInitialized) return;
    final prefs = await SharedPreferences.getInstance();
    final savedBookmarks = prefs.getStringList(_bookmarksKey);
    if (savedBookmarks != null) {
      _bookmarkedIds.addAll(savedBookmarks);
    }
    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_bookmarksKey, _bookmarkedIds.toList());
  }

  bool isBookmarked(String wordId) {
    return _bookmarkedIds.contains(wordId);
  }

  Future<void> toggleBookmark(String wordId) async {
    if (_bookmarkedIds.contains(wordId)) {
      _bookmarkedIds.remove(wordId);
    } else {
      _bookmarkedIds.add(wordId);
    }
    notifyListeners();
    await _saveToPrefs();
  }

  List<String> get bookmarkedWordIds => _bookmarkedIds.toList();
}
