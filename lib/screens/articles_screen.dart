import 'package:flutter/material.dart';
import '../main.dart';

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

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

        final articles = [
          {'icon': Icons.menu_book_rounded, 'title': 'Origins of the Tagabawa Language', 'tag': 'History', 'mins': 5, 'desc': 'Tagabawa is a Manobo language of the Austronesian family, spoken by approximately 30,000 people in Davao City, Cotabato, and Davao del Sur provinces. The name "Bagobo" comes from "bago" (new) and "obo/uvu" (person), meaning "new people". (Source: Wikipedia, NCCA)'},
          {'icon': Icons.account_tree_rounded, 'title': 'Bagobo Subgroups: Tagabawa, Klata, Ovu', 'tag': 'People', 'mins': 4, 'desc': 'The Bagobo are one of the largest subgroups of the Manobo peoples, comprising three main groups: Tagabawa (settled in Davao region), Klata/Guiangan, and Ovu/Ubo. They were formerly nomadic hunter-gatherers. (Source: Aswang Project)'},
          {'icon': Icons.terrain_rounded, 'title': 'Mount Apo: Sacred Highland', 'tag': 'Geography', 'mins': 3, 'desc': 'Mount Apo, the highest peak in the Philippines at 2,954 meters, is sacred to the Bagobo people who call the mountain their ancestral home. Tagabawa is spoken on the western slopes of Mount Apo. (Source: Wikipedia)'},
          {'icon': Icons.auto_awesome_rounded, 'title': 'Mabalian: Shamanic Traditions', 'tag': 'Spirituality', 'mins': 6, 'desc': 'The Mabalian is the shamanic practitioner in Bagobo culture, serving as intermediary between the living and the spirit world. They communicate with deities and ancestral spirits called anito. (Source: Aswang Project)'},
          {'icon': Icons.shield_rounded, 'title': 'Warrior Culture & Sacred Rituals', 'tag': 'Tradition', 'mins': 7, 'desc': 'Traditional Bagobo society had warrior classes (bagani). They conduct sacred rituals honoring ancestors and nature spirits called anito. Sacred rituals include pagan cups (pompom) ceremonies. (Source: NCCA, Facebook)'},
          {'icon': Icons.restaurant_rounded, 'title': 'Food as Medicine Tradition', 'tag': 'Culture', 'mins': 5, 'desc': 'The Bagobo-Tagabawa practice holistic health traditions using medicinal plants from their ancestral lands. Families maintain backyard gardens with traditional herbs. (Source: Rooted Magazine)'},
          {'icon': Icons.people_rounded, 'title': 'Davao Regional Heritage', 'tag': 'Culture', 'mins': 4, 'desc': 'Davao del Sur is home to the Bagobo people. The Bagobo-Tagabawa Cultural Village in Tibolo, Sta. Cruz preserves their traditional way of life. (Source: Out of Town Blog)'},
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
            title: Text('Featured Articles', style: TextStyle(color: text, fontWeight: FontWeight.bold)),
          ),
          body: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: articles.length,
            itemBuilder: (_, i) {
              final a = articles[i];
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: surface, borderRadius: BorderRadius.circular(18)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(a['icon'] as IconData, size: 28, color: accent),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(color: accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                                child: Text(a['tag'] as String, style: TextStyle(fontSize: 10, color: accent, fontWeight: FontWeight.w600)),
                              ),
                              const SizedBox(height: 8),
                              Text(a['title'] as String, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: text)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(a['desc'] as String, style: TextStyle(fontSize: 12, color: sub, height: 1.4)),
                    const SizedBox(height: 8),
                    Text('${a['mins']} min read', style: TextStyle(fontSize: 11, color: sub)),
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
