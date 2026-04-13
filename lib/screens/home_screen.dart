import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'guide_screen.dart';
import 'about_screen.dart';
import 'articles_screen.dart';
import 'trending_screen.dart';
import 'translate_screen.dart';
import 'history_screen.dart';
import '../main.dart';
import '../data/dictionary_data.dart';
import '../models/word_model.dart';
import '../services/bookmark_service.dart';
import '../services/history_service.dart';
import '../services/connectivity_service.dart';
import '../services/sync_service.dart';
import '../services/translation_service.dart' show Language;
import '../services/gemini_correction_service.dart';
import '../services/settings_service.dart';
import '../services/debouncer.dart';

void main() => runApp(const BanualectoApp());

final darkModeNotifier = ValueNotifier<bool>(false);

class BanualectoApp extends StatelessWidget {
  const BanualectoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (_, isDark, __) => MaterialApp(
        title: 'Banualecto',
        debugShowCheckedModeBanner: false,
        themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
        theme: ThemeData(useMaterial3: true, brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFFAF6F0)),
        darkTheme: ThemeData(useMaterial3: true, brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF13100D)),
        home: const MainShell(),
      ),
    );
  }
}

class T {
  final bool dark;
  const T(this.dark);
  Color get bg => dark ? const Color(0xFF13100D) : const Color(0xFFFAF6F0);
  Color get surface => dark ? const Color(0xFF2A2420) : Colors.white;
  Color get card => dark ? const Color(0xFF2A2420) : const Color(0xFFB85C38);
  Color get nav => dark ? const Color(0xFF1E1A16) : Colors.white;
  Color get text => dark ? const Color(0xFFF5F0EA) : const Color(0xFF1A1108);
  Color get sub => dark ? const Color(0xFFA89B8C) : const Color(0xFF5C4F3D);
  Color get accent => const Color(0xFFB85C38);
  Color get chip => dark ? const Color(0xFFD4845A) : const Color(0xFFB85C38);
  Color get border => dark ? const Color(0xFF3A332D) : const Color(0xFFE8DDD0);
  Color get dotOn => const Color(0xFFB85C38);
  Color get dotOff => dark ? const Color(0xFF3A332D) : const Color(0xFFD9CEC1);
  Color get tileLabel => dark ? const Color(0xFFD4845A) : const Color(0xFF5E2510);
  Color get navOff => dark ? const Color(0xFF6D6258) : const Color(0xFF8A7B68);
  Color get togTrack => dark ? const Color(0xFF2A2420) : const Color(0xFFEDE3D6);
  Color get togBorder => dark ? const Color(0xFF3A332D) : const Color(0xFFD9CEC1);
  Color get thumb => dark ? const Color(0xFFF4C95D) : const Color(0xFFB85C38);
  Color get thumbFg => dark ? const Color(0xFF1E1A16) : Colors.white;
  Color get divider => dark ? const Color(0xFF3A332D) : const Color(0xFFEDE3D6);
  Color get glassBg => dark ? Colors.white.withValues(alpha: 0.1) : Colors.white.withValues(alpha: 0.25);
  Color get glassBorder => dark ? Colors.white.withValues(alpha: 0.2) : Colors.white.withValues(alpha: 0.4);
}

class _PageMeta {
  final String title;
  final String? subtitle;
  final IconData icon;
  const _PageMeta({required this.title, this.subtitle, required this.icon});
}

const _pages = [
  _PageMeta(title: 'Banualecto', subtitle: 'Bagobo-Tagabawa Translator', icon: Icons.home_rounded),
  _PageMeta(title: 'Search', icon: Icons.search_rounded),
  _PageMeta(title: 'Translate', icon: Icons.translate_rounded),
  _PageMeta(title: 'Games', icon: Icons.extension_rounded),
  _PageMeta(title: 'About', icon: Icons.info_outline_rounded),
];

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _idx = 0;

  static const _bodies = [
    _HomeBody(),
    _SearchBody(),
    _TranslateBody(),
    _GamesBody(),
    _SavedBody(),
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (_, isDark, __) {
        final t = T(isDark);
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ));

        return Scaffold(
          backgroundColor: t.bg,
          appBar: AppBar(
            backgroundColor: t.bg,
            elevation: 0,
            scrolledUnderElevation: 0,
            automaticallyImplyLeading: false,
            centerTitle: true,
            toolbarHeight: 68,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  _pages[_idx].title,
                  style: TextStyle(
                    fontSize: _idx == 0 ? 26 : 22,
                    fontWeight: FontWeight.bold,
                    color: t.text,
                    letterSpacing: 0.3,
                  ),
                ),
                if (_pages[_idx].subtitle != null)
                  Text(
                    _pages[_idx].subtitle!,
                    style: TextStyle(fontSize: 12, color: t.sub),
                  ),
              ],
            ),
            actions: [
              Consumer<ConnectivityService>(
                builder: (_, connectivity, __) {
                  final isOnline = connectivity.isOnline;
                  return Container(
                    margin: const EdgeInsets.only(right: 8, top: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isOnline 
                          ? const Color(0xFF1D6A3A).withValues(alpha: 0.15)
                          : const Color(0xFF9B1C1C).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6, height: 6,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isOnline ? const Color(0xFF1D6A3A) : const Color(0xFF9B1C1C),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isOnline ? 'Online' : 'Offline',
                          style: TextStyle(
                            fontSize: 10,
                            color: isOnline ? const Color(0xFF1D6A3A) : const Color(0xFF9B1C1C),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.only(right: 20),
                child: _Toggle(t: t),
              ),
            ],
          ),
          body: IndexedStack(index: _idx, children: _bodies),
          bottomNavigationBar: _BottomNav(
            idx: _idx,
            onTap: (i) => setState(() => _idx = i),
            t: t,
          ),
        );
      },
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();
  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {

  DictionaryWord _getWordOfTheDay() {
    final wordsWithBagobo = dictionaryWords.where((w) => w.bagoboWord.isNotEmpty).toList();
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    return wordsWithBagobo[dayOfYear % wordsWithBagobo.length];
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (_, isDark, __) {
        final t = T(isDark);
        final wotd = _getWordOfTheDay();
        final wotdWord = wotd.bagoboWord.split(',').first.trim();
        final wotdMeaning = wotd.word;
        final wotdDesc = wotd.description.isNotEmpty ? '"${wotd.description}"' : '';
        return ColoredBox(
          color: t.bg,
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(color: t.card, borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: t.chip, borderRadius: BorderRadius.circular(20)),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(Icons.star_rounded, color: Color(0xFFFFCC66), size: 14),
                          SizedBox(width: 5),
                          Text('Word of the Day', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                        ]),
                      ),
                      Container(
                        width: 34, height: 34,
                        decoration: BoxDecoration(color: t.chip, shape: BoxShape.circle),
                        child: const Icon(Icons.volume_up_rounded, color: Colors.white, size: 18),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    Text(wotdWord, style: const TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(color: t.chip, borderRadius: BorderRadius.circular(20)),
                      child: Text('Bagobo: $wotdMeaning', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500)),
                    ),
                    const SizedBox(height: 14),
                    Text(wotdDesc,
                        style: const TextStyle(color: Color(0xFFE8C9B0), fontSize: 13, fontStyle: FontStyle.italic)),
                  ]),
                ),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text('World of Words', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.text)),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Wrap(spacing: 10, children: [
                  _Chip(icon: Icons.menu_book_rounded, label: 'Guide', t: t,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GuideScreen()))),
                  _Chip(icon: Icons.lightbulb_outline_rounded, label: 'Suggest', t: t,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen()))),
                ]),
              ),
              const SizedBox(height: 28),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Recent Searches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.text)),
                    GestureDetector(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
                      child: Text('See all', style: TextStyle(fontSize: 13, color: t.accent, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              ListenableBuilder(
                listenable: HistoryService(),
                builder: (_, __) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: _buildTrendingRows(t),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ]),
          ),
        );
      },
    );
  }

  List<Widget> _buildTrendingRows(T t) {
    final historyService = HistoryService();
    final historyIds = historyService.history.take(5).toList();
    if (historyIds.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Text('Words you view will appear here', style: TextStyle(color: t.sub, fontSize: 13)),
        ),
      ];
    }
    final rows = <Widget>[];
    for (var i = 0; i < historyIds.length; i++) {
      try {
        final word = dictionaryWords.firstWhere((w) => w.id == historyIds[i]);
        final viewCount = historyService.getViewCount(word.id);
        rows.add(_TrendingRow(
          t: t,
          rank: i + 1,
          word: word.word,
          meaning: word.bagoboWord.isNotEmpty ? word.bagoboWord : word.tagalog,
          views: viewCount,
        ));
      } catch (_) {}
    }
    return rows;
  }
}

