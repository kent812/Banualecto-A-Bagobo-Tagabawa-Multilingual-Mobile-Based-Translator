import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _bg = Color(0xFFFAF6F0);
  static const _text = Color(0xFF1A1108);
  static const _sub = Color(0xFF5C4F3D);
  static const _accent = Color(0xFFB85C38);
  static const _surface = Colors.white;
  static const _border = Color(0xFFE8DDD0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: _text, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('About', style: TextStyle(color: _text, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(24)),
              child: const Icon(Icons.menu_book_rounded, size: 56, color: Colors.white),
            ),
            const SizedBox(height: 20),
            const Text('Banualecto', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: _text)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(color: _accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: const Text('Version 1.0.0', style: TextStyle(color: _accent, fontWeight: FontWeight.w600)),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: _border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('About Banualecto', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _text)),
                  const SizedBox(height: 12),
                  Text(
                    'Your daily companion for learning Bagobo-Tagabawa. '
                    'Discover the richness of our local language through translations, '
                    'word of the day, games, and more.',
                    style: TextStyle(fontSize: 14, color: _sub, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(20), border: Border.all(color: _border)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Features', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: _text)),
                  const SizedBox(height: 16),
                  _featureRow(Icons.wb_sunny_rounded, 'Word of the Day'),
                  _featureRow(Icons.translate_rounded, 'Translate'),
                  _featureRow(Icons.mic_rounded, 'Voice Input'),
                  _featureRow(Icons.bookmark_rounded, 'Saved Words'),
                  _featureRow(Icons.games_rounded, 'Learning Games'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _actionCard(context, icon: Icons.lightbulb_outline_rounded, title: 'Suggest a Word', subtitle: 'Submit new Bagobo words to add', onTap: () => _sendSuggestion(context)),
            const SizedBox(height: 12),
            _actionCard(context, icon: Icons.share_rounded, title: 'Share App', subtitle: 'Invite others to learn', onTap: () => _shareApp(context)),
            const SizedBox(height: 16),
            _contactRow(Icons.email_rounded, 'bagobodictionary@gmail.com'),
            const SizedBox(height: 12),
            _contactRow(Icons.alternate_email, '@Banualecto'),
            const SizedBox(height: 24),
            const Text('© 2024 Banualecto. All rights reserved.', style: TextStyle(fontSize: 12, color: _sub)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _featureRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: _accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: _accent, size: 18),
          ),
          const SizedBox(width: 12),
          Text(text, style: TextStyle(fontSize: 15, color: _text)),
        ],
      ),
    );
  }

  Widget _actionCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: _text)),
                  Text(subtitle, style: TextStyle(fontSize: 13, color: _sub)),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: _sub),
          ],
        ),
      ),
    );
  }

  Widget _contactRow(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: _border)),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: _accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: _accent, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(child: Text(text, style: TextStyle(fontSize: 15, color: _text))),
          Icon(Icons.chevron_right_rounded, color: _sub, size: 18),
        ],
      ),
    );
  }

  void _sendSuggestion(BuildContext context) {
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _surface,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 36, height: 4, decoration: BoxDecoration(color: _border, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            Text('Suggest a Word', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _text)),
            const SizedBox(height: 8),
            Text('Submit a new Bagobo word to add to the dictionary.', style: TextStyle(fontSize: 14, color: _sub)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: _bg, borderRadius: BorderRadius.circular(12)),
              child: TextField(
                controller: controller,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Enter the word and its meaning...',
                  hintStyle: TextStyle(color: _sub),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: 'Word Suggestion: ${controller.text}'));
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: const Text('Suggestion copied! Paste in email to send.'), backgroundColor: _accent),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(color: _accent, borderRadius: BorderRadius.circular(12)),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Copy Text', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _shareApp(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: 'Check out Banualecto - Bagobo-Tagabawa Dictionary app!'));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Share text copied!'),
        backgroundColor: _accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}