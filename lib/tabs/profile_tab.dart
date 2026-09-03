import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/feature_tile.dart';
import '../utils/helpers.dart';

/// Profile tab page - user settings and profile management
class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  static const List<FeatureItem> _items = [
    FeatureItem('Child Profiles', Icons.face_rounded, AppColors.purple),
    FeatureItem(
      'Daily Reminders',
      Icons.notifications_active_rounded,
      AppColors.yellow,
    ),
    FeatureItem('Account Settings', Icons.settings_rounded, AppColors.teal),
    FeatureItem(
      'Offline Content',
      Icons.cloud_download_rounded,
      AppColors.pink,
    ),
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
              'Profile 👤',
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
