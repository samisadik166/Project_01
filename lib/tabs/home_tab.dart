import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/child.dart';
import '../utils/app_colors.dart';
import '../utils/feature_tile.dart';
import '../features/alphabet_page.dart';
import '../features/numbers_page.dart';
import '../features/shapes_colors_page.dart';
import '../features/animals_page.dart';
import '../features/fruits_veggies_page.dart';
import '../features/vehicles_page.dart';
import '../features/stories_page.dart';
import '../features/drawing_page.dart';
import '../features/quizzes_page.dart';
import '../features/games_page.dart';
import '../features/rewards_page.dart';
import '../features/daily_reminders_page.dart';

/// Home tab page - main dashboard with all features
class HomeTab extends StatefulWidget {
  final String userName;
  final VoidCallback onLogout;

  const HomeTab({super.key, required this.userName, required this.onLogout});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  late Future<ChildModel> _activeChildFuture;

  @override
  void initState() {
    super.initState();
    _activeChildFuture = _loadActiveChild();
  }

  Future<ChildModel> _loadActiveChild() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return ChildModel(
        childId: 'local',
        name: widget.userName,
        age: 0,
        avatarId: 'bear_1',
        createdAt: DateTime.now(),
        totalStars: 0,
      );
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('children')
          .orderBy('createdAt', descending: false)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return ChildModel.fromDoc(snapshot.docs.first);
      }
    } catch (error) {
      debugPrint('Could not load active child for home tab: $error');
    }

    return ChildModel(
      childId: 'local',
      name: widget.userName,
      age: 0,
      avatarId: 'bear_1',
      createdAt: DateTime.now(),
      totalStars: 0,
    );
  }

  Future<void> _refreshActiveChild() async {
    setState(() {
      _activeChildFuture = _loadActiveChild();
    });
  }

  static const List<FeatureItem> _features = [
    FeatureItem('Alphabet', Icons.abc_rounded, AppColors.pink),
    FeatureItem('Numbers', Icons.pin_rounded, AppColors.yellow),
    FeatureItem('Shapes & Colors', Icons.category_rounded, AppColors.teal),
    FeatureItem('Animals', Icons.pets_rounded, AppColors.purple),
    FeatureItem('Fruits & Veggies', Icons.eco_rounded, AppColors.pink),
    FeatureItem('Vehicles', Icons.directions_bus_rounded, AppColors.yellow),
    FeatureItem('Stories', Icons.auto_stories_rounded, AppColors.teal),
    FeatureItem('Drawing', Icons.brush_rounded, AppColors.purple),
    FeatureItem('Quizzes', Icons.quiz_rounded, AppColors.pink),
    FeatureItem('Games', Icons.sports_esports_rounded, AppColors.yellow),
    FeatureItem('Rewards', Icons.emoji_events_rounded, AppColors.teal),
    FeatureItem(
      'Daily Reminders',
      Icons.notifications_active_rounded,
      AppColors.purple,
    ),
  ];

  Future<void> _navigateToFeature(BuildContext context, int index) async {
    final routes = [
      MaterialPageRoute(builder: (_) => const AlphabetPage()),
      MaterialPageRoute(builder: (_) => const NumbersPage()),
      MaterialPageRoute(builder: (_) => const ShapesColorsPage()),
      MaterialPageRoute(builder: (_) => const AnimalsPage()),
      MaterialPageRoute(builder: (_) => const FruitsVeggiesPage()),
      MaterialPageRoute(builder: (_) => const VehiclesPage()),
      MaterialPageRoute(builder: (_) => const StoriesPage()),
      MaterialPageRoute(builder: (_) => const DrawingPage()),
      MaterialPageRoute(builder: (_) => const QuizzesPage()),
      MaterialPageRoute(builder: (_) => const GamesPage()),
      MaterialPageRoute(builder: (_) => const RewardsPage()),
      MaterialPageRoute(builder: (_) => const DailyRemindersPage()),
    ];

    await Navigator.of(context).push(routes[index]);
    await _refreshActiveChild();
  }

  IconData _avatarIcon(String avatarId) {
    switch (avatarId) {
      case 'star_1':
        return Icons.star_rounded;
      case 'cat_1':
        return Icons.emoji_nature_rounded;
      case 'rocket_1':
        return Icons.rocket_launch_rounded;
      case 'bear_1':
      default:
        return Icons.pets_rounded;
    }
  }

  Color _avatarColor(String avatarId) {
    switch (avatarId) {
      case 'star_1':
        return AppColors.yellow;
      case 'cat_1':
        return AppColors.teal;
      case 'rocket_1':
        return AppColors.purple;
      case 'bear_1':
      default:
        return AppColors.pink;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<ChildModel>(
      future: _activeChildFuture,
      builder: (context, snapshot) {
        final child =
            snapshot.data ??
            ChildModel(
              childId: 'local',
              name: widget.userName,
              age: 0,
              avatarId: 'bear_1',
              createdAt: DateTime.now(),
              totalStars: 0,
            );

        final displayName = child.name.trim().isEmpty
            ? widget.userName
            : child.name;
        final avatarColor = _avatarColor(child.avatarId);

        return SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.yellow.withOpacity(0.92),
                        AppColors.pink.withOpacity(0.78),
                        AppColors.teal.withOpacity(0.7),
                      ],
                    ),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(32),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.purple.withOpacity(0.12),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 62,
                        height: 62,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _avatarIcon(child.avatarId),
                          color: avatarColor,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, $displayName! 👋',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${child.totalStars} stars',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: widget.onLogout,
                        tooltip: 'Log out',
                        icon: const Icon(
                          Icons.logout_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(20),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final feature = _features[index];
                    return FeatureTile(
                      feature: feature,
                      onTap: () async => _navigateToFeature(context, index),
                    );
                  }, childCount: _features.length),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
