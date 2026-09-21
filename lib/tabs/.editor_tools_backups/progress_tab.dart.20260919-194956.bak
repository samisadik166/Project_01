import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/child.dart';
import '../model/result_model.dart';
import '../utils/app_colors.dart';
import '../utils/feature_tile.dart';
import '../widgets/parental_gate.dart';

class ProgressTab extends StatefulWidget {
  const ProgressTab({super.key});

  @override
  State<ProgressTab> createState() => _ProgressTabState();
}

class _ProgressTabState extends State<ProgressTab> {
  late Future<String?> _activeChildIdFuture;

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

  Future<int> _loadTotalStars(String childId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('children')
          .doc(childId)
          .get();

      final child = ChildModel.fromDoc(doc);
      return child.totalStars;
    } catch (error) {
      debugPrint('Failed to load total stars: $error');
      return 0;
    }
  }

  Stream<QuerySnapshot> _resultsStream(String childId) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('children')
        .doc(childId)
        .collection('results')
        .orderBy('completedAt', descending: true)
        .limit(10)
        .snapshots();
  }

  Future<void> _handleCertificatesTap() async {
    final allowed = await showParentalGate(context);
    if (!mounted || !allowed) return;
    final childId = await _activeChildIdFuture;
    if (!mounted || childId == null) return;

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('children')
          .doc(childId)
          .collection('results')
          .where('score', isGreaterThanOrEqualTo: 3)
          .limit(1)
          .get();

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Learning certificates'),
          content: snapshot.docs.isEmpty
              ? const Text(
                  'Complete a quiz with 3 or more correct answers to unlock your first certificate!',
                )
              : const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.workspace_premium_rounded,
                      color: AppColors.yellow,
                      size: 72,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Amazing work! Your first certificate is unlocked.',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
          actions: [
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Keep learning'),
            ),
          ],
        ),
      );
    } catch (error) {
      debugPrint('Failed to load certificate status: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load certificates right now.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<String?>(
        future: _activeChildIdFuture,
        builder: (context, childSnapshot) {
          final childId = childSnapshot.data;
          if (childId == null) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No child profile found yet.',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGray,
                  ),
                ),
              ),
            );
          }

          return FutureBuilder<int>(
            future: _loadTotalStars(childId),
            builder: (context, starsSnapshot) {
              final totalStars = starsSnapshot.data ?? 0;

              return StreamBuilder<QuerySnapshot>(
                stream: _resultsStream(childId),
                builder: (context, resultsSnapshot) {
                  final results = (resultsSnapshot.data?.docs ?? [])
                      .map(ResultModel.fromDoc)
                      .toList();

                  final averageScore = results.isEmpty
                      ? 0.0
                      : results
                                .map(
                                  (result) =>
                                      (result.score /
                                          math.max(1, result.totalQuestions)) *
                                      100,
                                )
                                .reduce((a, b) => a + b) /
                            results.length;
                  final quizCount = results.map((r) => r.quizId).toSet().length;

                  return ListView(
                    padding: const EdgeInsets.all(20),
                    children: [
                      const Text(
                        'Progress 🏆',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ProgressCard(
                        title: 'Stars & Badges',
                        accentColor: AppColors.yellow,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.emoji_events_rounded,
                                  color: AppColors.yellow,
                                  size: 32,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  '$totalStars stars',
                                  style: const TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkGray,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Recent results',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkGray,
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (results.isEmpty)
                              const Text(
                                'No quiz results yet. Start learning to earn stars!',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              )
                            else
                              ...results.map(
                                (result) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: AppColors.yellow,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${result.score}/${result.totalQuestions} • ${result.stars} stars',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.darkGray,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _ProgressCard(
                        title: 'Performance Reports',
                        accentColor: AppColors.pink,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quick snapshot',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkGray,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _MetricTile(
                                    label: 'Quizzes',
                                    value: '$quizCount',
                                    color: AppColors.teal,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _MetricTile(
                                    label: 'Avg score',
                                    value:
                                        '${averageScore.toStringAsFixed(0)}%',
                                    color: AppColors.pink,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      FeatureListTile(
                        item: const FeatureItem(
                          'Certificates',
                          Icons.workspace_premium_rounded,
                          AppColors.teal,
                        ),
                        onTap: _handleCertificatesTap,
                      ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class _ProgressCard extends StatelessWidget {
  final String title;
  final Color accentColor;
  final Widget child;

  const _ProgressCard({
    required this.title,
    required this.accentColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }
}
