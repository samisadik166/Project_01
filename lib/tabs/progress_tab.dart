import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/feature_tile.dart';
import '../utils/helpers.dart';

/// Progress tab page - tracking achievements and rewards
class ProgressTab extends StatelessWidget {
  const ProgressTab({super.key});

  static const List<FeatureItem> _items = [
    FeatureItem('Stars & Badges', Icons.emoji_events_rounded, AppColors.yellow),
    FeatureItem(
      'Certificates',
      Icons.workspace_premium_rounded,
      AppColors.teal,
    ),
    FeatureItem('Performance Reports', Icons.bar_chart_rounded, AppColors.pink),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: const Text(
              'Progress 🏆',
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
                  onTap: () => showComingSoon(context, item.label),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