class _SearchBody extends StatefulWidget {
  const _SearchBody();
  @override
  State<_SearchBody> createState() => _SearchBodyState();
}

class _SearchBodyState extends State<_SearchBody> {
  final _ctrl = TextEditingController();
  String _q = '';

  List<Map<String, String>> get _hits {
    final allWords = dictionaryWords.toList()..sort((a, b) => a.word.toLowerCase().compareTo(b.word.toLowerCase()));
    if (_q.isEmpty) {
      return allWords.map((w) => {
        'word': w.word,
        'meaning': w.bagoboWord.isNotEmpty ? w.bagoboWord : w.tagalog,
        'ex': w.exampleSentence.isNotEmpty ? w.exampleSentence : w.description,
      }).toList();
    }
    final words = searchWords(_q);
    return words.map((w) => {
      'word': w.word,
      'meaning': w.bagoboWord.isNotEmpty ? w.bagoboWord : w.tagalog,
      'ex': w.exampleSentence.isNotEmpty ? w.exampleSentence : w.description,
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (_, isDark, __) {
        final t = T(isDark);
        return ColoredBox(
          color: t.bg,
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Container(
                decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: t.border)),
                child: TextField(
                  controller: _ctrl,
                  style: TextStyle(color: t.text),
                  decoration: InputDecoration(
                    hintText: 'Search Bagobo words…',
                    hintStyle: TextStyle(color: t.sub, fontSize: 14),
                    prefixIcon: Icon(Icons.search_rounded, color: t.accent, size: 22),
                    suffixIcon: _q.isNotEmpty ? IconButton(
                      icon: Icon(Icons.clear_rounded, color: t.sub, size: 18),
                      onPressed: () { _ctrl.clear(); setState(() => _q = ''); },
                    ) : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
                  ),
                  onChanged: (v) => setState(() => _q = v),
                ),
              ),
            ),
            Expanded(child: _hits.isEmpty
                ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.sentiment_dissatisfied_rounded, size: 56, color: t.dotOff),
                    const SizedBox(height: 12),
                    Text('No results for "$_q"', style: TextStyle(color: t.sub, fontSize: 15)),
                  ]))
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
                    itemCount: _hits.length,
                    separatorBuilder: (_, __) => Divider(color: t.divider, height: 1),
                    itemBuilder: (_, i) {
                      final w = _hits[i];
                      return GestureDetector(
                        onTap: () {
                          final fullWord = dictionaryWords.firstWhere(
                            (dw) => dw.word.toLowerCase() == w['word']!.toLowerCase(),
                            orElse: () => dictionaryWords.first,
                          );
                          HistoryService().addToHistory(fullWord.id);
                          _showWordDetail(context, fullWord, t);
                        },
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(vertical: 8),
                          title: Text(w['word']!, style: TextStyle(fontWeight: FontWeight.bold, color: t.text, fontSize: 17)),
                          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const SizedBox(height: 3),
                            Text(w['meaning']!, style: TextStyle(color: t.accent, fontWeight: FontWeight.w500, fontSize: 13)),
                            const SizedBox(height: 2),
                            Text(w['ex']!, style: TextStyle(color: t.sub, fontSize: 12, fontStyle: FontStyle.italic)),
                          ]),
                          trailing: Icon(Icons.arrow_forward_ios_rounded, color: t.sub, size: 16),
                        ),
                      );
                    },
                  ),
            ),
          ]),
        );
      },
    );
  }

  void _showWordDetail(BuildContext context, DictionaryWord word, T t) {
    showModalBottomSheet(
      context: context,
      backgroundColor: t.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        maxChildSize: 0.85,
        minChildSize: 0.3,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: t.border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 16),
            Text(word.word, style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: t.text)),
            const SizedBox(height: 4),
            if (word.pronunciation.isNotEmpty)
              Text(word.pronunciation, style: TextStyle(fontSize: 14, color: t.sub, fontStyle: FontStyle.italic)),
            const SizedBox(height: 16),
            if (word.bagoboWord.isNotEmpty) _detailRow('Bagobo', word.bagoboWord, t),
            if (word.tagalog.isNotEmpty) _detailRow('Tagalog', word.tagalog, t),
            if (word.bisaya.isNotEmpty) _detailRow('Bisaya', word.bisaya, t),
            if (word.partOfSpeech.isNotEmpty) _detailRow('Type', word.partOfSpeech, t),
            if (word.category.isNotEmpty) _detailRow('Category', word.category, t),
            if (word.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Description', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.sub)),
              const SizedBox(height: 6),
              Text(word.description, style: TextStyle(fontSize: 15, color: t.text, height: 1.4)),
            ],
            if (word.exampleSentence.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Example', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.sub)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: t.accent.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                child: Text(word.exampleSentence, style: TextStyle(fontSize: 14, color: t.accent, fontStyle: FontStyle.italic, height: 1.4)),
              ),
            ],
            if (word.synonyms.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text('Synonyms', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.sub)),
              const SizedBox(height: 6),
              Wrap(spacing: 8, runSpacing: 8, children: word.synonyms.map((s) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: t.chip, borderRadius: BorderRadius.circular(20)),
                child: Text(s, style: const TextStyle(color: Colors.white, fontSize: 12)),
              )).toList()),
            ],
            const SizedBox(height: 24),
          ]),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, T t) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        SizedBox(width: 80, child: Text(label, style: TextStyle(fontSize: 13, color: t.sub))),
        Expanded(child: Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: t.text))),
      ]),
    );
  }
}

