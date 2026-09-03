import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Data model for a feature
class FeatureItem {
  final String label;
  final IconData icon;
  final Color color;

  const FeatureItem(this.label, this.icon, this.color);
}

/// Reusable tile widget for grid display
class FeatureTile extends StatelessWidget {
  final FeatureItem feature;
  final VoidCallback onTap;

  const FeatureTile({super.key, required this.feature, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: feature.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: feature.color.withOpacity(0.4),
                  width: 2,
                ),
              ),
              child: Icon(feature.icon, color: feature.color, size: 32),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            feature.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }
}

/// Reusable list item tile widget
class FeatureListTile extends StatelessWidget {
  final FeatureItem item;
  final VoidCallback onTap;

  const FeatureListTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, color: item.color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                item.label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGray,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
