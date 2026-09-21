import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../features/performance_reports_page.dart';
import '../features/stars_badges_page.dart';
import '../utils/app_colors.dart';
import '../utils/feature_tile.dart';
import '../utils/helpers.dart';

class ProgressTab extends StatefulWidget {
  const ProgressTab({super.key});

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  late Future<String?> _activeChildIdFuture;

  static const List<FeatureItem> _items = [
    FeatureItem('Stars & Badges', Icons.star_rounded, AppColors.yellow),
    FeatureItem(
      'Performance Reports',
      Icons.analytics_rounded,
      AppColors.pink,
    ),
    FeatureItem(
      'Certificates',
      Icons.workspace_premium_rounded,
      AppColors.teal,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _activeChildIdFuture = _loadActiveChildId();
  }

  Future<String?> _loadActiveChildId() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('children')
          .orderBy('createdAt', descending: false)
          .limit(1)
          .get();

      return snapshot.docs.isEmpty ? null : snapshot.docs.first.id;
    } catch (error) {
      debugPrint('Failed to load active child: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not load progress data.')),
        );
      }
      return null;
    }
  }

  void _handleTileTap(String label, String childId) {
    if (label == 'Stars & Badges') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => StarsBadgesPage(childId: childId)),
      );
      return;
    }

    if (label == 'Performance Reports') {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => PerformanceReportsPage(childId: childId),
        ),
      );
      return;
    }

    showComingSoon(context, label);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<String?>(
        future: _activeChildIdFuture,
        builder: (context, childSnapshot) {
          if (childSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final childId = childSnapshot.data;
          if (childId == null) {
            return const Center(
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
            );
          }

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text(
                'Progress 📊',
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
          );
        },
      ),
    );
  }
}
