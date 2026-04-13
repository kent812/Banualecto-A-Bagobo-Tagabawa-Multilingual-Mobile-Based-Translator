import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;

class GeminiCorrectionService {
  static const String _apiKey = 'AIzaSyAMthMk3BBZ29jBxZT9XbWsEDzFEHToqAM';
  static const String _model = 'gemini-2.0-flash';
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1/models/$_model:generateContent';

  String? _lastError;
  final Map<String, String> _cache = {};

  String? getLastError() => _lastError;

  Future<String?> translateWord(
    String text,
    String sourceLanguage,
    String targetLanguage,
  ) async {
    _lastError = null;

    if (sourceLanguage == targetLanguage) return text;

    final cacheKey = '$text|$sourceLanguage|$targetLanguage';
    if (_cache.containsKey(cacheKey)) {
      developer.log('Cache hit: $cacheKey');
      return _cache[cacheKey];
    }

    return await _callGemini(text, sourceLanguage, targetLanguage, cacheKey);
  }

  Future<String?> _callGemini(
    String text,
    String source,
    String target,
    String cacheKey,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': _buildPrompt(text, source, target)}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.1,
            'maxOutputTokens': 100,
          },
        }),
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final parts = data['candidates']?[0]?['content']?['parts'] as List?;
        if (parts != null && parts.isNotEmpty) {
          final result = (parts[0]['text'] as String).trim();
          _cache[cacheKey] = result;
          return result;
        }
        _lastError = 'Empty response from Gemini';
        return null;
      } else if (response.statusCode == 429) {
        _lastError = 'Quota exceeded. Try again later.';
        return null;
      } else {
        final err = jsonDecode(response.body);
        _lastError = err['error']?['message'] ?? 'Gemini error ${response.statusCode}';
        return null;
      }
    } catch (e) {
      _lastError = 'Network error: ${e.toString()}';
      return null;
    }
  }

  String _buildPrompt(String text, String source, String target) {
    final bagoboClarification = (source == 'Bagobo' || target == 'Bagobo')
        ? 'Bagobo Tagabawa is an indigenous Philippine language from Davao del Sur. '
          'It belongs to the Manobo language family.\n\n'
        : '';

    return '${bagoboClarification}Translate from $source to $target.\n'
        'Return ONLY the translated word or phrase. No explanations.\n\n'
        'Text: "$text"';
  }
}