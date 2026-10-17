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

/// Home tab page - main dashboard with all features.
///
/// UI only: navigation, data and state are unchanged from before.
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
    FeatureItem('Animals', Icons.pets_rounded, AppColors.green),
    FeatureItem('Fruits & Veggies', Icons.eco_rounded, AppColors.orange),
    FeatureItem('Vehicles', Icons.directions_bus_rounded, AppColors.sky),
    FeatureItem('Stories', Icons.auto_stories_rounded, AppColors.purple),
    FeatureItem('Drawing', Icons.brush_rounded, AppColors.pink),
    FeatureItem('Quizzes', Icons.quiz_rounded, AppColors.yellow),
    FeatureItem('Games', Icons.sports_esports_rounded, AppColors.teal),
    FeatureItem('Rewards', Icons.emoji_events_rounded, AppColors.orange),
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
      MaterialPageRoute(builder: (_) => VehiclesPage(childId: childId)),
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
    final totalStars = child?.totalStars ?? 0;

    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 2 columns on phones for big tap targets, 3 on wider screens.
          final columns = constraints.maxWidth >= 600 ? 3 : 2;
          final childAspectRatio = columns == 3 ? 0.92 : 0.95;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: _buildHeader(
                  displayName: displayName,
                  avatarId: avatarId,
                  avatarColor: avatarColor,
                  totalStars: totalStars,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: childAspectRatio,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final feature = _features[index];
                      return _CategoryCard(
                        label: feature.label,
                        icon: feature.icon,
                        color: feature.color,
                        onTap: () => _navigateToFeature(context, index),
                      );
                    },
                    childCount: _features.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// Gradient greeting banner. The subtle dark scrim keeps the white text
  /// readable across all three accent colours.
  Widget _buildHeader({
    required String displayName,
    required String avatarId,
    required Color avatarColor,
    required int totalStars,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.pink, AppColors.purple, AppColors.sky],
        ),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0x29000000), Color(0x4D000000)],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 20, 26),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(_avatarIcon(avatarId), color: avatarColor, size: 36),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi, $displayName!',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 28,
                          height: 1.1,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Color(0x66000000),
                              offset: Offset(0, 2),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Ready to learn and play? 🌟',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white.withValues(alpha: 0.92),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.10),
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
                              color: AppColors.yellow,
                              size: 22,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$totalStars stars',
                              style: const TextStyle(
                                fontSize: 16,
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
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: IconButton(
                    onPressed: widget.onLogout,
                    tooltip: 'Log out',
                    splashRadius: 24,
                    icon: const Icon(
                      Icons.logout_rounded,
                      color: AppColors.darkGray,
                      size: 26,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// A single category card: solid accent badge with a legible icon, plus a
/// bold dark label on white for strong contrast.
class _CategoryCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _CategoryCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  /// White on dark accents, dark on light ones, so the icon stays readable.
  Color get _iconForeground =>
      color.computeLuminance() > 0.55 ? AppColors.darkGray : Colors.white;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: color, width: 2.5),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 64,
                height: 64,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: 0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(icon, color: _iconForeground, size: 34),
              ),
              const SizedBox(height: 12),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
