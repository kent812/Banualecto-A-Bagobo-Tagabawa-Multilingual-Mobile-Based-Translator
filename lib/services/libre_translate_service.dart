import 'dart:convert';
import 'package:http/http.dart' as http;

class LibreTranslateService {
  static const List<String> _endpoints = [
    'https://libretranslate.com',
    'https://translate.argosopentech.com',
    'https://translate.terraprint.co',
  ];
  
  String? _lastError;
  int _currentEndpoint = 0;

  String? getLastError() => _lastError;

  Future<String?> translate(String text, String source, String target) async {
    final sourceCode = _mapLanguageCode(source);
    final targetCode = _mapLanguageCode(target);
    
    for (int i = 0; i < _endpoints.length; i++) {
      final idx = (_currentEndpoint + i) % _endpoints.length;
      final result = await _tryTranslate(_endpoints[idx], text, sourceCode, targetCode);
      if (result != null) {
        _currentEndpoint = idx;
        return result;
      }
    }
    
    _lastError = 'All LibreTranslate endpoints failed';
    return null;
  }

  Future<String?> _tryTranslate(String endpoint, String text, String source, String target) async {
    try {
      final response = await http.post(
        Uri.parse('$endpoint/translate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'source': source,
          'target': target,
          'format': 'text',
        }),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['translatedText'] as String?;
      } else {
        final error = jsonDecode(response.body);
        _lastError = error['error'] ?? 'Translation failed: ${response.statusCode}';
        return null;
      }
    } catch (e) {
      _lastError = 'Network error: ${e.toString()}';
      return null;
    }
  }

  String _mapLanguageCode(String lang) {
    final langLower = lang.toLowerCase();
    switch (langLower) {
      case 'english':
      case 'en':
        return 'en';
      case 'bagobo':
      case 'bg':
        return 'tl';
      case 'tagalog':
      case 'tl':
        return 'tl';
      case 'bisaya':
      case 'ceb':
        return 'ceb';
      default:
        return 'en';
    }
  }

  Future<List<String>?> getLanguages() async {
    try {
      final response = await http.get(
        Uri.parse('${_endpoints[_currentEndpoint]}/languages'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List;
        return data.map((l) => l['code'] as String).toList();
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
