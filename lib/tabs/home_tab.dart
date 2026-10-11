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
  final List<ChildModel> children;
  final String? selectedChildId;
  final Future<void> Function([String?]) onChildrenChanged;

  const HomeTab({
    super.key,
    required this.userName,
    required this.onLogout,
    required this.children,
    required this.selectedChildId,
    required this.onChildrenChanged,
  });

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
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
    final childId = widget.selectedChildId;
    if (childId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a child profile before starting an activity.')),
      );
      return;
    }

    final routes = [
      MaterialPageRoute(builder: (_) => AlphabetPage(childId: childId)),
      MaterialPageRoute(builder: (_) => NumbersPage(childId: childId)),
      MaterialPageRoute(builder: (_) => const ShapesColorsPage()),
      MaterialPageRoute(builder: (_) => const AnimalsPage()),
      MaterialPageRoute(builder: (_) => const FruitsVeggiesPage()),
      MaterialPageRoute(builder: (_) => const VehiclesPage()),
      MaterialPageRoute(builder: (_) => const StoriesPage()),
      MaterialPageRoute(builder: (_) => DrawingPage(childId: childId)),
      MaterialPageRoute(builder: (_) => QuizzesPage(childId: childId)),
      MaterialPageRoute(builder: (_) => GamesPage(childId: childId)),
      MaterialPageRoute(builder: (_) => const RewardsPage()),
      MaterialPageRoute(builder: (_) => const DailyRemindersPage()),
    ];

    await Navigator.of(context).push(routes[index]);
    await widget.onChildrenChanged();
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
    final childIndex = widget.children.indexWhere(
      (profile) => profile.childId == widget.selectedChildId,
    );
    final child = childIndex < 0 ? null : widget.children[childIndex];
    final displayName = child?.name.trim().isNotEmpty == true
        ? child!.name
        : widget.userName;
    final avatarId = child?.avatarId ?? 'bear_1';
    final avatarColor = _avatarColor(avatarId);

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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 66,
                        height: 66,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.96),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Icon(
                          _avatarIcon(avatarId),
                          color: avatarColor,
                          size: 34,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hi, $displayName! 👋',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    color: Color(0x33000000),
                                    offset: Offset(0, 2),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                borderRadius: BorderRadius.circular(18),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.08),
                                    blurRadius: 8,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    color: Color(0xFFFFC93C),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${child?.totalStars ?? 0} stars',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.darkGray,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: IconButton(
                          onPressed: widget.onLogout,
                          tooltip: 'Log out',
                          splashRadius: 20,
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: AppColors.darkGray,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
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
