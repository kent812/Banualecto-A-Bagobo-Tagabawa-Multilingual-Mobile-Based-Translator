import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../services/gemini_correction_service.dart';
import '../services/bookmark_service.dart';
import '../services/settings_service.dart';
import '../services/debouncer.dart';
import '../services/translation_service.dart' show Language;
import '../models/word_model.dart';
import '../main.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});

  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final TextEditingController _ctrl = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final GeminiCorrectionService _geminiService = GeminiCorrectionService();
  final Debouncer _debouncer = Debouncer(milliseconds: 1000);

  Language _from = Language.bagobo;
  Language _to = Language.english;
  String _result = '';
  List<Map<String, String>> _allTranslations = [];
  bool _notFound = false;
  bool _speechEnabled = false;
  bool _isListening = false;
  String _lastWords = '';
  bool _isLoading = false;
  String? _errorMessage;
  bool _autoDetect = true;
  bool _isDebouncing = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _speechToText.cancel();
    _flutterTts.stop();
    _debouncer.dispose();
    super.dispose();
  }

  void _initTts() async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Speech error: ${error.errorMsg}'), backgroundColor: const Color(0xFF9B1C1C)),
        );
      },
    );
    setState(() {});
  }

  void _startListening() async {
    if (_speechEnabled) {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        localeId: 'en_PH',
      );
      setState(() => _isListening = true);
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() => _isListening = false);
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      _lastWords = result.recognizedWords;
      _ctrl.text = _lastWords;
    });
  }

  void _swap() {
    setState(() {
      final tmp = _from;
      _from = _to;
      _to = tmp;
      _ctrl.clear();
      _result = '';
      _allTranslations = [];
      _notFound = false;
    });
  }

  void _go() {
    final inp = _ctrl.text.trim();
    if (inp.isEmpty) return;
    if (_from == _to) {
      setState(() { _result = inp; _notFound = false; _allTranslations = []; });
      return;
    }
    
    if (_isDebouncing) return;
    
    _debouncer.run(() {
      _translateWithGemini(inp);
    });
  }

  Future<void> _translateWithGemini(String text) async {
    setState(() { 
      _isLoading = true; 
      _isDebouncing = true;
      _errorMessage = null;
      _result = '';
      _allTranslations = [];
    });
    
    final sourceLang = _from.displayName;
    final targetLang = _to.displayName;
    
    debugPrint('Translating from $sourceLang to $targetLang: $text');
    
    final result = await _geminiService.translateWord(text, sourceLang, targetLang);
    
    debugPrint('Result: $result');
    debugPrint('Error: ${_geminiService.getLastError()}');
    
    if (result != null && result.isNotEmpty) {
      final otherTranslations = <Map<String, String>>[];
      
      for (final lang in Language.values.where((l) => l != _from && l != _to)) {
        final otherResult = await _geminiService.translateWord(text, sourceLang, lang.displayName);
        if (otherResult != null && otherResult.isNotEmpty) {
          otherTranslations.add({
            'lang': lang.displayName,
            'code': lang.code,
            'word': otherResult,
          });
        }
      }
      
      setState(() {
        _result = result;
        _allTranslations = otherTranslations;
        _notFound = false;
      });
    } else {
      setState(() {
        _errorMessage = _geminiService.getLastError() ?? 'Translation failed';
        _notFound = true;
      });
    }
    
    setState(() => _isLoading = false);
    setState(() => _isDebouncing = false);
  }

  void _setFrom(Language l) {
    setState(() {
      if (l == _to) _to = _from;
      _from = l;
      _result = '';
      _allTranslations = [];
      _notFound = false;
      _ctrl.clear();
      _autoDetect = false;
    });
  }

  void _setTo(Language l) {
    setState(() {
      if (l == _from) _from = _to;
      _to = l;
      _result = '';
      _allTranslations = [];
      _notFound = false;
      _ctrl.clear();
      _autoDetect = false;
    });
  }

  Language _detectLanguage(String text) {
    if (text.isEmpty) return Language.english;
    
    final lowerText = text.toLowerCase().trim();
    final words = lowerText.split(RegExp(r'\s+'));
    
    final completeBagoboPhrases = [
      'ako ay', 'ikaw ay', 'siya ay', 'kami ay', 'kayo ay', 'sila ay',
      'ako man', 'ikaw man', 'siya man', 'kami man', 'kayo man', 'sila man',
      'ako pa', 'ikaw pa', 'siya pa', 'kami pa', 'kayo pa', 'sila pa',
      'ako na', 'ikaw na', 'siya na', 'kami na', 'kayo na', 'sila na',
      'ako lang', 'ikaw lang', 'siya lang', 'kami lang', 'kayo lang', 'sila lang',
      'ako gid', 'ikaw gid', 'siya gid', 'kami gid', 'kayo gid', 'sila gid',
      'ang akon', 'ang imong', 'ang iya', 'ang among', 'ang inyong', 'ang nila',
      'ang tanan', 'ang tanan', 'ang tanan',
      'kay kang', 'kay sa', 'kang ako', 'kang ikaw', 'kang siya', 'kang kami', 'kang kamo', 'kang sila',
      'sa ako', 'sa ikaw', 'sa iya', 'sa kami', 'sa kamo', 'sa sila',
      'para sa ako', 'para sa ikaw', 'para sa iya', 'para sa kami',
      'diri sa', 'didto sa', 'kini nga', 'kadtong', 'kining',
      'wala sa', 'may', 'walay', 'dili', 'kay', 'kung',
      'na kana', 'na kini', 'na didto', 'na diri',
      'kanang', 'kining', 'kadtong', 'nako', 'nimo', 'niya', 'among', 'ninyo', 'nilang',
      'ako gid', 'ikaw gid', 'siya gid', 'kami gid', 'kayo gid',
      'ako ra', 'ikaw ra', 'siya ra', 'kami ra', 'kayo ra',
      'ako man pud', 'ikaw man pud', 'siya man pud',
      'giunsa', 'gikano', 'unu', 'kini', 'kadtu', 'asa',
      'unsa ang', 'asa ang', 'kano ang',
      'dili ko', 'dili ka', 'dili siya', 'dili kami', 'dili kamo', 'dili sila',
      'kay ako', 'kay ikaw', 'kay siya', 'kay kami', 'kay kamo', 'kay sila',
      'kung ako', 'kung ikaw', 'kung siya', 'kung kami',
      'kay kung', 'kay og', 'kay ug',
      'bóó diyá', 'gató', 'kámay', 'níyo', 'sángulo', 'tahód', 'tubig', 'laman', 'dagon', 
      'páng', 'sá', 'báwa', 'lúong', 'báso', 'súlat', 'kíta', 'túyon', 'púso', 'kítab',
      'balay', 'tambok', 'lawas', 'ulo', 'kamot', 'tiil', 'tungod', 'busog', 'gutom',
      'ako', 'ikaw', 'siya', 'kami', 'kamo', 'sila',
    ];
    
    int bagoboScore = 0;
    for (final phrase in completeBagoboPhrases) {
      if (lowerText.contains(phrase.toLowerCase())) {
        bagoboScore += 3;
      }
    }
    
    if (words.length > 1) {
      for (int i = 0; i < words.length - 1; i++) {
        final pair = '${words[i]} ${words[i+1]}';
        if (completeBagoboPhrases.contains(pair)) {
          bagoboScore += 4;
        }
      }
    }
    
    if (words.length > 2) {
      for (int i = 0; i < words.length - 2; i++) {
        final triple = '${words[i]} ${words[i+1]} ${words[i+2]}';
        if (completeBagoboPhrases.contains(triple)) {
          bagoboScore += 5;
        }
      }
    }
    
    final completeTagalogPhrases = [
      'ako ay', 'ikaw ay', 'siya ay', 'kami ay', 'kayo ay', 'sila ay',
      'ako man', 'ikaw man', 'siya man', 'kami man', 'kayo man', 'sila man',
      'ako pa', 'ikaw pa', 'siya pa', 'kami pa', 'kayo pa', 'sila pa',
      'ako na', 'ikaw na', 'siya na', 'kami na', 'kayo na', 'sila na',
      'ako lang', 'ikaw lang', 'siya lang', 'kami lang', 'kayo lang', 'sila lang',
      'ako rin', 'ikaw rin', 'siya rin', 'kami rin', 'kayo rin', 'sila rin',
      'ang akin', 'ang iyo', 'ang kaniya', 'ang amin', 'ang inyo', 'ang kanila',
      'ang lahat', 'ang bawat', 'ang isa',
      'ang ', 'ng ', 'sa ',
      'nang ', 'mga ',
      'si ', 'ni ', 'kay ',
      'ako ng', 'ikaw ng', 'siya ng', 'kami ng', 'kayo ng', 'sila ng',
      'gusto ko', 'gusto ikaw', 'gusto niya', 'gusto namin', 'gusto nyo',
      'gusto kong', 'gusto mong', 'gusto niyang',
      'kailangan ko', 'kailangan ikaw', 'kailangan niya',
      'mayroon ako', 'mayroon ikaw', 'mayroon siya', 'mayroon kami', 'mayroon kayo',
      'walang', 'hindi', 'hindi ako', 'hindi ikaw', 'hindi siya',
      'para sa', 'sa pamamagitan', 'dahil sa',
      'ito ay', 'iyon ay', 'iyang', 'iyong',
      'nila', 'namin', 'ninyo',
      'salamat', 'maraming salamat', 'salamat po',
      'paalam', 'paalam na', 'magkita na lang',
      'kumusta ka', 'kumusta', 'kamusta',
      'ano ', 'saan ', 'paano ', 'bakit ', 'kailan ',
      'hindi ko', 'hindi ka', 'hindi siya', 'hindi kami', 'hindi kayo', 'hindi sila',
      'hindi rin', 'hindi lang', 'hindi pa',
    ];
    
    int tagalogScore = 0;
    for (final phrase in completeTagalogPhrases) {
      if (lowerText.contains(phrase.toLowerCase())) {
        tagalogScore += 3;
      }
    }
    
    if (words.length > 1) {
      for (int i = 0; i < words.length - 1; i++) {
        final pair = '${words[i]} ${words[i+1]}';
        if (completeTagalogPhrases.contains(pair)) {
          tagalogScore += 4;
        }
      }
    }
    
    if (words.length > 2) {
      for (int i = 0; i < words.length - 2; i++) {
        final triple = '${words[i]} ${words[i+1]} ${words[i+2]}';
        if (completeTagalogPhrases.contains(triple)) {
          tagalogScore += 5;
        }
      }
    }
    
    final completeBisayaPhrases = [
      'ako ay', 'ikaw ay', 'siya ay', 'kami ay', 'kamo ay', 'sila ay',
      'ako man', 'ikaw man', 'siya man', 'kami man', 'kamo man', 'sila man',
      'ako pa', 'ikaw pa', 'siya pa', 'kami pa', 'kamo pa', 'sila pa',
      'ako na', 'ikaw na', 'siya na', 'kami na', 'kamo na', 'sila na',
      'ako lang', 'ikaw lang', 'siya lang', 'kami lang', 'kamo lang', 'sila lang',
      'ako gid', 'ikaw gid', 'siya gid', 'kami gid', 'kamo gid', 'sila gid',
      'ang akon', 'ang imong', 'ang iya', 'ang among', 'ang inyong', 'ang nila',
      'ang tanan', 'ang tanan',
      'si ', 'ni ', 'kay ',
      'sa ako', 'sa ikaw', 'sa iya', 'sa kami', 'sa kamo', 'sa sila',
      'para sa ako', 'para sa ikaw', 'para sa iya',
      'kini', 'kadtu', 'diri', 'didto', 'kang', 'og', 'ug',
      'ka', 'na', 'pa', 'lang', 'gid', 'man', 'ra', 'nga',
      'nako', 'nimo', 'niya', 'among', 'ninyo', 'nilang',
      'walay', 'may', 'dili', 'kay', 'kung',
      'kay sauna', 'kay kinsa', 'kay unsa',
      'kanang', 'kining', 'kadtong',
      'mu', 'mo', 'ko',
      'giunsa', 'gikano', 'unu', 'asa',
      'unsa ang', 'asa ang', 'kano ang',
      'dili ko', 'dili ka', 'dili siya', 'dili kami', 'dili kamo', 'dili sila',
      'dili man', 'dili lang', 'dili ra',
      'kay ako', 'kay ikaw', 'kay siya', 'kay kami', 'kay kamo', 'kay sila',
      'kung ako', 'kung ikaw', 'kung siya', 'kung kami',
      'salamat', 'salamat kaayo', 'salamat pud',
      'dayon', 'dayon lang', 'kita na',
      'kumusta', 'kumusta ka', 'kamusta',
      'unsa nay', 'asa na', 'unsa na',
    ];
    
    int bisayaScore = 0;
    for (final phrase in completeBisayaPhrases) {
      if (lowerText.contains(phrase.toLowerCase())) {
        bisayaScore += 3;
      }
    }
    
    if (words.length > 1) {
      for (int i = 0; i < words.length - 1; i++) {
        final pair = '${words[i]} ${words[i+1]}';
        if (completeBisayaPhrases.contains(pair)) {
          bisayaScore += 4;
        }
      }
    }
    
    if (words.length > 2) {
      for (int i = 0; i < words.length - 2; i++) {
        final triple = '${words[i]} ${words[i+1]} ${words[i+2]}';
        if (completeBisayaPhrases.contains(triple)) {
          bisayaScore += 5;
        }
      }
    }
    
    final bagoboOnlyWords = [
      'bóó', 'gató', 'kámay', 'níyo', 'sángulo', 'tahód', 'tubig', 'laman', 'dagon', 
      'páng', 'sá', 'báwa', 'lúong', 'báso', 'súlat', 'kíta', 'túyon', 'púso', 'kítab',
      'balay', 'tambok', 'lawas', 'ulo', 'kamot', 'tiil', 'tungod', 'busog', 'gutom',
    ];
    int bagoboExact = 0;
    for (final word in bagoboOnlyWords) {
      if (lowerText.contains(word.toLowerCase())) {
        bagoboExact += 5;
      }
    }
    bagoboScore += bagoboExact;
    
    final isEnglishPattern = RegExp(r'^[a-zA-Z\s.,?!\-]+$');
    final isEnglish = isEnglishPattern.hasMatch(lowerText) && 
                      !lowerText.contains('ang ') && 
                      !lowerText.contains('ng ') && 
                      !lowerText.contains('sa ') &&
                      !lowerText.contains('ako') && 
                      !lowerText.contains('ikaw') &&
                      !lowerText.contains('siya') &&
                      !lowerText.contains('kami');
    
    if (isEnglish && bagoboScore == 0 && tagalogScore == 0 && bisayaScore == 0) {
      return Language.english;
    }
    
    if (bagoboScore > tagalogScore && bagoboScore > bisayaScore && bagoboScore >= 6) {
      return Language.bagobo;
    } else if (tagalogScore > bisayaScore && tagalogScore >= 6) {
      return Language.tagalog;
    } else if (bisayaScore >= 6) {
      return Language.bisaya;
    }
    
    return Language.english;
  }
  
  Future<Language?> _detectLanguageWithGemini(String text) async {
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (_, isDark, __) {
        final bg = isDark ? const Color(0xFF13100D) : const Color(0xFFFAF6F0);
        final surface = isDark ? const Color(0xFF2A2420) : Colors.white;
        final text = isDark ? const Color(0xFFF5F0EA) : const Color(0xFF1A1108);
        final sub = isDark ? const Color(0xFFA89B8C) : const Color(0xFF5C4F3D);
        final accent = const Color(0xFFB85C38);
        final card = isDark ? const Color(0xFF2A2420) : const Color(0xFFB85C38);
        final border = isDark ? const Color(0xFF3A332D) : const Color(0xFFE8DDD0);

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: text, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Translate', style: TextStyle(color: text, fontWeight: FontWeight.bold, fontSize: 22)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Row(children: [
                Expanded(child: _LangPicker(
                  selected: _from,
                  label: _autoDetect ? 'From (Auto)' : 'From',
                  excluded: _to,
                  onSelect: _setFrom,
                  accent: accent, text: text, sub: sub, surface: surface, border: border,
                )),
                GestureDetector(
                  onTap: _swap,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 10),
                    width: 40, height: 40,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    child: const Icon(Icons.swap_horiz_rounded, color: Colors.white, size: 22),
                  ),
                ),
                Expanded(child: _LangPicker(
                  selected: _to,
                  label: 'To',
                  excluded: _from,
                  onSelect: _setTo,
                  accent: accent, text: text, sub: sub, surface: surface, border: border,
                )),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Text('Auto-detect language', style: TextStyle(color: sub, fontSize: 13)),
                const Spacer(),
                Switch(
                  value: _autoDetect,
                  onChanged: (v) => setState(() {
                    _autoDetect = v;
                    if (v && _ctrl.text.isNotEmpty) {
                      final detected = _detectLanguage(_ctrl.text);
                      if (detected != _from) {
                        _from = detected;
                      }
                    }
                  }),
                  activeThumbColor: accent,
                ),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _LangPicker(
                  selected: _to,
                  label: 'To',
                  excluded: _from,
                  onSelect: _setTo,
                  accent: accent, text: text, sub: sub, surface: surface, border: border,
                )),
              ]),
              const SizedBox(height: 18),
              Container(
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                ),
                padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
                child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  TextField(
                    controller: _ctrl,
                    style: TextStyle(color: text, fontSize: 20, fontWeight: FontWeight.w500),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Type in ${_from.name}…',
                      hintStyle: TextStyle(color: sub, fontSize: 15, fontWeight: FontWeight.w400),
                      border: InputBorder.none,
                    ),
                    onChanged: (v) {
                      setState(() { _result = ''; _allTranslations = []; _notFound = false; _errorMessage = null; });
                      if (_autoDetect && v.isNotEmpty) {
                        final detected = _detectLanguage(v);
                        if (detected != _from && detected != _to) {
                          setState(() => _from = detected);
                        }
                      }
                    },
                    onSubmitted: (_) => _go(),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Row(children: [
                      Text(_from.code, style: TextStyle(fontSize: 14, color: sub, fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      _isListening
                          ? GestureDetector(
                              onTap: _stopListening,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(color: const Color(0xFF9B1C1C).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: Row(children: [
                          Icon(Icons.mic, color: const Color(0xFF9B1C1C), size: 16),
                          const SizedBox(width: 4),
                          Text('Stop', style: TextStyle(color: const Color(0xFF9B1C1C), fontSize: 12, fontWeight: FontWeight.w500)),
                        ]),
                      ),
                            )
                          : GestureDetector(
                              onTap: _speechEnabled ? _startListening : null,
                              child: Icon(Icons.mic_none_rounded, color: _speechEnabled ? accent : sub, size: 20),
                            ),
                    ]),
                    if (_ctrl.text.isNotEmpty)
                      GestureDetector(
                        onTap: () { _ctrl.clear(); setState(() { _result = ''; _allTranslations = []; _notFound = false; }); },
                        child: Icon(Icons.clear_rounded, color: sub, size: 18),
                      ),
                  ]),
                ]),
              ),
              const SizedBox(height: 12),
              if (_isLoading)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: accent),
                    ),
                    const SizedBox(width: 12),
                    Text('Translating with AI...', style: TextStyle(color: sub, fontSize: 14)),
                  ]),
                )
              else
                GestureDetector(
                onTap: _go,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3))],
                  ),
                  child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.translate_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text('Translate', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15, letterSpacing: 0.3)),
                  ]),
                ),
              ),
              const SizedBox(height: 20),
              if (_notFound)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                  ),
                  child: Row(children: [
                    Icon(Icons.info_outline_rounded, color: sub, size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text('No translation found for "${_ctrl.text.trim()}"', style: TextStyle(color: sub, fontSize: 14))),
                  ]),
                )
              else if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9B1C1C).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF9B1C1C).withValues(alpha: 0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.error_outline_rounded, color: Color(0xFF9B1C1C), size: 20),
                    const SizedBox(width: 10),
                    Expanded(child: Text(_errorMessage!, style: const TextStyle(color: Color(0xFF9B1C1C), fontSize: 14))),
                  ]),
                )
              else if (_result.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: card,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('${_to.code}  ${_to.name}', style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.w500)),
                      Row(children: [
                        GestureDetector(
                          onTap: () => _speak(_result),
                          child: Icon(Icons.volume_up_rounded, color: Colors.white.withValues(alpha: 0.5), size: 18),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            final word = DictionaryWord(
                              id: 'temp', word: _ctrl.text.trim(), bagoboWord: _result,
                              tagalog: '', bisaya: '', partOfSpeech: '', description: '',
                              synonyms: [], exampleSentence: '', category: '', pronunciation: '',
                            );
                            context.read<BookmarkService>().toggleBookmark(word.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Toggled favorite!'), duration: Duration(seconds: 1)),
                            );
                          },
                          child: Icon(Icons.favorite_border_rounded, color: Colors.white.withValues(alpha: 0.5), size: 18),
                        ),
                      ]),
                    ]),
                    const SizedBox(height: 10),
                    Text(_result, style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold, letterSpacing: 0.3)),
                    if (_allTranslations.isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(children: [
                          Text('All translations', style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11)),
                          const SizedBox(height: 8),
                          ..._allTranslations.map((tr) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 3),
                            child: Row(children: [
                              Text('${tr['code']}  ', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.55), fontWeight: FontWeight.w600)),
                              SizedBox(width: 70, child: Text(tr['lang']!, style: TextStyle(color: Colors.white.withValues(alpha: 0.55), fontSize: 12))),
                              Expanded(child: Text(tr['word']!, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600))),
                            ]),
                          )),
                        ]),
                      ),
                    ],
                  ]),
                ),
              const SizedBox(height: 24),
              Text('Try these words', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: sub)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 8, children: [
                'abaca', 'ability', 'afraid', 'beautiful', 'agreement', 'allow', 'arrive', 'advice',
              ].map((w) => GestureDetector(
                onTap: () {
                  _ctrl.text = w;
                  _from = Language.english;
                  if (_to == Language.english) _to = Language.bagobo;
                  setState(() { _result = ''; _allTranslations = []; _notFound = false; });
                  _go();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: border),
                  ),
                  child: Text(w, style: TextStyle(color: accent, fontSize: 13, fontWeight: FontWeight.w500)),
                ),
              )).toList()),
            ]),
          ),
        );
      },
    );
  }
}

