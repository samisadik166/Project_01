import 'package:flutter/material.dart';
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
class HomeTab extends StatelessWidget {
  final String userName;
  final VoidCallback onLogout;

  const HomeTab({super.key, required this.userName, required this.onLogout});

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

  void _navigateToFeature(BuildContext context, int index) {
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
    Navigator.of(context).push(routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 30),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.pink, AppColors.yellow],
                ),
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.emoji_emotions_rounded,
                      color: AppColors.pink,
                      size: 36,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hi, $userName! 👋',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'What do you want to learn today?',
                          style: TextStyle(fontSize: 14, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: onLogout,
                    tooltip: 'Log out',
                    icon: const Icon(Icons.logout_rounded, color: Colors.white),
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
                  onTap: () => _navigateToFeature(context, index),
                );
              }, childCount: _features.length),
            ),
          ),
        ],
      ),
    );
  }
}
