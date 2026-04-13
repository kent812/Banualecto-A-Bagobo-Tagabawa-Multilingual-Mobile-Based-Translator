import '../models/word_model.dart';
import '../data/dictionary_data.dart';
import 'translation_service.dart';

enum SentenceType { statement, question, command, negation }

enum VerbFocus { actorFocus, patientFocus, locativeFocus }

class SentenceComponent {
  final String original;
  final String translated;
  final String role; // subject, verb, object, adverb, adjective, preposition, conjunction, pronoun
  final String? partOfSpeech;

  SentenceComponent({
    required this.original,
    required this.translated,
    required this.role,
    this.partOfSpeech,
  });
}

class SentenceTranslation {
  final String originalSentence;
  final String translatedSentence;
  final List<SentenceComponent> components;
  final String grammarNote;

  SentenceTranslation({
    required this.originalSentence,
    required this.translatedSentence,
    required this.components,
    this.grammarNote = '',
  });
}

class SentenceTranslator {
  static final SentenceTranslator _instance = SentenceTranslator._internal();
  factory SentenceTranslator() => _instance;
  SentenceTranslator._internal();

  final Map<String, String> _wordCache = {};
  bool _cacheBuilt = false;

  static const Map<String, String> _pronouns = {
    // Subject pronouns
    'i': 'sakən',
    'me': 'sakən',
    'you': 'ikaw',
    'he': 'kandin',
    'she': 'kandin',
    'it': 'kandin',
    'we': 'kitan',
    'they': 'silan',
    // Object pronouns
    'him': 'kandin',
    'her': 'kandin',
    'them': 'silan',
    'us': 'kitan',
    // Possessive pronouns
    'my': 'sakən',
    'your': 'mu',
    'his': 'nu kandin',
    'hers': 'nu kandin',
    'its': 'nu kandin',
    'our': 'nu kitan',
    'their': 'nu silan',
    'mine': 'nu sakən',
    'yours': 'mu',
    'ours': 'nu kitan',
    'theirs': 'nu silan',
  };

  static const Map<String, String> _beVerbs = {
    'am': 'ey',
    'is': 'ey',
    'are': 'ey',
    'was': 'ey',
    'were': 'ey',
    'been': 'ey',
    'being': 'ey',
  };

  static const Set<String> _articles = {'a', 'an', 'the'};

  static const Set<String> _prepositions = {
    'in', 'on', 'at', 'to', 'from', 'with', 'by', 'for', 'of', 'about',
    'into', 'through', 'during', 'before', 'after', 'above', 'below',
    'between', 'under', 'over', 'around', 'near', 'behind', 'beside',
    'across', 'along', 'against', 'toward', 'towards', 'upon', 'among',
    'inside', 'outside', 'without', 'within', 'until', 'since',
  };

  static const Set<String> _conjunctions = {
    'and', 'but', 'or', 'nor', 'so', 'yet', 'because', 'although',
    'while', 'if', 'when', 'where', 'unless', 'since', 'than',
  };

  static const Set<String> _adverbs = {
    'not', 'never', 'always', 'often', 'sometimes', 'usually', 'already',
    'also', 'very', 'really', 'just', 'only', 'still', 'even', 'again',
    'here', 'there', 'now', 'then', 'today', 'tomorrow', 'yesterday',
    'quickly', 'slowly', 'well', 'badly', 'hard', 'fast', 'soon',
    'much', 'more', 'most', 'less', 'least', 'too', 'enough',
    'perhaps', 'maybe', 'certainly', 'definitely', 'probably',
  };

  static const Set<String> _questionWords = {
    'what', 'who', 'where', 'when', 'why', 'how', 'which', 'whose',
  };

  static const Set<String> _negationWords = {'not', "n't", 'never', 'no', 'none'};

  static const Map<String, String> _questionWordTranslations = {
    'what': 'onu',
    'who': 'isin',
    'where': 'indiyan',
    'when': 'kunan',
    'why': 'pinaagi',
    'how': 'pinaagi',
    'which': 'isin',
    'whose': 'nu isin',
  };

