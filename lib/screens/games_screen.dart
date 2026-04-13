import 'package:flutter/material.dart';
import '../theme/colors.dart';
import '../data/dictionary_data.dart';
import '../models/word_model.dart';

class GamesScreen extends StatelessWidget {
  const GamesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                ),
              ],
            ),
            child: const Text('←', style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Games',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: const Text('🏆', style: TextStyle(fontSize: 40)),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Learn While Playing!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Challenge yourself to improve your vocabulary',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildGameCard(
              context,
              title: 'Word Scramble',
              description: 'Unscramble letters to form Bagobo-Tagabawa words',
              iconText: '🔀',
              color: const Color(0xFFFF6B6B),
              gradient: const LinearGradient(
                colors: [Color(0xFFFF6B6B), Color(0xFFFF8E8E)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const WordScrambleScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              context,
              title: 'Quiz',
              description: 'Test your knowledge of Bagobo-Tagabawa words',
              iconText: '❓',
              color: const Color(0xFF4ECDC4),
              gradient: const LinearGradient(
                colors: [Color(0xFF4ECDC4), Color(0xFF6EE7DE)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const QuizScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              context,
              title: 'Memory Match',
              description: 'Match Bagobo words with English translations',
              iconText: '🃏',
              color: const Color(0xFF9B59B6),
              gradient: const LinearGradient(
                colors: [Color(0xFF9B59B6), Color(0xFFB07CC6)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const MemoryMatchScreen()),
                );
              },
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              context,
              title: 'Flashcards',
              description: 'Swipe to learn vocabulary with pronunciation',
              iconText: '📇',
              color: const Color(0xFF3498DB),
              gradient: const LinearGradient(
                colors: [Color(0xFF3498DB), Color(0xFF5DADE2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FlashcardsScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(
    BuildContext context, {
    required String title,
    required String description,
    required String iconText,
    required Color color,
    required LinearGradient gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Text(iconText, style: const TextStyle(fontSize: 40)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Text('➡', style: TextStyle(fontSize: 20, color: Colors.white70)),
            ],
          ),
        ),
      ),
    );
  }
}

class WordScrambleScreen extends StatefulWidget {
  const WordScrambleScreen({super.key});

  @override
  State<WordScrambleScreen> createState() => _WordScrambleScreenState();
}

class _WordScrambleScreenState extends State<WordScrambleScreen> {
  late List<DictionaryWord> _words;
  int _currentIndex = 0;
  int _score = 0;
  String _scrambled = '';
  final TextEditingController _answerController = TextEditingController();
  bool _answered = false;
  bool _isCorrect = false;

  @override
  void initState() {
    super.initState();
    _words = List.from(dictionaryWords)..shuffle();
    _scrambleWord();
  }

  void _scrambleWord() {
    final word = _words[_currentIndex];
    final letters = word.bagoboWord.toUpperCase().split('');
    letters.shuffle();
    _scrambled = letters.join();
  }

  void _checkAnswer() {
    final answer = _answerController.text.toLowerCase().trim();
    final correct = _words[_currentIndex].bagoboWord.toLowerCase();

    setState(() {
      _answered = true;
      _isCorrect = answer == correct;
      if (_isCorrect) _score++;
    });
  }

  void _nextWord() {
    setState(() {
      _currentIndex++;
      _answered = false;
      _isCorrect = false;
      _answerController.clear();
      if (_currentIndex >= _words.length) {
        _showResults();
      } else {
        _scrambleWord();
      }
    });
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('🏆', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            const Text('Game Over!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your score: $_score/${_words.length}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildScoreIndicator(),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back to Games'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _words.shuffle();
                _currentIndex = 0;
                _score = 0;
                _answered = false;
                _isCorrect = false;
                _answerController.clear();
                _scrambleWord();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_words.length, (index) {
        final isCorrect = index < _score;
        return Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isCorrect ? AppColors.success : AppColors.divider,
            borderRadius: BorderRadius.circular(6),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text('Old Quiz Removed')),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<DictionaryWord> _words;
  int _currentIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;

  @override
  void initState() {
    super.initState();
    _words = List.from(dictionaryWords)..shuffle();
  }

  List<String> _generateOptions(DictionaryWord correct) {
    final options = <String>[correct.bagoboWord];
    final others = dictionaryWords.where((w) => w.id != correct.id).toList()..shuffle();
    for (var i = 0; i < 3 && i < others.length; i++) {
      options.add(others[i].bagoboWord);
    }
    options.shuffle();
    return options;
  }

  void _checkAnswer(int answer) {
    final correct = _words[_currentIndex].bagoboWord;
    final options = _generateOptions(_words[_currentIndex]);
    final isCorrect = options[answer] == correct;

    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      if (isCorrect) _score++;
    });
  }

  void _nextQuestion() {
    if (_currentIndex + 1 >= _words.length) {
      _showResults();
      return;
    }
    setState(() {
      _currentIndex++;
      _selectedAnswer = null;
      _answered = false;
    });
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('🏆', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            const Text('Quiz Complete!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Your score: $_score/${_words.length}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_words.length, (index) {
                final isCorrect = index < _score;
                return Container(
                  width: 24,
                  height: 24,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: isCorrect ? AppColors.success : AppColors.divider,
                    borderRadius: BorderRadius.circular(6),
                  ),
                );
              }),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back to Games'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _words.shuffle();
                _currentIndex = 0;
                _score = 0;
                _selectedAnswer = null;
                _answered = false;
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_currentIndex >= _words.length) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentWord = _words[_currentIndex];
    final options = _generateOptions(currentWord);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Text('✕', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('❓', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 8),
            const Text(
              'Quiz',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_words.length, (index) {
                final isCorrect = index < _score && index < _currentIndex;
                return Container(
                  width: 20,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: index < _currentIndex
                        ? (isCorrect ? AppColors.success : AppColors.error)
                        : AppColors.divider,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(28),
              ),
              child: Text(
                'Question ${_currentIndex + 1}/${_words.length}',
                style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Score: $_score',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'What is the Bagobo word for:',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    currentWord.word,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            ...List.generate(options.length, (index) {
              final isSelected = _selectedAnswer == index;
              final isCorrectAnswer = options[index] == currentWord.bagoboWord;

              Color? backgroundColor;
              Color borderColor = Colors.transparent;
              if (_answered) {
                if (isCorrectAnswer) {
                  backgroundColor = AppColors.success.withValues(alpha: 0.15);
                  borderColor = AppColors.success;
                } else if (isSelected) {
                  backgroundColor = AppColors.error.withValues(alpha: 0.15);
                  borderColor = AppColors.error;
                }
              }

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: _answered ? null : () => _checkAnswer(index),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: backgroundColor ?? Colors.white,
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(color: borderColor, width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (_answered
                                    ? (isCorrectAnswer ? AppColors.success : AppColors.error)
                                    : AppColors.primary)
                                : AppColors.divider,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + index),
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            options[index],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (_answered && isCorrectAnswer)
                          const Text('✓', style: TextStyle(fontSize: 20, color: AppColors.success)),
                        if (_answered && isSelected && !isCorrectAnswer)
                          const Text('✗', style: TextStyle(fontSize: 20, color: AppColors.error)),
                      ],
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 16),
            if (_answered)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    'Next Question',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MemoryMatchScreen extends StatefulWidget {
  const MemoryMatchScreen({super.key});

  @override
  State<MemoryMatchScreen> createState() => _MemoryMatchScreenState();
}

class _MemoryMatchScreenState extends State<MemoryMatchScreen> {
  late List<DictionaryWord> _words;
  List<_MemoryCard> _cards = [];
  int _score = 0;
  int _matches = 0;
  int? _firstSelected;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _words = List.from(dictionaryWords)..shuffle();
    final selectedWords = _words.take(6).toList();
    _cards = [];
    
    for (var word in selectedWords) {
      _cards.add(_MemoryCard(
        id: word.id,
        content: word.bagoboWord,
        isBagobo: true,
        matched: false,
      ));
      _cards.add(_MemoryCard(
        id: word.id,
        content: word.word,
        isBagobo: false,
        matched: false,
      ));
    }
    _cards.shuffle();
    setState(() {});
  }

  void _onCardTap(int index) {
    if (_isProcessing || _cards[index].matched || _firstSelected == index) return;

    setState(() {
      _cards[index] = _cards[index].copyWith(isFlipped: true);
    });

    if (_firstSelected == null) {
      _firstSelected = index;
    } else {
      _isProcessing = true;
      final first = _cards[_firstSelected!];
      final second = _cards[index];

      if (first.id == second.id) {
        setState(() {
          _cards[_firstSelected!] = first.copyWith(matched: true);
          _cards[index] = second.copyWith(matched: true);
          _score++;
          _matches++;
          _firstSelected = null;
          _isProcessing = false;
        });
        if (_matches >= 6) _showResults();
      } else {
        Future.delayed(const Duration(milliseconds: 1000), () {
          setState(() {
            _cards[_firstSelected!] = first.copyWith(isFlipped: false);
            _cards[index] = second.copyWith(isFlipped: false);
            _firstSelected = null;
            _isProcessing = false;
          });
        });
      }
    }
  }

  void _showResults() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text('🏆', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 12),
            const Text('Congratulations!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Score: $_score/12',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('You matched all pairs!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back to Games'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _score = 0;
                _matches = 0;
                _firstSelected = null;
                _isProcessing = false;
                _initGame();
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Text('✕', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Memory Match',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Score: $_score',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.8,
          ),
          itemCount: _cards.length,
          itemBuilder: (context, index) {
            final card = _cards[index];
            return GestureDetector(
              onTap: () => _onCardTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  gradient: card.matched
                      ? LinearGradient(
                          colors: [AppColors.success, AppColors.success.withValues(alpha: 0.7)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : card.isFlipped
                          ? AppColors.primaryGradient
                          : const LinearGradient(
                              colors: [Color(0xFF9B59B6), Color(0xFFB07CC6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: (card.matched ? AppColors.success : const Color(0xFF9B59B6))
                          .withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: card.isFlipped || card.matched
                      ? Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                card.isBagobo ? '📝' : '🔤',
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                card.content,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : const Text('?', style: TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _MemoryCard {
  final String id;
  final String content;
  final bool isBagobo;
  final bool isFlipped;
  final bool matched;

  _MemoryCard({
    required this.id,
    required this.content,
    required this.isBagobo,
    this.isFlipped = false,
    this.matched = false,
  });

  _MemoryCard copyWith({bool? isFlipped, bool? matched}) {
    return _MemoryCard(
      id: id,
      content: content,
      isBagobo: isBagobo,
      isFlipped: isFlipped ?? this.isFlipped,
      matched: matched ?? this.matched,
    );
  }
}

class FlashcardsScreen extends StatefulWidget {
  const FlashcardsScreen({super.key});

  @override
  State<FlashcardsScreen> createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  late List<DictionaryWord> _words;
  int _currentIndex = 0;
  bool _isFront = true;

  @override
  void initState() {
    super.initState();
    _words = List.from(dictionaryWords)..shuffle();
  }

  void _nextCard() {
    setState(() {
      _currentIndex = (_currentIndex + 1) % _words.length;
      _isFront = true;
    });
  }

  void _previousCard() {
    setState(() {
      _currentIndex = (_currentIndex - 1 + _words.length) % _words.length;
      _isFront = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final currentWord = _words[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Text('✕', style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('📇', style: TextStyle(fontSize: 20)),
            ),
            const SizedBox(width: 8),
            const Text(
              'Flashcards',
              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            _nextCard();
          } else if (details.primaryVelocity! > 0) {
            _previousCard();
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Card ${_currentIndex + 1}/${_words.length}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Swipe left or right to navigate',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _isFront = !_isFront),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      key: ValueKey(_isFront),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: _isFront
                            ? AppColors.primaryGradient
                            : LinearGradient(
                                colors: [
                                  AppColors.accent,
                                  AppColors.accent.withValues(alpha: 0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: (_isFront ? AppColors.primary : AppColors.accent)
                                .withValues(alpha: 0.4),
                            blurRadius: 25,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _isFront ? '📝' : '📖',
                              style: const TextStyle(fontSize: 40),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _isFront ? currentWord.bagoboWord : currentWord.word,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            if (!_isFront) ...[
                              const SizedBox(height: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  currentWord.pronunciation,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                  child: Row(
                                    children: [
                                      const Text('"', style: TextStyle(fontSize: 20, color: Colors.white)),
                                      const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        currentWord.exampleSentence,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.9),
                                          fontSize: 14,
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            Text(
                              'Tap to flip',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: _previousCard,
                    icon: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Text('←', style: TextStyle(fontSize: 20, color: AppColors.primary)),
                    ),
                  ),
                  const SizedBox(width: 24),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: TextButton(
                      onPressed: () => setState(() => _isFront = !_isFront),
                      child: const Text('🔄', style: TextStyle(fontSize: 20)),
                    ),
                  ),
                  const SizedBox(width: 24),
                  IconButton(
                    onPressed: _nextCard,
                    icon: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Text('→', style: TextStyle(fontSize: 20, color: AppColors.primary)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