class _LangPicker extends StatelessWidget {
  final Language selected;
  final Language excluded;
  final String label;
  final ValueChanged<Language> onSelect;
  final Color accent, text, sub, surface, border;

  const _LangPicker({
    required this.selected, required this.excluded, required this.label, required this.onSelect,
    required this.accent, required this.text, required this.sub, required this.surface, required this.border,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
        ),
        child: Row(children: [
          Text(selected.code, style: TextStyle(fontSize: 14, color: accent, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 10, color: sub)),
            Text(selected.name, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: text)),
          ])),
          Icon(Icons.keyboard_arrow_down_rounded, color: sub, size: 18),
        ]),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(width: 36, height: 4, decoration: BoxDecoration(color: border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 14),
          Text('Select $label language', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: text)),
          const SizedBox(height: 12),
          ...Language.values.map((l) {
            final isSelected = l == selected;
            final isExcluded = l == excluded;
            return ListTile(
              leading: Text(l.code, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: accent)),
              title: Text(l.name, style: TextStyle(
                color: isExcluded ? sub : text,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              )),
              trailing: isSelected ? Icon(Icons.check_rounded, color: accent) : null,
              subtitle: isExcluded ? Text('Already selected', style: TextStyle(fontSize: 11, color: sub)) : null,
              onTap: () {
                Navigator.pop(context);
                onSelect(l);
              },
            );
          }),
          const SizedBox(height: 8),
        ]),
      ),
    );
  }
}
