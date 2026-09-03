import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/feature_tile.dart';
import '../features/alphabet_page.dart';
import '../features/numbers_page.dart';
import '../features/shapes_colors_page.dart';
import '../features/animals_page.dart';
import '../features/fruits_veggies_page.dart';
import '../features/stories_page.dart';

/// Learn tab page - educational content
class LearnTab extends StatelessWidget {
  const LearnTab({super.key});

  static const List<FeatureItem> _items = [
    FeatureItem('Alphabet A–Z', Icons.abc_rounded, AppColors.pink),
    FeatureItem('Numbers & Counting', Icons.pin_rounded, AppColors.yellow),
    FeatureItem('Shapes & Colors', Icons.category_rounded, AppColors.teal),
    FeatureItem('Animals', Icons.pets_rounded, AppColors.purple),
    FeatureItem('Fruits & Vegetables', Icons.eco_rounded, AppColors.pink),
    FeatureItem('Stories & Audio', Icons.auto_stories_rounded, AppColors.teal),
  ];

  void _navigateToFeature(BuildContext context, int index) {
    final routes = [
      MaterialPageRoute(builder: (_) => const AlphabetPage()),
      MaterialPageRoute(builder: (_) => const NumbersPage()),
      MaterialPageRoute(builder: (_) => const ShapesColorsPage()),
      MaterialPageRoute(builder: (_) => const AnimalsPage()),
      MaterialPageRoute(builder: (_) => const FruitsVeggiesPage()),
      MaterialPageRoute(builder: (_) => const StoriesPage()),
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
              'Learn 📚',
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
