import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// COLORS (shared across this file — move to a theme.dart once more screens exist)
// ---------------------------------------------------------------------------
class AppColors {
  static const pink = Color(0xFFFF6B9D);
  static const yellow = Color(0xFFFFC93C);
  static const teal = Color(0xFF4EE0C1);
  static const purple = Color(0xFF9B7BFF);
  static const cream = Color(0xFFFFF8E7);
}

// ---------------------------------------------------------------------------
// HOME PAGE — hosts the bottom navigation bar and switches between 5 tabs
// ---------------------------------------------------------------------------
class HomePage extends StatefulWidget {
  final String userName;
  const HomePage({super.key, this.userName = 'Explorer'});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  // one page per bottom nav tab — kept in a list so switching tabs
  // is just changing an index, no rebuilding widgets from scratch
  late final List<Widget> _pages = [
    _HomeTab(userName: widget.userName),
    const _LearnTab(),
    const _PlayTab(),
    const _ProgressTab(),
    const _ProfileTab(),
  ];

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      // IndexedStack keeps every tab's state alive in the background
      // instead of destroying/rebuilding it every time you switch tabs
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onTabTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.pink,
            unselectedItemColor: Colors.grey.shade400,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            showUnselectedLabels: true,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_rounded),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.menu_book_rounded),
                label: 'Learn',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.sports_esports_rounded),
                label: 'Play',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.emoji_events_rounded),
                label: 'Progress',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_rounded),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// SHARED: what happens when a feature tile is tapped (not built yet)
// ---------------------------------------------------------------------------
void _showComingSoon(BuildContext context, String featureName) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$featureName is coming soon! 🚧 We\'ll build this next.'),
      backgroundColor: AppColors.teal,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

// ---------------------------------------------------------------------------
// TAB 1 — HOME: greeting + grid of every core feature
// ---------------------------------------------------------------------------
class _HomeTab extends StatelessWidget {
  final String userName;
  const _HomeTab({required this.userName});

  static const List<_FeatureItem> _features = [
    _FeatureItem('Alphabet', Icons.abc_rounded, AppColors.pink),
    _FeatureItem('Numbers', Icons.pin_rounded, AppColors.yellow),
    _FeatureItem('Shapes & Colors', Icons.category_rounded, AppColors.teal),
    _FeatureItem('Animals', Icons.pets_rounded, AppColors.purple),
    _FeatureItem('Fruits & Veggies', Icons.eco_rounded, AppColors.pink),
    _FeatureItem('Vehicles', Icons.directions_bus_rounded, AppColors.yellow),
    _FeatureItem('Stories', Icons.auto_stories_rounded, AppColors.teal),
    _FeatureItem('Drawing', Icons.brush_rounded, AppColors.purple),
    _FeatureItem('Quizzes', Icons.quiz_rounded, AppColors.pink),
    _FeatureItem('Games', Icons.sports_esports_rounded, AppColors.yellow),
    _FeatureItem('Rewards', Icons.emoji_events_rounded, AppColors.teal),
    _FeatureItem(
      'Daily Reminders',
      Icons.notifications_active_rounded,
      AppColors.purple,
    ),
  ];

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
                return _FeatureTile(
                  feature: feature,
                  onTap: () => _showComingSoon(context, feature.label),
                );
              }, childCount: _features.length),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem {
  final String label;
  final IconData icon;
  final Color color;
  const _FeatureItem(this.label, this.icon, this.color);
}

class _FeatureTile extends StatelessWidget {
  final _FeatureItem feature;
  final VoidCallback onTap;
  const _FeatureTile({required this.feature, required this.onTap});

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
              color: Color(0xFF3A3A3A),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// TAB 2 — LEARN: alphabet, numbers, shapes/colors, animals, stories
// ---------------------------------------------------------------------------
class _LearnTab extends StatelessWidget {
  const _LearnTab();

  static const List<_FeatureItem> _items = [
    _FeatureItem('Alphabet A–Z', Icons.abc_rounded, AppColors.pink),
    _FeatureItem('Numbers & Counting', Icons.pin_rounded, AppColors.yellow),
    _FeatureItem('Shapes & Colors', Icons.category_rounded, AppColors.teal),
    _FeatureItem('Animals', Icons.pets_rounded, AppColors.purple),
    _FeatureItem(
      'Fruits & Vehicles',
      Icons.directions_bus_rounded,
      AppColors.pink,
    ),
    _FeatureItem('Stories & Audio', Icons.auto_stories_rounded, AppColors.teal),
  ];

  @override
  Widget build(BuildContext context) {
    return _ListTabScaffold(title: 'Learn 📚', items: _items);
  }
}

// ---------------------------------------------------------------------------
// TAB 3 — PLAY: games, drawing/coloring, quizzes
// ---------------------------------------------------------------------------
class _PlayTab extends StatelessWidget {
  const _PlayTab();

  static const List<_FeatureItem> _items = [
    _FeatureItem(
      'Interactive Games',
      Icons.sports_esports_rounded,
      AppColors.yellow,
    ),
    _FeatureItem('Drawing & Coloring', Icons.brush_rounded, AppColors.purple),
    _FeatureItem('Quizzes', Icons.quiz_rounded, AppColors.pink),
  ];

  @override
  Widget build(BuildContext context) {
    return _ListTabScaffold(title: 'Play 🎮', items: _items);
  }
}

// ---------------------------------------------------------------------------
// TAB 4 — PROGRESS: rewards, badges, performance reports
// ---------------------------------------------------------------------------
class _ProgressTab extends StatelessWidget {
  const _ProgressTab();

  static const List<_FeatureItem> _items = [
    _FeatureItem(
      'Stars & Badges',
      Icons.emoji_events_rounded,
      AppColors.yellow,
    ),
    _FeatureItem(
      'Certificates',
      Icons.workspace_premium_rounded,
      AppColors.teal,
    ),
    _FeatureItem(
      'Performance Reports',
      Icons.bar_chart_rounded,
      AppColors.pink,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _ListTabScaffold(title: 'Progress 🏆', items: _items);
  }
}

// ---------------------------------------------------------------------------
// TAB 5 — PROFILE: child profile management, reminders, account settings
// ---------------------------------------------------------------------------
class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  static const List<_FeatureItem> _items = [
    _FeatureItem('Child Profiles', Icons.face_rounded, AppColors.purple),
    _FeatureItem(
      'Daily Reminders',
      Icons.notifications_active_rounded,
      AppColors.yellow,
    ),
    _FeatureItem('Account Settings', Icons.settings_rounded, AppColors.teal),
    _FeatureItem(
      'Offline Content',
      Icons.cloud_download_rounded,
      AppColors.pink,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _ListTabScaffold(title: 'Profile 👤', items: _items);
  }
}

// ---------------------------------------------------------------------------
// SHARED LIST LAYOUT — reused by Learn / Play / Progress / Profile tabs
// ---------------------------------------------------------------------------
class _ListTabScaffold extends StatelessWidget {
  final String title;
  final List<_FeatureItem> items;
  const _ListTabScaffold({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w800,
                color: Color(0xFF3A3A3A),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                return GestureDetector(
                  onTap: () => _showComingSoon(context, item.label),
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
                              color: Color(0xFF3A3A3A),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
