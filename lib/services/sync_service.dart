import 'dart:convert';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'connectivity_service.dart';

enum SyncStatus { idle, syncing, synced, error }

enum SyncState { localFirst, syncing, synced }

class SyncItem {
  final String id;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  bool isSynced;

  SyncItem({
    required this.id,
    required this.type,
    required this.data,
    required this.createdAt,
    this.isSynced = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type,
    'data': data,
    'createdAt': createdAt.toIso8601String(),
    'isSynced': isSynced,
  };

  static SyncItem fromJson(Map<String, dynamic> json) => SyncItem(
    id: json['id'] as String,
    type: json['type'] as String,
    data: Map<String, dynamic>.from(json['data'] as Map),
    createdAt: DateTime.parse(json['createdAt'] as String),
    isSynced: json['isSynced'] as bool? ?? false,
  );
}

class SyncService extends ChangeNotifier {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  static const String _syncBoxName = 'sync_queue';
  static const String _settingsBoxName = 'app_settings';
  static const String _apiBaseUrl = 'https://api.banualecto.com';
  
  Box? _syncBox;
  Box? _settingsBox;
  
  SyncStatus _syncStatus = SyncStatus.idle;
  SyncState _syncState = SyncState.localFirst;
  bool _isInitialized = false;
  
  List<SyncItem> _pendingItems = [];

  SyncStatus get syncStatus => _syncStatus;
  SyncState get syncState => _syncState;
  bool get isOnline => ConnectivityService().isOnline;
  int get pendingCount => _pendingItems.length;

  Future<void> init() async {
    if (_isInitialized) return;
    
    await Hive.initFlutter();
    _syncBox = await Hive.openBox(_syncBoxName);
    _settingsBox = await Hive.openBox(_settingsBoxName);
    
    await _loadPendingItems();
    
    ConnectivityService().addListener(_onConnectivityChanged);
    
    _isInitialized = true;
    
    if (ConnectivityService().isOnline) {
      await syncPendingItems();
    }
  }

  void _onConnectivityChanged() {
    if (ConnectivityService().isOnline && _pendingItems.isNotEmpty) {
      syncPendingItems();
    }
  }

  Future<void> _loadPendingItems() async {
    if (_syncBox == null) return;
    
    final items = <SyncItem>[];
    for (final key in _syncBox!.keys) {
      final data = _syncBox!.get(key);
      if (data != null) {
        final item = SyncItem.fromJson(Map<String, dynamic>.from(data as Map));
        if (!item.isSynced) {
          items.add(item);
        }
      }
    }
    
    items.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    _pendingItems = items;
  }

  Future<void> addPendingItem({
    required String type,
    required Map<String, dynamic> data,
  }) async {
    final item = SyncItem(
      id: '${type}_${DateTime.now().millisecondsSinceEpoch}',
      type: type,
      data: data,
      createdAt: DateTime.now(),
      isSynced: false,
    );

    _pendingItems.add(item);
    await _syncBox?.put(item.id, item.toJson());
    notifyListeners();

    if (ConnectivityService().isOnline) {
      await syncPendingItems();
    }
  }

  Future<void> syncPendingItems() async {
    if (_pendingItems.isEmpty) return;
    if (!ConnectivityService().isOnline) return;

    _syncStatus = SyncStatus.syncing;
    _syncState = SyncState.syncing;
    notifyListeners();

    final unsyncedItems = _pendingItems.where((e) => !e.isSynced).toList();

    for (final item in unsyncedItems) {
      try {
        final success = await _syncItemToServer(item);
        if (success) {
          item.isSynced = true;
          await _syncBox?.put(item.id, item.toJson());
        }
      } catch (e) {
        debugPrint('Sync error for item ${item.id}: $e');
      }
    }

    _pendingItems.removeWhere((e) => e.isSynced);
    
    _syncStatus = _pendingItems.isEmpty ? SyncStatus.synced : SyncStatus.idle;
    _syncState = SyncState.synced;
    notifyListeners();
  }

  Future<bool> _syncItemToServer(SyncItem item) async {
    try {
      final url = Uri.parse('$_apiBaseUrl/sync');
      final client = http.Client();
      
      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'id': item.id,
          'type': item.type,
          'data': item.data,
          'timestamp': item.createdAt.toIso8601String(),
        }),
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> fetchFromServer(String endpoint) async {
    if (!ConnectivityService().isOnline) {
      return null;
    }

    try {
      final url = Uri.parse('$_apiBaseUrl/$endpoint');
      final client = http.Client();
      final response = await client.get(url);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      debugPrint('Fetch error: $e');
    }
    return null;
  }

  Future<void> saveLocal(String key, dynamic value) async {
    await _settingsBox?.put(key, value);
  }

  T? getLocal<T>(String key, {T? defaultValue}) {
    return _settingsBox?.get(key, defaultValue: defaultValue) as T? ?? defaultValue;
  }

  Future<void> clearPendingItems() async {
    _pendingItems.clear();
    await _syncBox?.clear();
    _syncStatus = SyncStatus.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}