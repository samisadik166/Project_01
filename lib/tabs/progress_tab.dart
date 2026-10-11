import 'package:flutter/material.dart';
import '../data/progress_repository.dart';
import '../features/certificates_page.dart';
import '../features/performance_reports_page.dart';
import '../features/stars_badges_page.dart';
import '../utils/app_colors.dart';
import '../utils/feature_tile.dart';
import '../utils/helpers.dart';

class ProgressTab extends StatefulWidget {
  final String? childId;

  const ProgressTab({super.key, required this.childId});

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  final ProgressRepository _repository = FirestoreProgressRepository();

  static const List<FeatureItem> _items = [
    FeatureItem('Stars & Badges', Icons.star_rounded, AppColors.yellow),
    FeatureItem('Performance Reports', Icons.analytics_rounded, AppColors.pink),
    FeatureItem(
      'Certificates',
      Icons.workspace_premium_rounded,
      AppColors.teal,
    ),
  ];

  void _handleTileTap(String label, String childId) async {
    if (label == 'Stars & Badges') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => StarsBadgesPage(childId: childId)),
      );
      return;
    }

    if (label == 'Performance Reports') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PerformanceReportsPage(
            childId: childId,
            repository: _repository,
          ),
        ),
      );
      return;
    }

    if (label == 'Certificates') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CertificatesPage(
            childId: childId,
            repository: _repository,
          ),
        ),
      );
      return;
    }

    showComingSoon(context, label);
  }

  @override
  Widget build(BuildContext context) {
    final childId = widget.childId;
    if (childId == null) {
      return const SafeArea(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No child profile found yet.\nAdd a child to start tracking progress.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGray,
              ),
            ),
          ),
        ),
      );
    }

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Progress',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 16),
          ..._items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: FeatureListTile(
                item: item,
                onTap: () => _handleTileTap(item.label, childId),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