enum Lang { english, bisaya, tagalog, bagobo }

extension LangExt on Lang {
  String get label {
    switch (this) {
      case Lang.english: return 'English';
      case Lang.bisaya: return 'Bisaya';
      case Lang.tagalog: return 'Tagalog';
      case Lang.bagobo: return 'Bagobo';
    }
  }
  String get flag {
    switch (this) {
      case Lang.english: return 'EN';
      case Lang.bisaya: return 'BI';
      case Lang.tagalog: return 'TL';
      case Lang.bagobo: return 'BG';
    }
  }
}

Language _mapLangToTranslationService(Lang l) {
  switch (l) {
    case Lang.english: return Language.english;
    case Lang.bisaya: return Language.bisaya;
    case Lang.tagalog: return Language.tagalog;
    case Lang.bagobo: return Language.bagobo;
  }
}

List<DictionaryWord> _getRandomWords(int count) {
  final shuffled = List<DictionaryWord>.from(dictionaryWords)..shuffle();
  return shuffled.take(count).where((w) => w.bagoboWord.isNotEmpty).toList();
}

class _TranslateBody extends StatefulWidget {
  const _TranslateBody();
  @override
  State<_TranslateBody> createState() => _TranslateBodyState();
}

class _TranslateBodyState extends State<_TranslateBody> {
  final _ctrl = TextEditingController();
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  final Debouncer _debouncer = Debouncer(milliseconds: 1000);

  String _fromLanguage = 'English';
  String _toLanguage = 'Bagobo';
  String _result = '';
  bool _isLoading = false;
  bool _speechEnabled = false;
  bool _isListening = false;
  bool _isDebouncing = false;

  final List<String> _languages = ['English', 'Bagobo', 'Tagalog', 'Bisaya'];

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
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    if (mounted) setState(() {});
  }

  void _startListening() async {
    if (_speechEnabled) {
      await _speechToText.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _ctrl.text = result.recognizedWords;
              _result = '';
            });
          }
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      );
      if (mounted) setState(() => _isListening = true);
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    if (mounted) setState(() => _isListening = false);
  }

  void _swap() {
    setState(() {
      final temp = _fromLanguage;
      _fromLanguage = _toLanguage;
      _toLanguage = temp;
      _result = '';
    });
  }

  Future<void> _translate() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;

    if (_isDebouncing) return; // Prevent multiple clicks

    setState(() {
      _isLoading = true;
      _isDebouncing = true;
      _result = '';
    });

    try {
      final result = await _translateWithGemini(text, _fromLanguage, _toLanguage);
      if (mounted) {
        setState(() {
          _result = result;
          _isLoading = false;
          _isDebouncing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _result = 'Error: ${e.toString()}';
          _isLoading = false;
          _isDebouncing = false;
        });
      }
    }
  }

  // Debounced translate - waits 1 second after user stops typing
  void _onTextChanged(String text) {
    if (text.trim().isEmpty) {
      setState(() {
        _result = '';
        _isDebouncing = false;
      });
      return;
    }
    
    _debouncer.run(() {
      _translate();
    });
  }

  Future<String> _translateWithGemini(String text, String from, String to) async {
    final service = GeminiCorrectionService();
    final result = await service.translateWord(text, from, to);
    
    if (result != null) {
      return result;
    }
    
    return service.getLastError() ?? 'Translation failed';
  }

  String _getLanguageName(String code) {
    switch (code.toLowerCase()) {
      case 'bagobo':
        return 'Bagobo (Bagobo-Tagabawa)';
      case 'english':
        return 'English';
      case 'tagalog':
        return 'Tagalog';
      case 'bisaya':
        return 'Bisaya';
      default:
        return code;
    }
  }

  String _getLanguageCode(String name) {
    switch (name.toLowerCase()) {
      case 'bagobo':
        return 'BG';
      case 'english':
        return 'EN';
      case 'tagalog':
        return 'TL';
      case 'bisaya':
        return 'BI';
      default:
        return 'EN';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = darkModeNotifier.value;
    final bg = isDark ? const Color(0xFF13100D) : const Color(0xFFFAF6F0);
    final surface = isDark ? const Color(0xFF2A2420) : Colors.white;
    final text = isDark ? const Color(0xFFF5F0EA) : const Color(0xFF1A1108);
    final sub = isDark ? const Color(0xFFA89B8C) : const Color(0xFF5C4F3D);
    final accent = const Color(0xFFB85C38);

    return Scaffold(
      backgroundColor: bg,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Title
            Text(
              'Translate',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: text,
              ),
            ),
            const SizedBox(height: 20),

            // Language Selection
            Row(
              children: [
                Expanded(child: _buildLanguageDropdown(_fromLanguage, (v) => setState(() => _fromLanguage = v!), surface, text, sub, isDark)),
                IconButton(
                  onPressed: _swap,
                  icon: Icon(Icons.swap_horiz, color: accent),
                  iconSize: 32,
                ),
                Expanded(child: _buildLanguageDropdown(_toLanguage, (v) => setState(() => _toLanguage = v!), surface, text, sub, isDark)),
              ],
            ),
            const SizedBox(height: 20),

            // Input Field
            Container(
              decoration: BoxDecoration(
                color: surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF3A332D) : const Color(0xFFE8DDD0)),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _ctrl,
                    maxLines: 3,
                    style: TextStyle(color: text, fontSize: 18),
                    decoration: InputDecoration(
                      hintText: 'Enter text to translate...',
                      hintStyle: TextStyle(color: sub),
                      border: InputBorder.none,
                    ),
                    onChanged: _onTextChanged,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getLanguageCode(_fromLanguage),
                        style: TextStyle(color: sub),
                      ),
                      Row(
                        children: [
                          if (_isListening)
                            IconButton(
                              onPressed: _stopListening,
                              icon: const Icon(Icons.stop, color: Colors.red),
                            )
                          else
                            IconButton(
                              onPressed: _speechEnabled ? _startListening : null,
                              icon: Icon(Icons.mic, color: _speechEnabled ? accent : sub),
                            ),
                          if (_ctrl.text.isNotEmpty)
                            IconButton(
                              onPressed: () {
                                _ctrl.clear();
                                setState(() => _result = '');
                              },
                              icon: Icon(Icons.clear, color: sub),
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Translate Button
            GestureDetector(
              onTap: _isLoading ? null : _translate,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.3), blurRadius: 10, offset: const Offset(0, 3))],
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text(
                          'Translate',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Result
            if (_result.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          _getLanguageCode(_toLanguage),
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                        ),
                        IconButton(
                          onPressed: () => _speak(_result),
                          icon: Icon(Icons.volume_up, color: Colors.white.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      _result,
                      style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 30),

            // Sample Words
            Text('Try these words', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: sub)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: ['hello', 'thank you', 'goodbye', 'good morning', 'how are you']
                  .map((word) => GestureDetector(
                        onTap: () {
                          _ctrl.text = word;
                          _fromLanguage = 'English';
                          _toLanguage = 'Bagobo';
                          _translate();
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: isDark ? const Color(0xFF3A332D) : const Color(0xFFE8DDD0)),
                          ),
                          child: Text(word, style: TextStyle(color: accent)),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageDropdown(String value, ValueChanged<String> onChanged, Color surface, Color text, Color sub, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: isDark ? const Color(0xFF3A332D) : const Color(0xFFE8DDD0)),
      ),
      child: DropdownButton<String>(
        value: value,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: surface,
        style: TextStyle(color: text),
        items: _languages
            .map((lang) => DropdownMenuItem(value: lang, child: Text(lang)))
            .toList(),
        onChanged: (v) => onChanged(v!),
      ),
    );
  }
}

class _LangPicker extends StatelessWidget {
  final Lang selected;
  final Lang excluded;
  final String label;
  final ValueChanged<Lang> onSelect;
  final T t;

  const _LangPicker({required this.selected, required this.excluded, required this.label, required this.onSelect, required this.t});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: t.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: t.border),
        ),
        child: Row(children: [
          Text(selected.flag, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: TextStyle(fontSize: 10, color: t.sub)),
            Text(selected.label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: t.text)),
          ])),
          Icon(Icons.keyboard_arrow_down_rounded, color: t.sub, size: 18),
        ]),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    final isDark = darkModeNotifier.value;
    final tt = T(isDark);
    showModalBottomSheet(
      context: context,
      backgroundColor: tt.surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 8),
          Container(width: 36, height: 4, decoration: BoxDecoration(color: tt.border, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 14),
          Text('Select $label language', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: tt.text)),
          const SizedBox(height: 12),
          ...Lang.values.map((l) {
            final isSelected = l == selected;
            final isExcluded = l == excluded;
            return ListTile(
              leading: Text(l.flag, style: const TextStyle(fontSize: 22)),
              title: Text(l.label, style: TextStyle(
                color: isExcluded ? tt.sub : tt.text,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              )),
              trailing: isSelected ? Icon(Icons.check_rounded, color: tt.accent) : null,
              subtitle: isExcluded ? Text('Already selected', style: TextStyle(fontSize: 11, color: tt.sub)) : null,
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

class _GamesBody extends StatefulWidget {
  const _GamesBody();
  @override
  State<_GamesBody> createState() => _GamesBodyState();
}

class _GamesBodyState extends State<_GamesBody> {
  int? _activeGame;

  static const _gameList = [
    {'id': 0, 'title': 'Word Quiz', 'desc': 'Pick the correct English meaning', 'icon': Icons.psychology_rounded, 'color': 0xFF6B2A0E},
    {'id': 1, 'title': 'Reverse Quiz', 'desc': 'Guess Bagobo from English', 'icon': Icons.swap_horiz_rounded, 'color': 0xFF185FA5},
    {'id': 2, 'title': 'True or False', 'desc': 'Is this translation correct?', 'icon': Icons.check_circle_outline_rounded, 'color': 0xFF7A3018},
    {'id': 3, 'title': 'Word Match', 'desc': 'Match words to meanings', 'icon': Icons.compare_arrows_rounded, 'color': 0xFF5A3A8A},
    {'id': 4, 'title': 'Spelling Bee', 'desc': 'Type the correct Bagobo word', 'icon': Icons.spellcheck_rounded, 'color': 0xFF8A5A00},
  ];

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (_, isDark, __) {
        final t = T(isDark);
        if (_activeGame != null) return _buildGame(_activeGame!, t);
        return ColoredBox(
          color: t.bg,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              Text('Choose a Game', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: t.text)),
              const SizedBox(height: 4),
              Text('All games use the Bagobo Tagabawa dictionary', style: TextStyle(fontSize: 13, color: t.sub)),
              const SizedBox(height: 16),
              ...(_gameList.map((g) => GestureDetector(
                onTap: () => setState(() => _activeGame = g['id'] as int),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: t.border)),
                  child: Row(children: [
                    Container(width: 52, height: 52, decoration: BoxDecoration(color: Color(g['color'] as int).withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
                      child: Center(child: Icon(g['icon'] as IconData, size: 26, color: Color(g['color'] as int)))),
                    const SizedBox(width: 14),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(g['title'] as String, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: t.text)),
                      const SizedBox(height: 3),
                      Text(g['desc'] as String, style: TextStyle(fontSize: 12, color: t.sub)),
                    ])),
                    Icon(Icons.chevron_right_rounded, color: t.sub),
                  ]),
                ),
              ))),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGame(int id, T t) {
    void back() => setState(() => _activeGame = null);
    switch (id) {
      case 0: return _WordQuizGame(t: t, onBack: back);
      case 1: return _ReverseQuizGame(t: t, onBack: back);
      case 2: return _TrueFalseGame(t: t, onBack: back);
      case 3: return _WordMatchGame(t: t, onBack: back);
      case 4: return _SpellingBeeGame(t: t, onBack: back);
      default: return const SizedBox();
    }
  }
}

