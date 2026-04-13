import 'package:flutter/material.dart';
import '../theme/colors.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guide'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              title: 'Getting Started',
              icon: Icons.play_circle,
              content:
                  'Welcome to Banualecto! This guide will help you navigate through the app '
                  'and make the most of its features.',
            ),
            _buildSection(
              title: 'Search Words',
              icon: Icons.search,
              content:
                  'Use the search bar to find words. You can search by English '
                  'or Bagobo-Tagabawa words. The search will show matching results as you type.',
            ),
            _buildSection(
              title: 'Word of the Day',
              icon: Icons.wb_sunny,
              content:
                  'Check the Word of the Day on the homepage to learn a new word every day. '
                  'Tap on it to see the full definition, pronunciation, and example sentence.',
            ),
            _buildSection(
              title: 'Categories',
              icon: Icons.category,
              content:
                  'Browse words by category such as Greetings, Family, Numbers, Colors, Animals, '
                  'Food, Nature, Actions, Emotions, and Time.',
            ),
            _buildSection(
              title: 'Saved',
              icon: Icons.bookmark,
              content:
                  'Save your favorite words by tapping the bookmark icon. Access your saved words '
                  'anytime from the Saved section.',
            ),
            _buildSection(
              title: 'History',
              icon: Icons.history,
              content:
                  'Your recently viewed words are automatically saved in History. '
                  'Tap on any word to view its details again.',
            ),
            _buildSection(
              title: 'Games',
              icon: Icons.games,
              content:
                  'Have fun while learning! Play Word Scramble to unscramble Bagobo-Tagabawa words, '
                  'or take the Quiz to test your knowledge.',
            ),
            _buildSection(
              title: 'Pronunciation',
              icon: Icons.volume_up,
              content:
                  'Each word includes a pronunciation guide. Tap the speaker icon to hear how '
                  'the word is pronounced.',
            ),
            _buildSection(
              title: 'Suggestions',
              icon: Icons.feedback,
              content:
                  'Help us improve! Use the Suggestions feature to report errors, suggest new words, '
                  'or share general feedback.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required String content,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
