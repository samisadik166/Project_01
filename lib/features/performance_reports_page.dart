import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/result_model.dart';
import '../utils/app_colors.dart';

class PerformanceReportsPage extends StatefulWidget {
  final String childId;

  const PerformanceReportsPage({super.key, required this.childId});

  @override
  State<PerformanceReportsPage> createState() => _PerformanceReportsPageState();
}

class _PerformanceReportsPageState extends State<PerformanceReportsPage> {
  Stream<QuerySnapshot> _resultsStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Stream.empty();
    }

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('children')
        .doc(widget.childId)
        .collection('results')
        .orderBy('completedAt', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Performance Reports'),
        backgroundColor: AppColors.pink,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: _resultsStream(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final results = (snapshot.data?.docs ?? [])
                .map(ResultModel.fromDoc)
                .toList();

            final quizCount = results.length;
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

            if (results.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
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
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.analytics_rounded,
                            color: Colors.grey,
                            size: 48,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No data yet',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGray,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Complete quizzes to see performance stats here.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Summary Stats
                const Text(
                  'Summary',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _MetricCard(
                        label: 'Quizzes Completed',
                        value: '$quizCount',
                        icon: Icons.quiz_rounded,
                        color: AppColors.teal,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _MetricCard(
                        label: 'Average Score',
                        value: '${averageScore.toStringAsFixed(0)}%',
                        icon: Icons.trending_up_rounded,
                        color: AppColors.pink,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Performance Breakdown
                const Text(
                  'Performance Breakdown',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(20),
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
                      _PerformanceRow(
                        label: 'Perfect scores (100%)',
                        value: results
                            .where((r) =>
                                r.score == r.totalQuestions && r.totalQuestions > 0)
                            .length
                            .toString(),
                      ),
                      const SizedBox(height: 12),
                      _PerformanceRow(
                        label: 'Good scores (≥75%)',
                        value: results
                            .where((r) =>
                                r.totalQuestions > 0 &&
                                (r.score / r.totalQuestions) >= 0.75 &&
                                r.score < r.totalQuestions)
                            .length
                            .toString(),
                      ),
                      const SizedBox(height: 12),
                      _PerformanceRow(
                        label: 'Needs improvement (<75%)',
                        value: results
                            .where((r) =>
                                r.totalQuestions > 0 &&
                                (r.score / r.totalQuestions) < 0.75)
                            .length
                            .toString(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Recent Activity
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 12),
                ...results.take(5).map(
                      (result) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
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
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      result.quizId,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.darkGray,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${result.score}/${result.totalQuestions} correct',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getScoreColor(result.score, result.totalQuestions)
                                      .withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '${((result.score / math.max(1, result.totalQuestions)) * 100).toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: _getScoreColor(result.score, result.totalQuestions),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
              ],
            );
          },
        ),
      ),
    );
  }

  Color _getScoreColor(int score, int total) {
    if (total == 0) return Colors.grey;
    final percentage = score / total;
    if (percentage >= 0.75) return AppColors.teal;
    if (percentage >= 0.5) return AppColors.yellow;
    return AppColors.pink;
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withOpacity(0.2),
            color.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceRow extends StatelessWidget {
  final String label;
  final String value;

  const _PerformanceRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.darkGray,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.lightGray,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.darkGray,
            ),
          ),
        ),
      ],
    );
  }
}