class _GameShell extends StatelessWidget {
  final T t; final String title; final IconData icon; final VoidCallback onBack; final Widget child;
  const _GameShell({required this.t, required this.title, required this.icon, required this.onBack, required this.child});
  @override
  Widget build(BuildContext context) => ColoredBox(color: t.bg, child: Column(children: [
    Padding(padding: const EdgeInsets.fromLTRB(8, 8, 20, 0), child: Row(children: [
      IconButton(icon: Icon(Icons.arrow_back_ios_new_rounded, color: t.text, size: 20), onPressed: onBack),
      Icon(icon, color: t.accent, size: 20),
      const SizedBox(width: 8),
      Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: t.text)),
    ])),
    Expanded(child: child),
  ]));
}

Widget _resultCard(T t, int score, int total, VoidCallback onReplay, VoidCallback onBack) {
  final pct = total > 0 ? score / total : 0.0;
  final msg = pct == 1.0 ? 'Perfect! Maayo kaayo!' : pct >= 0.7 ? 'Maayo! Keep it up!' : 'Keep studying!';
  return Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [
    Container(width: double.infinity, padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: t.card, borderRadius: BorderRadius.circular(24)),
      child: Column(children: [
        const Text('Game Over!', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Text('$score / $total', style: const TextStyle(color: Color(0xFFFFCC66), fontSize: 56, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(msg, style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14), textAlign: TextAlign.center),
      ])),
    const SizedBox(height: 20),
    Row(children: [
      Expanded(child: GestureDetector(onTap: onBack,
        child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: t.border)),
          child: Text('All Games', textAlign: TextAlign.center, style: TextStyle(color: t.text, fontWeight: FontWeight.w600))))),
      const SizedBox(width: 12),
      Expanded(child: GestureDetector(onTap: onReplay,
        child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(12)),
          child: const Text('Play Again', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600))))),
    ]),
  ])));
}

