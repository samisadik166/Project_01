import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/feature_tile.dart';
import '../features/games_page.dart';

/// Play tab page - interactive activities
class PlayTab extends StatelessWidget {
  final String? childId;

  const PlayTab({super.key, required this.childId});

  static const List<FeatureItem> _items = [
    FeatureItem('Count the Stars', Icons.star_rounded, AppColors.yellow),
    FeatureItem('Find the Color', Icons.palette_rounded, AppColors.teal),
    FeatureItem('Memory Match', Icons.grid_view_rounded, AppColors.purple),
  ];

  void _navigateToFeature(BuildContext context, int index) {
    final selectedChildId = childId;
    if (selectedChildId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a child profile before starting a game.')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GamesPage(
          childId: selectedChildId,
          initialGameIndex: index,
        ),
      ),
    );
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
              'Play',
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