  void _buildWordCache() {
    if (_cacheBuilt) return;
    for (var word in dictionaryWords) {
      _wordCache[word.word.toLowerCase()] = word.bagoboWord;
      if (word.bagoboWord.isNotEmpty) {
        var parts = word.bagoboWord.split(',').map((w) => w.trim().toLowerCase());
        for (var part in parts) {
          if (part.isNotEmpty) {
            _wordCache[part] = word.word;
          }
        }
      }
    }
    _cacheBuilt = true;
  }

  String? _lookupWord(String word) {
    _buildWordCache();
    final lower = word.toLowerCase().trim();
    if (_wordCache.containsKey(lower)) {
      return _wordCache[lower];
    }
    // Try partial match
    for (var entry in _wordCache.entries) {
      if (entry.key.contains(lower) || lower.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }

  DictionaryWord? _lookupDictionaryWord(String word) {
    final lower = word.toLowerCase().trim();
    for (var dw in dictionaryWords) {
      if (dw.word.toLowerCase() == lower) return dw;
      var bagoboParts = dw.bagoboWord.split(',').map((w) => w.trim().toLowerCase());
      if (bagoboParts.contains(lower)) return dw;
    }
    return null;
  }

  bool isSentence(String text) {
    final words = text.trim().split(RegExp(r'\s+'));
    if (words.length < 2) return false;

    final lower = text.toLowerCase().trim();

    // Has a verb indicator
    final hasVerb = _containsVerb(lower);
    // Has typical sentence patterns
    final hasSubjectPattern = _containsSubjectPronoun(lower) || _containsProperNoun(text);
    // Has prepositions or conjunctions (sentence structure markers)
    final hasStructureMarkers = words.any((w) => _prepositions.contains(w.toLowerCase()) || _conjunctions.contains(w.toLowerCase()));

    return hasVerb && (hasSubjectPattern || hasStructureMarkers);
  }

  bool _containsVerb(String text) {
    final words = text.split(RegExp(r'\s+'));
    for (var w in words) {
      final lower = w.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
      if (lower.isEmpty) continue;
      // Check be verbs
      if (_beVerbs.containsKey(lower)) return true;
      // Check dictionary for verbs
      final dw = _lookupDictionaryWord(lower);
      if (dw != null && dw.partOfSpeech.toLowerCase().contains('verb')) return true;
    }
    // Common verb patterns (ends in -ing, -ed, -s)
    for (var w in words) {
      final lower = w.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
      if (lower.endsWith('ing') || lower.endsWith('ed') || lower.endsWith('s') && lower.length > 3) {
        return true;
      }
    }
    return false;
  }

  bool _containsSubjectPronoun(String text) {
    final words = text.split(RegExp(r'\s+'));
    for (var w in words) {
      final lower = w.toLowerCase().replaceAll(RegExp(r'[^\w]'), '');
      if (_pronouns.containsKey(lower) && ['i', 'you', 'he', 'she', 'it', 'we', 'they'].contains(lower)) {
        return true;
      }
    }
    return false;
  }

  bool _containsProperNoun(String text) {
    final words = text.trim().split(RegExp(r'\s+'));
    for (var w in words) {
      if (w.isNotEmpty && w[0] == w[0].toUpperCase() && w[0] != w[0].toLowerCase()) {
        // Skip sentence-starting capitalization
        if (w == words.first) continue;
        // Skip known capitalized words
        if (_questionWords.contains(w.toLowerCase())) continue;
        return true;
      }
    }
    return false;
  }

  SentenceTranslation translateSentence(String text, {Language target = Language.bagobo}) {
    if (target != Language.bagobo) {
      return _translateSimpleWordByWord(text, target);
    }

    final cleaned = _cleanInput(text);
    final sentenceType = _detectSentenceType(cleaned);
    final tokens = _tokenize(cleaned);
    final components = _parseComponents(tokens, cleaned);
    final bagoboSentence = _assembleBagoboSentence(components, sentenceType);

    return SentenceTranslation(
      originalSentence: text,
      translatedSentence: bagoboSentence,
      components: components,
      grammarNote: _getGrammarNote(sentenceType),
    );
  }

  String _cleanInput(String text) {
    return text.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  SentenceType _detectSentenceType(String text) {
    final lower = text.toLowerCase();
    if (lower.startsWith('do ') || lower.startsWith('does ') || lower.startsWith('did ') ||
        lower.startsWith('is ') || lower.startsWith('are ') || lower.startsWith('was ') ||
        lower.startsWith('were ') || lower.startsWith('will ') || lower.startsWith('can ') ||
        lower.startsWith('could ') || lower.startsWith('should ') || lower.startsWith('would ') ||
        lower.startsWith('have ') || lower.startsWith('has ') || lower.startsWith('had ') ||
        lower.endsWith('?')) {
      return SentenceType.question;
    }
    if (_questionWords.contains(lower.split(' ').first)) {
      return SentenceType.question;
    }
    // Check for imperative (starts with a verb)
    final firstWord = lower.split(' ').first;
    if (_beVerbs.containsKey(firstWord)) {
      return SentenceType.statement;
    }
    final dw = _lookupDictionaryWord(firstWord);
    if (dw != null && dw.partOfSpeech.toLowerCase().contains('verb')) {
      // Could be imperative if no subject pronoun before it
      if (!_pronouns.containsKey(firstWord)) {
        return SentenceType.command;
      }
    }

    final words = lower.split(' ');
    if (words.contains('not') || words.any((w) => w.endsWith("n't"))) {
      return SentenceType.negation;
    }

    return SentenceType.statement;
  }

  List<String> _tokenize(String text) {
    return text.split(RegExp(r'\s+'))
        .map((w) => w.replaceAll(RegExp(r'[^\w-]'), ''))
        .where((w) => w.isNotEmpty)
        .toList();
  }

  List<SentenceComponent> _parseComponents(List<String> tokens, String fullText) {
    final components = <SentenceComponent>[];
    bool hasBeVerb = false;
    String? currentAdjective;
    int i = 0;

    while (i < tokens.length) {
      final token = tokens[i];
      final lower = token.toLowerCase();

      // Skip articles
      if (_articles.contains(lower)) {
        i++;
        continue;
      }

      // Question words
      if (_questionWords.contains(lower)) {
        final translated = _questionWordTranslations[lower] ?? lower;
        components.add(SentenceComponent(
          original: token,
          translated: translated,
          role: 'question_word',
        ));
        i++;
        continue;
      }

      // Negation
      if (_negationWords.contains(lower)) {
        components.add(SentenceComponent(
          original: token,
          translated: 'indi',
          role: 'negation',
        ));
        i++;
        continue;
      }

      // Pronouns (subject)
      if (_pronouns.containsKey(lower)) {
        // Determine if subject or object based on position
        final role = components.isEmpty || components.every((c) => c.role != 'subject')
            ? 'subject'
            : 'object';
        components.add(SentenceComponent(
          original: token,
          translated: _pronouns[lower]!,
          role: role,
          partOfSpeech: 'pronoun',
        ));
        i++;
        continue;
      }

      // Be verbs
      if (_beVerbs.containsKey(lower)) {
        hasBeVerb = true;
        components.add(SentenceComponent(
          original: token,
          translated: _beVerbs[lower]!,
          role: 'copula',
          partOfSpeech: 'verb',
        ));
        i++;
        continue;
      }

      // Prepositions
      if (_prepositions.contains(lower)) {
        final prepTranslation = _translatePreposition(lower);
        components.add(SentenceComponent(
          original: token,
          translated: prepTranslation,
          role: 'preposition',
        ));
        i++;
        continue;
      }

      // Conjunctions
      if (_conjunctions.contains(lower)) {
        final conjTranslation = _translateConjunction(lower);
        components.add(SentenceComponent(
          original: token,
          translated: conjTranslation,
          role: 'conjunction',
        ));
        i++;
        continue;
      }

      // Adverbs
      if (_adverbs.contains(lower)) {
        final advTranslation = _translateAdverb(lower);
        components.add(SentenceComponent(
          original: token,
          translated: advTranslation,
          role: 'adverb',
        ));
        i++;
        continue;
      }

      // Check dictionary for word role
      final dw = _lookupDictionaryWord(lower);
      if (dw != null) {
        final pos = dw.partOfSpeech.toLowerCase();
        String role;

        if (pos.contains('verb')) {
          role = 'verb';
        } else if (pos.contains('adjective')) {
          role = 'adjective';
        } else if (pos.contains('adverb')) {
          role = 'adverb';
        } else if (pos.contains('noun')) {
          // First noun-like word after verb is typically the object
          final hasVerb = components.any((c) => c.role == 'verb');
          final hasSubject = components.any((c) => c.role == 'subject');
          role = (!hasVerb || hasSubject) ? 'subject' : 'object';
        } else {
          role = 'object';
        }

        final translation = dw.bagoboWord.isNotEmpty ? dw.bagoboWord : dw.word;
        components.add(SentenceComponent(
          original: token,
          translated: translation,
          role: role,
          partOfSpeech: dw.partOfSpeech,
        ));
        i++;
        continue;
      }

      // Proper noun (capitalized, not first word)
      if (token[0] == token[0].toUpperCase() && i > 0) {
        components.add(SentenceComponent(
          original: token,
          translated: token, // Keep proper names as-is
          role: 'proper_noun',
        ));
        i++;
        continue;
      }

      // Unknown word - keep as-is
      components.add(SentenceComponent(
        original: token,
        translated: token,
        role: 'unknown',
      ));
      i++;
    }

    // Post-process: if no subject found, check if first component could be subject
    if (!components.any((c) => c.role == 'subject')) {
      for (var c in components) {
        if (c.role == 'object') {
          final idx = components.indexOf(c);
          // If it's the first noun-like word, treat as subject
          if (idx == 0 || !components.sublist(0, idx).any((cc) => cc.role == 'object')) {
            components[idx] = SentenceComponent(
              original: c.original,
              translated: c.translated,
              role: 'subject',
              partOfSpeech: c.partOfSpeech,
            );
            break;
          }
        }
      }
    }

    return components;
  }

  String _assembleBagoboSentence(List<SentenceComponent> components, SentenceType sentenceType) {
    if (components.isEmpty) return '';

    final subject = components.where((c) => c.role == 'subject' || c.role == 'proper_noun').toList();
    final verb = components.where((c) => c.role == 'verb' || c.role == 'copula').toList();
    final object = components.where((c) => c.role == 'object').toList();
    final adjectives = components.where((c) => c.role == 'adjective').toList();
    final adverbs = components.where((c) => c.role == 'adverb').toList();
    final prepositions = components.where((c) => c.role == 'preposition').toList();
    final conjunctions = components.where((c) => c.role == 'conjunction').toList();
    final negation = components.where((c) => c.role == 'negation').toList();
    final questionWord = components.where((c) => c.role == 'question_word').toList();

    final parts = <String>[];

    // Question word at the beginning
    if (questionWord.isNotEmpty) {
      parts.add(questionWord.first.translated);
    }

    // Negation marker
    if (negation.isNotEmpty) {
      parts.add(negation.first.translated);
    }

    // Adverbs before verb
    for (var adv in adverbs) {
      parts.add(adv.translated);
    }

    // Bagobo VSO order: Verb first
    for (var v in verb) {
      String verbForm = v.translated;
      // Apply verb focus prefix based on sentence structure
      if (object.isNotEmpty && subject.isNotEmpty) {
        // Actor focus: mu- prefix (actor performs the action)
        if (!verbForm.startsWith('mu') && !verbForm.startsWith('ma') && !verbForm.startsWith('mi')) {
          verbForm = 'mu$verbForm';
        }
      }
      parts.add(verbForm);
    }

    // Subject (with actor marker)
    for (var s in subject) {
      if (s.role == 'proper_noun') {
        parts.add(s.original); // Keep proper name
      } else {
        parts.add(s.translated);
      }
    }

    // Object (with patient marker "su" if present)
    for (var o in object) {
      String objText = o.translated;
      // Add patient marker for object-focus sentences
      if (subject.isNotEmpty && verb.isNotEmpty) {
        objText = 'su $objText';
      }
      parts.add(objText);
    }

    // Adjectives after the noun they modify
    for (var adj in adjectives) {
      parts.add(adj.translated);
    }

    // Prepositions and their objects
    for (var prep in prepositions) {
      parts.add(prep.translated);
    }

    // Conjunctions
    for (var conj in conjunctions) {
      parts.add(conj.translated);
    }

    var result = parts.join(' ');

    // Question marker at the end
    if (sentenceType == SentenceType.question) {
      result = '$result ba';
    }

    // Capitalize first letter
    if (result.isNotEmpty) {
      result = result[0].toUpperCase() + result.substring(1);
    }

    return result;
  }

  String _translatePreposition(String prep) {
    const prepositionMap = {
      'in': 'di',
      'on': 'di',
      'at': 'di',
      'to': 'pa',
      'from': 'galing',
      'with': 'iban',
      'by': 'nu',
      'for': 'para',
      'of': 'nu',
      'about': 'mahitungod',
      'into': 'di',
      'during': 'panahon',
      'before': 'bagu',
      'after': 'pasado',
      'above': 'babaw',
      'below': 'ubus',
      'between': 'taliwala',
      'under': 'ubus',
      'over': 'babaw',
      'around': 'palibot',
      'near': 'duol',
      'without': 'waray',
      'until': 'asta',
      'since': 'sukad',
    };
    return prepositionMap[prep] ?? prep;
  }

  String _translateConjunction(String conj) {
    const conjunctionMap = {
      'and': 'iban',
      'but': 'pero',
      'or': 'o',
      'because': 'kay',
      'if': 'kung',
      'when': 'kunan',
      'where': 'indiyan',
      'while': 'samtang',
    };
    return conjunctionMap[conj] ?? conj;
  }

  String _translateAdverb(String adv) {
    const adverbMap = {
      'not': 'indi',
      'never': 'indi gayud',
      'always': 'sulit',
      'often': 'pirmi',
      'sometimes': 'minsán',
      'already': 'elantape',
      'also': 'pagsik',
      'very': 'kaayo',
      'really': 'gayud',
      'just': 'lang',
      'only': 'lang',
      'still': 'apan',
      'here': 'diyan',
      'there': 'diyan',
      'now': 'karon',
      'then': 'tapos',
      'quickly': 'madali',
      'well': 'maayo',
    };
    return adverbMap[adv] ?? adv;
  }

  SentenceTranslation _translateSimpleWordByWord(String text, Language target) {
    final words = text.trim().split(RegExp(r'\s+'));
    final translated = <String>[];

    for (var word in words) {
      final clean = word.replaceAll(RegExp(r'[^\w]'), '');
      String? fieldKey;
      if (target == Language.tagalog) fieldKey = 'tagalog';
      else if (target == Language.bisaya) fieldKey = 'bisaya';
      else if (target == Language.english) fieldKey = 'word';

      if (fieldKey != null) {
        final dw = _lookupDictionaryWord(clean);
        if (dw != null) {
          String result;
          switch (target) {
            case Language.tagalog: result = dw.tagalog.isNotEmpty ? dw.tagalog : dw.word; break;
            case Language.bisaya: result = dw.bisaya.isNotEmpty ? dw.bisaya : dw.word; break;
            case Language.english: result = dw.word; break;
            default: result = clean;
          }
          translated.add(result);
          continue;
        }
      }
      translated.add(clean);
    }

    return SentenceTranslation(
      originalSentence: text,
      translatedSentence: translated.join(' '),
      components: [],
    );
  }

  String _getGrammarNote(SentenceType type) {
    switch (type) {
      case SentenceType.statement:
        return 'Bagobo uses VSO (Verb-Subject-Object) word order. The verb comes first.';
      case SentenceType.question:
        return 'Questions in Bagobo end with "ba" as a question marker.';
      case SentenceType.command:
        return 'Commands use the verb root form directly.';
      case SentenceType.negation:
        return 'Negation uses "indi" before the verb.';
    }
  }
}