Widget _choiceBtn(T t, String label, String? picked, String correct, VoidCallback onTap) {
  Color bg = t.surface, bdr = t.border, tx = t.text;
  if (picked != null) {
    if (label == correct) { bg = const Color(0xFF1D6A3A).withOpacity(0.15); bdr = const Color(0xFF1D6A3A); tx = const Color(0xFF1D6A3A); }
    else if (label == picked) { bg = const Color(0xFF9B1C1C).withOpacity(0.12); bdr = const Color(0xFF9B1C1C); tx = const Color(0xFF9B1C1C); }
  }
  return GestureDetector(onTap: onTap, child: AnimatedContainer(duration: const Duration(milliseconds: 200), margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 18),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12), border: Border.all(color: bdr, width: 1.5)),
    child: Text(label, style: TextStyle(color: tx, fontWeight: FontWeight.w500, fontSize: 15))));
}

Widget _progressBar(T t, int cur, int total, int score) => Row(children: [
  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text('${cur + 1} / $total', style: TextStyle(color: t.sub, fontSize: 12)),
      Text('Score: $score', style: TextStyle(color: t.accent, fontSize: 12, fontWeight: FontWeight.bold)),
    ]),
    const SizedBox(height: 4),
    LinearProgressIndicator(value: (cur + 1) / total, backgroundColor: t.border, color: t.accent, borderRadius: BorderRadius.circular(4), minHeight: 5),
  ])),
]);

// Game 1: Word Quiz
class _WordQuizGame extends StatefulWidget {
  final T t; final VoidCallback onBack;
  const _WordQuizGame({required this.t, required this.onBack});
  @override State<_WordQuizGame> createState() => _WordQuizGameState();
}
class _WordQuizGameState extends State<_WordQuizGame> {
  late List<DictionaryWord> _items;
  int _cur = 0, _score = 0;
  String? _pick;
  bool _done = false;
  late List<String> _choices;

  @override void initState() { super.initState(); _setup(); }
  void _setup() {
    _items = _getRandomWords(5);
    _cur = 0; _score = 0; _pick = null; _done = false;
    _buildChoices();
  }
  void _buildChoices() {
    final correct = _items[_cur].word;
    final others = dictionaryWords.map((e) => e.word).where((e) => e != correct).toList()..shuffle();
    _choices = ([correct, ...others.take(3)])..shuffle();
  }
  void _choose(String c) {
    if (_pick != null) return;
    setState(() => _pick = c);
    if (c == _items[_cur].word) _score++;
    Future.delayed(const Duration(milliseconds: 800), () => setState(() {
      _pick = null;
      if (_cur < _items.length - 1) { _cur++; _buildChoices(); } else _done = true;
    }));
  }
  @override Widget build(BuildContext context) {
    final t = widget.t;
    if (_done) return _resultCard(t, _score, _items.length, () => setState(_setup), widget.onBack);
    final word = _items[_cur].bagoboWord.isNotEmpty ? _items[_cur].bagoboWord : _items[_cur].word;
    return _GameShell(t: t, title: 'Word Quiz', icon: Icons.psychology_rounded, onBack: widget.onBack,
      child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _progressBar(t, _cur, _items.length, _score),
        const SizedBox(height: 24),
        Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: t.card, borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
            Text('What does this mean?', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
            const SizedBox(height: 10),
            Text(word, style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 1)),
          ])),
        const SizedBox(height: 24),
        ..._choices.map((c) => _choiceBtn(t, c, _pick, _items[_cur].word, () => _choose(c))),
      ])));
  }
}

// Game 2: Reverse Quiz
class _ReverseQuizGame extends StatefulWidget {
  final T t; final VoidCallback onBack;
  const _ReverseQuizGame({required this.t, required this.onBack});
  @override State<_ReverseQuizGame> createState() => _ReverseQuizGameState();
}
class _ReverseQuizGameState extends State<_ReverseQuizGame> {
  late List<DictionaryWord> _items;
  int _cur = 0, _score = 0;
  String? _pick;
  bool _done = false;
  late List<String> _choices;

  @override void initState() { super.initState(); _setup(); }
  void _setup() {
    _items = _getRandomWords(5);
    _cur = 0; _score = 0; _pick = null; _done = false;
    _buildChoices();
  }
  void _buildChoices() {
    final correct = _items[_cur].bagoboWord.isNotEmpty ? _items[_cur].bagoboWord : _items[_cur].word;
    final others = dictionaryWords.where((e) => e.bagoboWord.isNotEmpty).map((e) => e.bagoboWord).where((e) => e != correct).toList()..shuffle();
    _choices = ([correct, ...others.take(3)])..shuffle();
  }
  void _choose(String c) {
    if (_pick != null) return;
    setState(() => _pick = c);
    final correctAnswer = _items[_cur].bagoboWord.isNotEmpty ? _items[_cur].bagoboWord : _items[_cur].word;
    if (c == correctAnswer) _score++;
    Future.delayed(const Duration(milliseconds: 800), () => setState(() {
      _pick = null;
      if (_cur < _items.length - 1) { _cur++; _buildChoices(); } else _done = true;
    }));
  }
  @override Widget build(BuildContext context) {
    final t = widget.t;
    if (_done) return _resultCard(t, _score, _items.length, () => setState(_setup), widget.onBack);
    final meaning = _items[_cur].word;
    final correctAnswer = _items[_cur].bagoboWord.isNotEmpty ? _items[_cur].bagoboWord : _items[_cur].word;
    return _GameShell(t: t, title: 'Reverse Quiz', icon: Icons.swap_horiz_rounded, onBack: widget.onBack,
      child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _progressBar(t, _cur, _items.length, _score),
        const SizedBox(height: 24),
        Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: t.card, borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
            Text('Which Bagobo word means…', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13)),
            const SizedBox(height: 10),
            Text('"$meaning"', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
          ])),
        const SizedBox(height: 24),
        ..._choices.map((c) => _choiceBtn(t, c, _pick, correctAnswer, () => _choose(c))),
      ])));
  }
}

// Game 3: True or False
class _TrueFalseGame extends StatefulWidget {
  final T t; final VoidCallback onBack;
  const _TrueFalseGame({required this.t, required this.onBack});
  @override State<_TrueFalseGame> createState() => _TrueFalseGameState();
}
class _TrueFalseGameState extends State<_TrueFalseGame> {
  late List<Map<String, dynamic>> _items;
  int _cur = 0, _score = 0;
  bool? _pick;
  bool _done = false;

