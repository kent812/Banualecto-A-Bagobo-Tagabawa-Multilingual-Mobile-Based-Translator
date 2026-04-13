import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

enum ConnectionStatus { online, offline, unknown }

class ConnectivityService extends ChangeNotifier {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  ConnectionStatus _status = ConnectionStatus.unknown;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectionStatus get status => _status;
  bool get isOnline => _status == ConnectionStatus.online;
  bool get isOffline => _status == ConnectionStatus.offline;

  Future<void> init() async {
    await checkConnection();
    _subscription = Connectivity().onConnectivityChanged.listen(_updateStatus);
  }

  Future<void> checkConnection() async {
    final result = await Connectivity().checkConnectivity();
    _updateStatus(result);
  }

  void _updateStatus(List<ConnectivityResult> results) {
    final newStatus = results.isEmpty || results.contains(ConnectivityResult.none)
        ? ConnectionStatus.offline
        : ConnectionStatus.online;
    
    if (_status != newStatus) {
      _status = newStatus;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}