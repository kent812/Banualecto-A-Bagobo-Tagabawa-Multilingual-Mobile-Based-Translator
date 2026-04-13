class DictionaryWord {
  final String id;
  final String word;
  final String bagoboWord;
  final String tagalog;
  final String bisaya;
  final String partOfSpeech;
  final String description;
  final List<String> synonyms;
  final String exampleSentence;
  final String category;
  final String pronunciation;

  const DictionaryWord({
    required this.id,
    required this.word,
    required this.bagoboWord,
    required this.tagalog,
    required this.bisaya,
    required this.partOfSpeech,
    required this.description,
    required this.synonyms,
    required this.exampleSentence,
    required this.category,
    required this.pronunciation,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'bagoboWord': bagoboWord,
      'tagalog': tagalog,
      'bisaya': bisaya,
      'partOfSpeech': partOfSpeech,
      'description': description,
      'synonyms': synonyms,
      'exampleSentence': exampleSentence,
      'category': category,
      'pronunciation': pronunciation,
    };
  }

  factory DictionaryWord.fromMap(Map<String, dynamic> map) {
    return DictionaryWord(
      id: map['id'] ?? '',
      word: map['word'] ?? '',
      bagoboWord: map['bagoboWord'] ?? '',
      tagalog: map['tagalog'] ?? '',
      bisaya: map['bisaya'] ?? '',
      partOfSpeech: map['partOfSpeech'] ?? '',
      description: map['description'] ?? '',
      synonyms: List<String>.from(map['synonyms'] ?? []),
      exampleSentence: map['exampleSentence'] ?? '',
      category: map['category'] ?? '',
      pronunciation: map['pronunciation'] ?? '',
    );
  }
}

class WordCategory {
  final String id;
  final String name;
  final String icon;

  const WordCategory({
    required this.id,
    required this.name,
    required this.icon,
  });
}
