import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _backendUrlKey = 'backend_url';
  
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  String? _backendUrl;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _backendUrl = prefs.getString(_backendUrlKey);
    
    if (_backendUrl == null || _backendUrl!.isEmpty) {
      const defaultUrl = 'https://YOUR_REPLIT_DOMAIN/api';
      _backendUrl = defaultUrl;
      await prefs.setString(_backendUrlKey, defaultUrl);
    }
  }

  String? get apiKey => null;
  String? get backendUrl => _backendUrl;

  Future<void> setBackendUrl(String url) async {
    _backendUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_backendUrlKey, url);
  }
}