  @override void initState() { super.initState(); _setup(); }
  void _setup() {
    final list = <Map<String, dynamic>>[];
    final shuffled = _getRandomWords(5);
    for (final entry in shuffled) {
      final isTrue = list.length % 2 == 0;
      if (isTrue) {
        list.add({'bagobo': entry.bagoboWord.isNotEmpty ? entry.bagoboWord : entry.word, 'shown': entry.word, 'answer': true});
      } else {
        final wrong = dictionaryWords.where((e) => e.word != entry.word).toList()..shuffle();
        list.add({'bagobo': entry.bagoboWord.isNotEmpty ? entry.bagoboWord : entry.word, 'shown': wrong.first.word, 'answer': false});
      }
    }
    list.shuffle();
    _items = list; _cur = 0; _score = 0; _pick = null; _done = false;
  }
  void _choose(bool v) {
    if (_pick != null) return;
    setState(() => _pick = v);
    if (v == _items[_cur]['answer']) _score++;
    Future.delayed(const Duration(milliseconds: 800), () => setState(() {
      _pick = null;
      if (_cur < _items.length - 1) _cur++; else _done = true;
    }));
  }
  @override Widget build(BuildContext context) {
    final t = widget.t;
    if (_done) return _resultCard(t, _score, _items.length, () => setState(_setup), widget.onBack);
    final item = _items[_cur];
    final correct = item['answer'] as bool;
    return _GameShell(t: t, title: 'True or False', icon: Icons.check_circle_outline_rounded, onBack: widget.onBack,
      child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _progressBar(t, _cur, _items.length, _score),
        const SizedBox(height: 24),
        Container(padding: const EdgeInsets.all(28), decoration: BoxDecoration(color: t.card, borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
            Text('Is this translation correct?', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
            const SizedBox(height: 16),
            Text(item['bagobo'] as String, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('= "${item['shown']}"', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 18, fontStyle: FontStyle.italic)),
          ])),
        const SizedBox(height: 32),
        Row(children: [
          Expanded(child: GestureDetector(onTap: () => _choose(true), child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 20), decoration: BoxDecoration(color: _pick == null ? t.surface : correct ? const Color(0xFF1D6A3A).withOpacity(0.15) : const Color(0xFF9B1C1C).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14), border: Border.all(color: _pick == null ? t.border : correct ? const Color(0xFF1D6A3A) : const Color(0xFF9B1C1C), width: 2)),
            child: Column(children: [Icon(Icons.check_circle_rounded, size: 28, color: _pick == null ? t.text : correct ? const Color(0xFF1D6A3A) : const Color(0xFF9B1C1C)), const SizedBox(height: 6),
              Text('TRUE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _pick == null ? t.text : correct ? const Color(0xFF1D6A3A) : const Color(0xFF9B1C1C)))])))),
          const SizedBox(width: 14),
          Expanded(child: GestureDetector(onTap: () => _choose(false), child: AnimatedContainer(duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 20), decoration: BoxDecoration(color: _pick == null ? t.surface : !correct ? const Color(0xFF1D6A3A).withOpacity(0.15) : const Color(0xFF9B1C1C).withOpacity(0.12),
              borderRadius: BorderRadius.circular(14), border: Border.all(color: _pick == null ? t.border : !correct ? const Color(0xFF1D6A3A) : const Color(0xFF9B1C1C), width: 2)),
            child: Column(children: [Icon(Icons.cancel_rounded, size: 28, color: _pick == null ? t.text : !correct ? const Color(0xFF1D6A3A) : const Color(0xFF9B1C1C)), const SizedBox(height: 6),
              Text('FALSE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: _pick == null ? t.text : !correct ? const Color(0xFF1D6A3A) : const Color(0xFF9B1C1C)))])))),
        ]),
      ])));
  }
}

// Game 4: Word Match
class _WordMatchGame extends StatefulWidget {
  final T t; final VoidCallback onBack;
  const _WordMatchGame({required this.t, required this.onBack});
  @override State<_WordMatchGame> createState() => _WordMatchGameState();
}
class _WordMatchGameState extends State<_WordMatchGame> {
  late List<DictionaryWord> _pairs;
  late List<String> _leftCol, _rightCol;
  String? _selLeft, _selRight;
  final Set<String> _matched = {};
  int _score = 0;
  bool _done = false;

  @override void initState() { super.initState(); _setup(); }
  void _setup() {
    _pairs = _getRandomWords(5);
    _leftCol = _pairs.map((e) => e.bagoboWord.isNotEmpty ? e.bagoboWord : e.word).toList()..shuffle();
    _rightCol = _pairs.map((e) => e.word).toList()..shuffle();
    _selLeft = null; _selRight = null; _matched.clear(); _score = 0; _done = false;
  }
  void _tapLeft(String w) {
    if (_matched.contains(w)) return;
    setState(() { _selLeft = w; _checkMatch(); });
  }
  void _tapRight(String w) {
    if (_matched.any((m) => _pairs.firstWhere((p) => (p.bagoboWord.isNotEmpty ? p.bagoboWord : p.word) == m, orElse: () => DictionaryWord(id: '', word: '', bagoboWord: '', tagalog: '', bisaya: '', partOfSpeech: '', description: '', synonyms: [], exampleSentence: '', category: '', pronunciation: '')).word == w)) return;
    setState(() { _selRight = w; _checkMatch(); });
  }
  void _checkMatch() {
    if (_selLeft == null || _selRight == null) return;
    final entry = _pairs.firstWhere((p) => (p.bagoboWord.isNotEmpty ? p.bagoboWord : p.word) == _selLeft, orElse: () => DictionaryWord(id: '', word: '', bagoboWord: '', tagalog: '', bisaya: '', partOfSpeech: '', description: '', synonyms: [], exampleSentence: '', category: '', pronunciation: ''));
    if (entry.word == _selRight) {
      _matched.add(_selLeft!); _score++;
      if (_matched.length == _pairs.length) _done = true;
    }
    Future.delayed(const Duration(milliseconds: 500), () => setState(() { _selLeft = null; _selRight = null; }));
  }
  @override Widget build(BuildContext context) {
    final t = widget.t;
    if (_done) return _resultCard(t, _score, _pairs.length, () => setState(_setup), widget.onBack);
    return _GameShell(t: t, title: 'Word Match', icon: Icons.compare_arrows_rounded, onBack: widget.onBack,
      child: Padding(padding: const EdgeInsets.fromLTRB(20, 8, 20, 20), child: Column(children: [
        Text('Match Bagobo to English', style: TextStyle(fontSize: 13, color: t.sub), textAlign: TextAlign.center),
        const SizedBox(height: 6),
        Text('Score: $_score / ${_pairs.length}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: t.accent)),
        const SizedBox(height: 20),
        Expanded(child: Row(children: [
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _leftCol.map((w) {
              final isMatched = _matched.contains(w);
              final isSel = _selLeft == w;
              return GestureDetector(onTap: () => _tapLeft(w), child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                decoration: BoxDecoration(color: isMatched ? const Color(0xFF1D6A3A).withOpacity(0.15) : isSel ? t.accent.withOpacity(0.15) : t.surface,
                  borderRadius: BorderRadius.circular(12), border: Border.all(color: isMatched ? const Color(0xFF1D6A3A) : isSel ? t.accent : t.border, width: 1.5)),
                child: Text(w, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isMatched ? const Color(0xFF1D6A3A) : isSel ? t.accent : t.text))));
            }).toList())),
          const SizedBox(width: 10),
          Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: List.generate(_pairs.length, (_) => Icon(Icons.arrow_forward_rounded, color: t.border, size: 16))),
          const SizedBox(width: 10),
          Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _rightCol.map((w) {
              final isMatched = _matched.any((m) => _pairs.firstWhere((p) => (p.bagoboWord.isNotEmpty ? p.bagoboWord : p.word) == m, orElse: () => DictionaryWord(id: '', word: '', bagoboWord: '', tagalog: '', bisaya: '', partOfSpeech: '', description: '', synonyms: [], exampleSentence: '', category: '', pronunciation: '')).word == w);
              final isSel = _selRight == w;
              return GestureDetector(onTap: () => _tapRight(w), child: AnimatedContainer(duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
                decoration: BoxDecoration(color: isMatched ? const Color(0xFF1D6A3A).withOpacity(0.15) : isSel ? t.accent.withOpacity(0.15) : t.surface,
                  borderRadius: BorderRadius.circular(12), border: Border.all(color: isMatched ? const Color(0xFF1D6A3A) : isSel ? t.accent : t.border, width: 1.5)),
                child: Text(w, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: isMatched ? const Color(0xFF1D6A3A) : isSel ? t.accent : t.text))));
            }).toList())),
        ])),
      ])));
  }
}

