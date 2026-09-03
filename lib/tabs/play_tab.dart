import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/feature_tile.dart';
import '../features/games_page.dart';
import '../features/drawing_page.dart';
import '../features/quizzes_page.dart';

/// Play tab page - interactive activities
class PlayTab extends StatelessWidget {
  const PlayTab({super.key});

  static const List<FeatureItem> _items = [
    FeatureItem(
      'Interactive Games',
      Icons.sports_esports_rounded,
      AppColors.yellow,
    ),
    FeatureItem('Drawing & Coloring', Icons.brush_rounded, AppColors.purple),
    FeatureItem('Quizzes', Icons.quiz_rounded, AppColors.pink),
  ];

  void _navigateToFeature(BuildContext context, int index) {
    final routes = [
      MaterialPageRoute(builder: (_) => const GamesPage()),
      MaterialPageRoute(builder: (_) => const DrawingPage()),
      MaterialPageRoute(builder: (_) => const QuizzesPage()),
    ];
    Navigator.of(context).push(routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: const Text(
              'Play 🎮',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: AppColors.darkGray,
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: _items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = _items[index];
                return FeatureListTile(
                  item: item,
                  onTap: () => _navigateToFeature(context, index),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
