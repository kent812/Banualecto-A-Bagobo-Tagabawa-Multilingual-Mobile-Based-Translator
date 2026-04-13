import '../models/word_model.dart';
import '../data/dictionary_data.dart';

enum Language {
  bagobo('Bagobo', 'BG'),
  english('English', 'EN'),
  tagalog('Tagalog', 'TL'),
  bisaya('Bisaya', 'BI');

  final String name;
  final String code;
  const Language(this.name, this.code);

  String get displayName => name;
}

class TranslationResult {
  final String originalText;
  final String translatedText;
  final Language sourceLanguage;
  final Language targetLanguage;
  final String? pronunciation;
  final String? exampleSentence;

  TranslationResult({
    required this.originalText,
    required this.translatedText,
    required this.sourceLanguage,
    required this.targetLanguage,
    this.pronunciation,
    this.exampleSentence,
  });
}

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final Map<String, Map<String, DictionaryWord>> _translationCache = {};

  void _buildCache() {
    if (_translationCache.isNotEmpty) return;
    
    for (var word in dictionaryWords) {
      // English translations
      _translationCache[word.word.toLowerCase()] ??= {};
      _translationCache[word.word.toLowerCase()]!['en'] = word;
      
      // Split bagobo words by comma and add each as a separate entry
      if (word.bagoboWord.isNotEmpty) {
        var bagoboWords = word.bagoboWord.split(',').map((w) => w.trim().toLowerCase()).where((w) => w.isNotEmpty);
        for (var bw in bagoboWords) {
          _translationCache[bw] ??= {};
          _translationCache[bw]!['bagobo'] = word;
        }
        // Also add the full phrase
        _translationCache[word.bagoboWord.toLowerCase()] ??= {};
        _translationCache[word.bagoboWord.toLowerCase()]!['bagobo'] = word;
      }
      
      // Split tagalog words by comma and add each as a separate entry
      if (word.tagalog.isNotEmpty) {
        var tagalogWords = word.tagalog.split(',').map((w) => w.trim().toLowerCase()).where((w) => w.isNotEmpty);
        for (var tw in tagalogWords) {
          _translationCache[tw] ??= {};
          _translationCache[tw]!['tagalog'] = word;
        }
        // Also add the full phrase
        _translationCache[word.tagalog.toLowerCase()] ??= {};
        _translationCache[word.tagalog.toLowerCase()]!['tagalog'] = word;
      }
      
      // Split bisaya words by comma and add each as a separate entry
      if (word.bisaya.isNotEmpty) {
        var bisayaWords = word.bisaya.split(',').map((w) => w.trim().toLowerCase()).where((w) => w.isNotEmpty);
        for (var bw in bisayaWords) {
          _translationCache[bw] ??= {};
          _translationCache[bw]!['bisaya'] = word;
        }
        // Also add the full phrase
        _translationCache[word.bisaya.toLowerCase()] ??= {};
        _translationCache[word.bisaya.toLowerCase()]!['bisaya'] = word;
      }
    }
  }

  TranslationResult translate(String text, Language source, Language target) {
    _buildCache();
    
    if (source == target) {
      return TranslationResult(
        originalText: text,
        translatedText: text,
        sourceLanguage: source,
        targetLanguage: target,
      );
    }

    final trimmedText = text.trim();
    
    if (trimmedText.isEmpty) {
      return TranslationResult(
        originalText: text,
        translatedText: '',
        sourceLanguage: source,
        targetLanguage: target,
      );
    }
    
    final result = _translateFullPhrase(trimmedText, source, target);
    if (result != null) {
      return result;
    }
    
    final singleWordResult = _translateSingleWord(trimmedText, source, target);
    if (singleWordResult != null) {
      return singleWordResult;
    }
    
    final words = trimmedText.split(RegExp(r'\s+'));
    final translatedWords = <String>[];
    int foundCount = 0;
    
    for (final word in words) {
      final wordResult = _translateSingleWord(word, source, target);
      if (wordResult != null) {
        translatedWords.add(wordResult.translatedText);
        foundCount++;
      } else {
        translatedWords.add(word);
      }
    }
    
    if (foundCount == 0) {
      return TranslationResult(
        originalText: text,
        translatedText: 'Translation not found. Try a different word or spelling.',
        sourceLanguage: source,
        targetLanguage: target,
      );
    }
    
    return TranslationResult(
      originalText: text,
      translatedText: translatedWords.join(' '),
      sourceLanguage: source,
      targetLanguage: target,
    );
  }
  
  TranslationResult? _translateFullPhrase(String text, Language source, Language target) {
    final lowerText = text.toLowerCase();
    final fullPhraseCache = _buildFullPhraseCache();
    
    final key = '${source.name.toLowerCase()}_${target.name.toLowerCase()}';
    final phraseMap = fullPhraseCache[key];
    
    if (phraseMap != null) {
      for (final phrase in phraseMap.keys) {
        if (lowerText.contains(phrase)) {
          return TranslationResult(
            originalText: text,
            translatedText: phraseMap[phrase]!,
            sourceLanguage: source,
            targetLanguage: target,
          );
        }
      }
    }
    
    return null;
  }
  
  Map<String, Map<String, String>> _buildFullPhraseCache() {
    final cache = <String, Map<String, String>>{};
    
    final phrases = [
      {'from': 'bagobo', 'to': 'english', 'phrase': 'good morning', 'trans': 'kaalam'},
      {'from': 'bagobo', 'to': 'english', 'phrase': 'good afternoon', 'trans': 'katapusan'},
      {'from': 'bagobo', 'to': 'english', 'phrase': 'good evening', 'trans': 'kaagahon'},
      {'from': 'bagobo', 'to': 'english', 'phrase': 'thank you', 'trans': 'salamat'},
      {'from': 'bagobo', 'to': 'english', 'phrase': 'how are you', 'trans': 'kumu'},
      {'from': 'bagobo', 'to': 'english', 'phrase': 'i love you', 'trans': 'gugma'},
      {'from': 'bagobo', 'to': 'english', 'phrase': 'what is your name', 'trans': 'kagang'},
      {'from': 'bagobo', 'to': 'english', 'phrase': 'my name is', 'trans': 'akong ngan'},
      {'from': 'bagobo', 'to': 'english', 'phrase': 'where are you going', 'trans': 'ninja'},
      {'from': 'bagobo', 'to': 'english', 'phrase': 'i am hungry', 'trans': 'gutom ako'},
      {'from': 'bagobo', 'to': 'english', 'phrase': 'i am tired', 'trans': 'kapoy ako'},
      {'from': 'bagobo', 'to': 'english', 'phrase': 'what is that', 'trans': 'datu'},
      {'from': 'bagobo', 'to': 'english', 'phrase': 'i dont understand', 'trans': 'dili ko kasabot'},
      {'from': 'bagobo', 'to': 'english', 'phrase': 'please help me', 'trans': 'tabangi ako'},
      {'from': 'bagobo', 'to': 'english', 'phrase': 'goodbye', 'trans': 'dayon'},
      {'from': 'bagobo', 'to': 'english', 'phrase': 'see you later', 'trans': 'kita na lang'},
      {'from': 'bagobo', 'to': 'english', 'phrase': 'yes', 'trans': 'oo'},
      {'from': 'bagobo', 'to': 'english', 'phrase': 'no', 'trans': 'dili'},
      {'from': 'bagobo', 'to': 'english', 'phrase': 'i am sorry', 'trans': 'pasayloi ako'},
      {'from': 'bagobo', 'to': 'english', 'phrase': 'excuse me', 'trans': 'tabi'},
      {'from': 'bagobo', 'to': 'english', 'phrase': 'how much is this', 'trans': 'tagpilaining'},
      {'from': 'bagobo', 'to': 'english', 'phrase': 'i want to eat', 'trans': 'kaonon ko'},
      {'from': 'bagobo', 'to': 'english', 'phrase': 'where is the bathroom', 'trans': 'ninja kasilyas'},
      {'from': 'bagobo', 'to': 'english', 'phrase': 'i need help', 'trans': 'kinahanglan ko og tabang'},
      {'from': 'tagalog', 'to': 'english', 'phrase': 'good morning', 'trans': 'magandang umaga'},
      {'from': 'tagalog', 'to': 'english', 'phrase': 'good afternoon', 'trans': 'magandang hapon'},
      {'from': 'tagalog', 'to': 'english', 'phrase': 'good evening', 'trans': 'magandang gabi'},
      {'from': 'tagalog', 'to': 'english', 'phrase': 'thank you', 'trans': 'salamat'},
      {'from': 'tagalog', 'to': 'english', 'phrase': 'how are you', 'trans': 'kumusta ka'},
      {'from': 'tagalog', 'to': 'english', 'phrase': 'i love you', 'trans': 'mahal kita'},
      {'from': 'tagalog', 'to': 'english', 'phrase': 'what is your name', 'trans': 'ano ang pangalan mo'},
      {'from': 'tagalog', 'to': 'english', 'phrase': 'my name is', 'trans': 'ang pangalan ko ay'},
      {'from': 'tagalog', 'to': 'english', 'phrase': 'where are you going', 'trans': 'saan ka pupunta'},
      {'from': 'tagalog', 'to': 'english', 'phrase': 'i am hungry', 'trans': 'gutom ako'},
      {'from': 'tagalog', 'to': 'english', 'phrase': 'i am tired', 'trans': 'pagod ako'},
      {'from': 'tagalog', 'to': 'english', 'phrase': 'what is that', 'trans': 'ano iyan'},
      {'from': 'tagalog', 'to': 'english', 'phrase': 'i dont understand', 'trans': 'hindi ko maintindihan'},
      {'from': 'tagalog', 'to': 'english', 'phrase': 'please help me', 'trans': 'tulungan mo ako'},
      {'from': 'tagalog', 'to': 'english', 'phrase': 'goodbye', 'trans': 'paalam'},
      {'from': 'tagalog', 'to': 'english', 'phrase': 'see you later', 'trans': 'hindi sa ngayon'},
      {'from': 'tagalog', 'to': 'english', 'phrase': 'yes', 'trans': 'oo'},
      {'from': 'tagalog', 'to': 'english', 'phrase': 'no', 'trans': 'hindi'},
      {'from': 'bisaya', 'to': 'english', 'phrase': 'good morning', 'trans': 'maayong buntag'},
      {'from': 'bisaya', 'to': 'english', 'phrase': 'good afternoon', 'trans': 'maayong hapon'},
      {'from': 'bisaya', 'to': 'english', 'phrase': 'good evening', 'trans': 'maayong gabii'},
      {'from': 'bisaya', 'to': 'english', 'phrase': 'thank you', 'trans': 'salamat'},
      {'from': 'bisaya', 'to': 'english', 'phrase': 'how are you', 'trans': 'kumusta ka'},
      {'from': 'bisaya', 'to': 'english', 'phrase': 'i love you', 'trans': 'gihigugma tika'},
      {'from': 'bisaya', 'to': 'english', 'phrase': 'what is your name', 'trans': 'unsa ang imong pangalan'},
      {'from': 'bisaya', 'to': 'english', 'phrase': 'my name is', 'trans': 'akong ngalan'},
      {'from': 'bisaya', 'to': 'english', 'phrase': 'where are you going', 'trans': 'asa ka kadtu'},
      {'from': 'bisaya', 'to': 'english', 'phrase': 'i am hungry', 'trans': 'giut-an ko'},
      {'from': 'bisaya', 'to': 'english', 'phrase': 'i am tired', 'trans': 'kapoyan ko'},
      {'from': 'bisaya', 'to': 'english', 'phrase': 'what is that', 'trans': 'unsa nay na'},
      {'from': 'bisaya', 'to': 'english', 'phrase': 'i dont understand', 'trans': 'dili ko kasabot'},
      {'from': 'bisaya', 'to': 'english', 'phrase': 'please help me', 'trans': 'tabangi ako'},
      {'from': 'bisaya', 'to': 'english', 'phrase': 'goodbye', 'trans': 'dayon'},
      {'from': 'bisaya', 'to': 'english', 'phrase': 'yes', 'trans': 'oo'},
      {'from': 'bisaya', 'to': 'english', 'phrase': 'no', 'trans': 'dili'},
      {'from': 'english', 'to': 'bagobo', 'phrase': 'good morning', 'trans': 'kaalam'},
      {'from': 'english', 'to': 'bagobo', 'phrase': 'good afternoon', 'trans': 'katapusan'},
      {'from': 'english', 'to': 'bagobo', 'phrase': 'good evening', 'trans': 'kaagahon'},
      {'from': 'english', 'to': 'bagobo', 'phrase': 'thank you', 'trans': 'salamat'},
      {'from': 'english', 'to': 'bagobo', 'phrase': 'how are you', 'trans': 'kumu'},
      {'from': 'english', 'to': 'bagobo', 'phrase': 'i love you', 'trans': 'gugma'},
      {'from': 'english', 'to': 'bagobo', 'phrase': 'what is your name', 'trans': 'kagang'},
      {'from': 'english', 'to': 'bagobo', 'phrase': 'goodbye', 'trans': 'dayon'},
      {'from': 'english', 'to': 'bagobo', 'phrase': 'yes', 'trans': 'oo'},
      {'from': 'english', 'to': 'bagobo', 'phrase': 'no', 'trans': 'dili'},
      {'from': 'english', 'to': 'tagalog', 'phrase': 'good morning', 'trans': 'magandang umaga'},
      {'from': 'english', 'to': 'tagalog', 'phrase': 'good afternoon', 'trans': 'magandang hapon'},
      {'from': 'english', 'to': 'tagalog', 'phrase': 'good evening', 'trans': 'magandang gabi'},
      {'from': 'english', 'to': 'tagalog', 'phrase': 'thank you', 'trans': 'salamat'},
      {'from': 'english', 'to': 'tagalog', 'phrase': 'how are you', 'trans': 'kumusta ka'},
      {'from': 'english', 'to': 'tagalog', 'phrase': 'i love you', 'trans': 'mahal kita'},
      {'from': 'english', 'to': 'tagalog', 'phrase': 'goodbye', 'trans': 'paalam'},
      {'from': 'english', 'to': 'bisaya', 'phrase': 'good morning', 'trans': 'maayong buntag'},
      {'from': 'english', 'to': 'bisaya', 'phrase': 'good afternoon', 'trans': 'maayong hapon'},
      {'from': 'english', 'to': 'bisaya', 'phrase': 'good evening', 'trans': 'maayong gabii'},
      {'from': 'english', 'to': 'bisaya', 'phrase': 'thank you', 'trans': 'salamat'},
      {'from': 'english', 'to': 'bisaya', 'phrase': 'how are you', 'trans': 'kumusta ka'},
      {'from': 'english', 'to': 'bisaya', 'phrase': 'i love you', 'trans': 'gihigugma tika'},
      {'from': 'english', 'to': 'bisaya', 'phrase': 'goodbye', 'trans': 'dayon'},
    ];
    
    for (final p in phrases) {
      final key = '${p['from']}_${p['to']}';
      cache[key] ??= {};
      cache[key]![p['phrase'] as String] = p['trans'] as String;
    }
    
    return cache;
  }

  TranslationResult? _translateSingleWord(String text, Language source, Language target) {
    final lowerText = text.toLowerCase().trim();
    if (lowerText.isEmpty) return null;
    DictionaryWord? foundWord;

    String? sourceKey;
    if (source == Language.bagobo) {
      sourceKey = 'bagobo';
    } else if (source == Language.english) {
      sourceKey = 'en';
    } else if (source == Language.tagalog) {
      sourceKey = 'tagalog';
    } else if (source == Language.bisaya) {
      sourceKey = 'bisaya';
    }

    if (sourceKey != null) {
      foundWord = _translationCache[lowerText]?[sourceKey];
    }

    if (foundWord == null && sourceKey != null) {
      foundWord = _partialMatchSearch(lowerText, sourceKey);
    }

    if (foundWord != null) {
      String translatedText = '';

      if (target == Language.bagobo) {
        translatedText = foundWord.bagoboWord.isNotEmpty ? foundWord.bagoboWord : foundWord.word;
      } else if (target == Language.english) {
        translatedText = foundWord.word;
      } else if (target == Language.tagalog) {
        translatedText = foundWord.tagalog.isNotEmpty ? foundWord.tagalog : foundWord.word;
      } else if (target == Language.bisaya) {
        translatedText = foundWord.bisaya.isNotEmpty ? foundWord.bisaya : foundWord.word;
      }

      return TranslationResult(
        originalText: text,
        translatedText: translatedText,
        sourceLanguage: source,
        targetLanguage: target,
      );
    }

    return null;
  }

  DictionaryWord? _partialMatchSearch(String query, String sourceKey) {
    for (var word in dictionaryWords) {
      String searchField = '';
      if (sourceKey == 'bagobo') {
        searchField = word.bagoboWord.toLowerCase();
      } else if (sourceKey == 'tagalog') {
        searchField = word.tagalog.toLowerCase();
      } else if (sourceKey == 'bisaya') {
        searchField = word.bisaya.toLowerCase();
      } else if (sourceKey == 'en') {
        searchField = word.word.toLowerCase();
      }
      
      if (searchField.isNotEmpty && searchField.contains(query)) {
        return word;
      }
    }
    return null;
  }

  List<DictionaryWord> getAllWords() {
    return dictionaryWords;
  }

  List<String> getCategories() {
    return categories.map((c) => c.name).toList();
  }
}
