import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/child.dart';
import '../model/result_model.dart';
import '../utils/app_colors.dart';

class StarsBadgesPage extends StatefulWidget {
  final String childId;

  const StarsBadgesPage({super.key, required this.childId});

  @override
  State<StarsBadgesPage> createState() => _StarsBadgesPageState();
}

class _StarsBadgesPageState extends State<StarsBadgesPage> {
  late Future<int> _totalStarsFuture;

  @override
  void initState() {
    super.initState();
    _totalStarsFuture = _loadTotalStars();
  }

  Future<int> _loadTotalStars() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('children')
          .doc(widget.childId)
          .get();

      final child = ChildModel.fromDoc(doc);
      return child.totalStars;
    } catch (error) {
      debugPrint('Failed to load total stars: $error');
      if (!mounted) return 0;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not load star count.')),
      );
      return 0;
    }
  }

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
        .limit(10)
        .snapshots();
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stars & Badges'),
        backgroundColor: AppColors.yellow,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: FutureBuilder<int>(
          future: _totalStarsFuture,
          builder: (context, starsSnapshot) {
            if (starsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final totalStars = starsSnapshot.data ?? 0;

            return StreamBuilder<QuerySnapshot>(
              stream: _resultsStream(),
              builder: (context, resultsSnapshot) {
                if (resultsSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final results = (resultsSnapshot.data?.docs ?? [])
                    .map(ResultModel.fromDoc)
                    .toList();

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Total Stars Display
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.yellow.withOpacity(0.2),
                            AppColors.yellow.withOpacity(0.05),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: AppColors.yellow.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: AppColors.yellow,
                            size: 64,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '$totalStars',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkGray,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            totalStars == 1 ? 'Total Star' : 'Total Stars',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Recent Results
                    const Text(
                      'Recent Quizzes',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (results.isEmpty)
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
                                Icons.quiz_rounded,
                                color: Colors.grey,
                                size: 48,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'No quizzes completed yet!',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.darkGray,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Complete a quiz to see your results here.',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      ...results.map(
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
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: AppColors.teal.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.quiz_rounded,
                                    color: AppColors.teal,
                                  ),
                                ),
                                const SizedBox(width: 16),
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
                                        '${result.score}/${result.totalQuestions} correct • ${_formatDate(result.completedAt)}',
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
                                    color: AppColors.yellow.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: AppColors.yellow,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${result.stars}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.darkGray,
                                        ),
                                      ),
                                    ],
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
            );
          },
        ),
      ),
    );
  }
}
