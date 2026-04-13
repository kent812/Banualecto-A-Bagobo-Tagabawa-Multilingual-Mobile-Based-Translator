import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'connectivity_service.dart';

enum FirebaseSyncStatus { idle, syncing, synced, error }

class FirebaseSyncService extends ChangeNotifier {
  static final FirebaseSyncService _instance = FirebaseSyncService._internal();
  factory FirebaseSyncService() => _instance;
  FirebaseSyncService._internal();

  FirebaseFirestore? _firestore;
  FirebaseSyncStatus _status = FirebaseSyncStatus.idle;
  bool _isInitialized = false;
  CollectionReference? _syncCollection;

  FirebaseSyncStatus get status => _status;
  bool get isOnline => ConnectivityService().isOnline;
  bool get isReady => _firestore != null;

  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      await Firebase.initializeApp();
      _firestore = FirebaseFirestore.instance;
      _syncCollection = _firestore!.collection('sync_queue');
      
      _isInitialized = true;
      
      ConnectivityService().addListener(_onConnectivityChanged);
      
      if (ConnectivityService().isOnline) {
        await syncPendingItems();
      }
    } catch (e) {
      debugPrint('Firebase init error: $e');
    }
  }

  void _onConnectivityChanged() {
    if (ConnectivityService().isOnline) {
      syncPendingItems();
    }
  }

  Future<void> saveBookmarks(List<String> bookmarkIds) async {
    if (_firestore == null) return;
    
    try {
      await _firestore!.collection('bookmarks').doc('user_bookmarks').set({
        'ids': bookmarkIds,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      debugPrint('Save bookmarks error: $e');
    }
  }

  Future<List<String>?> fetchBookmarks() async {
    if (_firestore == null) return null;
    
    try {
      final doc = await _firestore!.collection('bookmarks').doc('user_bookmarks').get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['ids'] != null) {
          return List<String>.from(data['ids'] as List);
        }
      }
    } catch (e) {
      debugPrint('Fetch bookmarks error: $e');
    }
    return null;
  }

  Future<void> saveHistory(List<String> historyIds) async {
    if (_firestore == null) return;
    
    try {
      await _firestore!.collection('history').doc('user_history').set({
        'ids': historyIds,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      debugPrint('Save history error: $e');
    }
  }

  Future<List<String>?> fetchHistory() async {
    if (_firestore == null) return null;
    
    try {
      final doc = await _firestore!.collection('history').doc('user_history').get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['ids'] != null) {
          return List<String>.from(data['ids'] as List);
        }
      }
    } catch (e) {
      debugPrint('Fetch history error: $e');
    }
    return null;
  }

  Future<void> addSuggestion(Map<String, dynamic> suggestion) async {
    if (_firestore == null) return;
    
    try {
      await _firestore!.collection('suggestions').add({
        ...suggestion,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      });
      notifyListeners();
    } catch (e) {
      debugPrint('Add suggestion error: $e');
    }
  }

  Future<void> syncPendingItems() async {
    if (!ConnectivityService().isOnline || _firestore == null) return;

    _status = FirebaseSyncStatus.syncing;
    notifyListeners();

    try {
      _status = FirebaseSyncStatus.synced;
    } catch (e) {
      _status = FirebaseSyncStatus.error;
      debugPrint('Sync error: $e');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}