// Game 5: Spelling Bee
class _SpellingBeeGame extends StatefulWidget {
  final T t; final VoidCallback onBack;
  const _SpellingBeeGame({required this.t, required this.onBack});
  @override State<_SpellingBeeGame> createState() => _SpellingBeeGameState();
}
class _SpellingBeeGameState extends State<_SpellingBeeGame> {
  late List<DictionaryWord> _items;
  final _ctrl = TextEditingController();
  int _cur = 0, _score = 0;
  bool _done = false, _checked = false, _correct = false;

  @override void initState() { super.initState(); _setup(); }
  @override void dispose() { _ctrl.dispose(); super.dispose(); }
  void _setup() {
    _items = _getRandomWords(5);
    _cur = 0; _score = 0; _done = false; _checked = false; _correct = false; _ctrl.clear();
  }
  void _check() {
    final answer = _ctrl.text.trim().toLowerCase();
    final correct = (_items[_cur].bagoboWord.isNotEmpty ? _items[_cur].bagoboWord : _items[_cur].word).toLowerCase();
    final isRight = answer == correct;
    setState(() { _checked = true; _correct = isRight; if (isRight) _score++; });
  }
  void _next() {
    setState(() { _checked = false; _correct = false; _ctrl.clear(); if (_cur < _items.length - 1) _cur++; else _done = true; });
  }
  @override Widget build(BuildContext context) {
    final t = widget.t;
    if (_done) return _resultCard(t, _score, _items.length, () => setState(_setup), widget.onBack);
    final item = _items[_cur];
    final bagoboWord = item.bagoboWord.isNotEmpty ? item.bagoboWord : item.word;
    return _GameShell(t: t, title: 'Spelling Bee', icon: Icons.spellcheck_rounded, onBack: widget.onBack,
      child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _progressBar(t, _cur, _items.length, _score),
        const SizedBox(height: 24),
        Container(padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: t.card, borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
            Text('Type the Bagobo word for:', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 13)),
            const SizedBox(height: 12),
            Text('"${item.word}"', style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text('(${item.tagalog} in Tagalog)', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12, fontStyle: FontStyle.italic)),
          ])),
        const SizedBox(height: 20),
        Container(decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _checked ? (_correct ? const Color(0xFF1D6A3A) : const Color(0xFF9B1C1C)) : t.border, width: 1.5)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: TextField(controller: _ctrl, style: TextStyle(color: t.text, fontSize: 20, fontWeight: FontWeight.w600), textAlign: TextAlign.center, enabled: !_checked,
            decoration: InputDecoration(hintText: 'Type here…', hintStyle: TextStyle(color: t.sub), border: InputBorder.none),
            onSubmitted: (_) => _check())),
        if (_checked) ...[
          const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: _correct ? const Color(0xFF1D6A3A).withOpacity(0.12) : const Color(0xFF9B1C1C).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: Text(_correct ? 'Tama! "$bagoboWord" is correct!' : 'The answer is "$bagoboWord"',
              style: TextStyle(color: _correct ? const Color(0xFF1D6A3A) : const Color(0xFF9B1C1C), fontWeight: FontWeight.w600), textAlign: TextAlign.center)),
        ],
        const SizedBox(height: 16),
        if (!_checked)
          GestureDetector(onTap: _check, child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(14)),
            child: const Text('Check', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15))))
        else
          GestureDetector(onTap: _next, child: Container(padding: const EdgeInsets.symmetric(vertical: 14), decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(14)),
            child: Text(_cur < _items.length - 1 ? 'Next →' : 'See Results', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)))),
      ])));
  }
}

class _SavedBody extends StatefulWidget {
  const _SavedBody();
  @override
  State<_SavedBody> createState() => _SavedBodyState();
}

class _SavedBodyState extends State<_SavedBody> {
  final BookmarkService _bookmarkService = BookmarkService();

  List<DictionaryWord> get _savedWords {
    return _bookmarkService.bookmarkedWordIds
        .map((id) {
          try {
            return dictionaryWords.firstWhere((w) => w.id == id);
          } catch (_) {
            return null;
          }
        })
        .whereType<DictionaryWord>()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (_, isDark, __) {
        final t = T(isDark);
        return ListenableBuilder(
          listenable: _bookmarkService,
          builder: (context, _) {
            final saved = _savedWords;
            return ColoredBox(
              color: t.bg,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Quick Access', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.text)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildActionCard(context, t, Icons.history_rounded, 'History', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())))),
                        const SizedBox(width: 12),
                        Expanded(child: _buildActionCard(context, t, Icons.lightbulb_outline_rounded, 'Suggest', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())))),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildShareCard(context, t)),
                        const SizedBox(width: 12),
                        Expanded(child: _buildActionCard(context, t, Icons.info_outline_rounded, 'About', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutScreen())))),
                      ],
                    ),
                    const SizedBox(height: 28),
                    Text('Saved Words', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: t.text)),
                    const SizedBox(height: 12),
                    if (saved.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: t.border)),
                        child: Column(
                          children: [
                            Icon(Icons.bookmark_border_rounded, size: 40, color: t.sub),
                            const SizedBox(height: 8),
                            Text('No saved words yet', style: TextStyle(color: t.sub, fontSize: 15)),
                          ],
                        ),
                      )
                    else
                      ...saved.map((w) => Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(12), border: Border.all(color: t.border)),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: t.chip, borderRadius: BorderRadius.circular(8)),
                              child: const Icon(Icons.bookmark_rounded, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(w.word, style: TextStyle(fontWeight: FontWeight.bold, color: t.text, fontSize: 15)),
                                  Text(w.bagoboWord.isNotEmpty ? w.bagoboWord : w.tagalog, style: TextStyle(color: t.accent, fontSize: 13)),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _bookmarkService.toggleBookmark(w.id),
                              child: Icon(Icons.bookmark_rounded, color: t.accent, size: 20),
                            ),
                          ],
                        ),
                      )),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildActionCard(BuildContext context, T t, IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: t.border)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.text)),
          ],
        ),
      ),
    );
  }

  Widget _buildShareCard(BuildContext context, T t) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(const ClipboardData(text: 'Check out Banualecto - Bagobo-Tagabawa Dictionary app!'));
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Copied to clipboard!'), backgroundColor: t.accent));
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: t.border)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: t.accent, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.share_rounded, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text('Share', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: t.text)),
          ],
        ),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final T t;
  final IconData icon;
  final String title, tag;
  final int mins;
  final Color tagColor;

  const _ArticleCard({required this.t, required this.icon, required this.title, required this.tag, required this.mins, required this.tagColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 190,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(18), border: Border.all(color: t.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(color: tagColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(20)),
            child: Text(tag, style: TextStyle(color: tagColor, fontSize: 11, fontWeight: FontWeight.w600)),
          ),
          Text('$mins min', style: TextStyle(fontSize: 11, color: t.sub)),
        ]),
        const SizedBox(height: 12),
        Icon(icon, size: 28, color: t.accent),
        const SizedBox(height: 8),
        Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: t.text, height: 1.35), maxLines: 3, overflow: TextOverflow.ellipsis),
      ]),
    );
  }
}

