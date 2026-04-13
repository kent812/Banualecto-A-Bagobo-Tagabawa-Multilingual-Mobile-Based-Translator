import 'package:flutter/material.dart';
import '../main.dart';

class TrendingScreen extends StatelessWidget {
  const TrendingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: darkModeNotifier,
      builder: (_, isDark, __) {
        final bg = isDark ? const Color(0xFF13100D) : const Color(0xFFFAF6F0);
        final text = isDark ? const Color(0xFFF5F0EA) : const Color(0xFF1A1108);
        final sub = isDark ? const Color(0xFFA89B8C) : const Color(0xFF5C4F3D);
        final surface = isDark ? const Color(0xFF2A2420) : Colors.white;
        final accent = const Color(0xFFB85C38);

        final words = [
          {'rank': 1, 'word': 'datu', 'meaning': 'chieftain / leader', 'searches': '1.2k'},
          {'rank': 2, 'word': 'bayanihan', 'meaning': 'community spirit', 'searches': '984'},
          {'rank': 3, 'word': 'tagalog', 'meaning': 'river dweller', 'searches': '876'},
          {'rank': 4, 'word': 'saluyot', 'meaning': 'jute plant / greens', 'searches': '741'},
          {'rank': 5, 'word': 'lihi', 'meaning': 'maternal influence', 'searches': '630'},
          {'rank': 6, 'word': 'balikbayan', 'meaning': 'returning hometown', 'searches': '512'},
          {'rank': 7, 'word': 'pamilya', 'meaning': 'family', 'searches': '489'},
          {'rank': 8, 'word': 'kaibigan', 'meaning': 'friend', 'searches': '423'},
          {'rank': 9, 'word': 'pagmamahal', 'meaning': 'love / affection', 'searches': '398'},
          {'rank': 10, 'word': 'pakikipagkaibigan', 'meaning': 'friendship', 'searches': '356'},
        ];

        return Scaffold(
          backgroundColor: bg,
          appBar: AppBar(
            backgroundColor: bg,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: text),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('Trending Words', style: TextStyle(color: text, fontWeight: FontWeight.bold)),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: words.length,
            itemBuilder: (_, i) {
              final w = words[i];
              final rank = w['rank'] as int;
              Color rankColor;
              if (rank == 1) rankColor = const Color(0xFFFFCC00);
              else if (rank == 2) rankColor = const Color(0xFFAAAAAA);
              else if (rank == 3) rankColor = const Color(0xFFCD7F32);
              else rankColor = sub;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(14)),
                child: Row(
                  children: [
                    SizedBox(width: 32, child: Text('#$rank', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: rankColor))),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(w['word'] as String, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: text)),
                          const SizedBox(height: 2),
                          Text(w['meaning'] as String, style: TextStyle(fontSize: 12, color: sub)),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.trending_up_rounded, size: 14, color: accent),
                        const SizedBox(width: 4),
                        Text(w['searches'] as String, style: TextStyle(fontSize: 12, color: accent, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