class _TrendingRow extends StatelessWidget {
  final T t;
  final int rank;
  final String word, meaning;
  final int views;

  const _TrendingRow({required this.t, required this.rank, required this.word, required this.meaning, required this.views});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(14), border: Border.all(color: t.border)),
      child: Row(children: [
        SizedBox(width: 28, child: Text('#$rank', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: t.accent))),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(word, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: t.text)),
          const SizedBox(height: 2),
          Text(meaning, style: TextStyle(fontSize: 12, color: t.sub)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(color: t.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.visibility_rounded, size: 12, color: t.accent),
              const SizedBox(width: 4),
              Text('$views', style: TextStyle(fontSize: 11, color: t.accent, fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ]),
    );
  }
}

class _Toggle extends StatelessWidget {
  final T t;
  const _Toggle({required this.t});
  @override
  Widget build(BuildContext context) {
    final isDark = t.dark;
    return GestureDetector(
      onTap: () => darkModeNotifier.value = !isDark,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 58, height: 32,
        decoration: BoxDecoration(
          color: t.togTrack,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: t.togBorder),
        ),
        child: Stack(children: [
          Positioned(left: 8, top: 0, bottom: 0, child: Center(
            child: Icon(Icons.nightlight_round, size: 13, color: isDark ? const Color(0xFFFFCC66) : Colors.transparent),
          )),
          Positioned(right: 8, top: 0, bottom: 0, child: Center(
            child: Icon(Icons.wb_sunny_rounded, size: 13, color: isDark ? Colors.transparent : const Color(0xFF6B2A0E)),
          )),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            left: isDark ? 28 : 2, top: 2,
            child: Container(
              width: 28, height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle, color: t.thumb,
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 4, offset: const Offset(0, 1))],
              ),
              child: Icon(isDark ? Icons.nightlight_round : Icons.wb_sunny_rounded, size: 15, color: t.thumbFg),
            ),
          ),
        ]),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final IconData icon;
  final String label;
  final T t;
  final VoidCallback onTap;
  const _Chip({required this.icon, required this.label, required this.t, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(color: t.surface, borderRadius: BorderRadius.circular(30), border: Border.all(color: t.border)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 16, color: t.accent),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13, color: t.text, fontWeight: FontWeight.w500)),
      ]),
    ),
  );
}

class _BottomNav extends StatefulWidget {
  final int idx;
  final ValueChanged<int> onTap;
  final T t;

  const _BottomNav({required this.idx, required this.onTap, required this.t});

  @override
  State<_BottomNav> createState() => _BottomNavState();
}

class _BottomNavState extends State<_BottomNav> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnim;

  static const _labels = ['Home', 'Search', 'Translate', 'Games', 'About'];
  static const _icons = [
    Icons.home_rounded, Icons.search_rounded, Icons.translate_rounded,
    Icons.extension_rounded, Icons.info_outline_rounded,
  ];
  static const int _c = 2;
  static const double _fab = 56;
  static const double _barH = 68;
  static const double _notchR = 36;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pad = MediaQuery.of(context).padding.bottom.clamp(0.0, 34.0);
    final w = MediaQuery.of(context).size.width;
    final cx = w / 2;
    final total = _barH + _fab / 2 + pad;

    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, _floatAnim.value),
        child: SizedBox(
          height: total + 8,
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.bottomCenter,
            children: [
              Positioned(
                bottom: 0, left: 0, right: 0,
                height: _barH + pad,
                child: CustomPaint(painter: _Painter(color: widget.t.nav, cx: cx, r: _notchR, dark: widget.t.dark)),
              ),
              ...List.generate(5, (i) {
                if (i == _c) return const SizedBox.shrink();
                final slotW = (w - (_notchR * 2 + 24)) / 4;
                final itemCx = i < _c
                    ? slotW * i + slotW / 2
                    : cx + _notchR + 12 + slotW * (i - _c - 1) + slotW / 2;
                final on = widget.idx == i;
                return Positioned(
                  bottom: pad, left: itemCx - 36, width: 72, height: _barH,
                  child: GestureDetector(
                    onTap: () => widget.onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(_icons[i], size: 22, color: on ? widget.t.accent : widget.t.navOff),
                      const SizedBox(height: 3),
                      Text(_labels[i], style: TextStyle(fontSize: 10, color: on ? widget.t.accent : widget.t.navOff, fontWeight: on ? FontWeight.w600 : FontWeight.w400)),
                      const SizedBox(height: 2),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: on ? 16 : 0, height: 3,
                        decoration: BoxDecoration(color: widget.t.accent, borderRadius: BorderRadius.circular(2)),
                      ),
                    ]),
                  ),
                );
              }),
              Positioned(
                bottom: _barH / 2 - _fab / 2 + pad + 6,
                left: cx - _fab / 2,
                child: GestureDetector(
                  onTap: () => widget.onTap(_c),
                  child: Container(
                    width: _fab, height: _fab,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, color: widget.t.accent,
                      boxShadow: [BoxShadow(color: widget.t.accent.withValues(alpha: 0.45), blurRadius: 16, offset: const Offset(0, 4))],
                    ),
                    child: const Icon(Icons.translate_rounded, color: Colors.white, size: 24),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Painter extends CustomPainter {
  final Color color;
  final double cx, r;
  final bool dark;
  const _Painter({required this.color, required this.cx, required this.r, required this.dark});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(_path(size), Paint()
      ..color = Colors.black.withValues(alpha: dark ? 0.35 : 0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8));
    canvas.drawPath(_path(size), Paint()..color = color..style = PaintingStyle.fill);
  }

  Path _path(Size size) {
    const s = 22.0;
    return Path()
      ..moveTo(0, 0)
      ..lineTo(cx - r - s, 0)
      ..cubicTo(cx - r - s * .35, 0, cx - r, r * .45, cx - r + 5, r * .68)
      ..arcToPoint(Offset(cx + r - 5, r * .68), radius: Radius.circular(r), clockwise: false)
      ..cubicTo(cx + r, r * .45, cx + r + s * .35, 0, cx + r + s, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldRepaint(_Painter o) => o.color != color || o.cx != cx || o.r != r || o.dark != dark;
}
