import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'utils/app_colors.dart';
import 'tabs/home_tab.dart';
import 'tabs/play_tab.dart';
import 'tabs/progress_tab.dart';
import 'tabs/profile_tab.dart';

// HOME PAGE — hosts the bottom navigation bar and switches between 4 tabs

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
    HomeTab(userName: widget.userName, onLogout: _handleLogout),
    const PlayTab(),
    const ProgressTab(),
    const ProfileTab(),
  ];

  void _onTabTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Future<void> _handleLogout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;

    try {
      await FirebaseAuth.instance.signOut();
      debugPrint('Logged out');
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } on FirebaseAuthException catch (error) {
      debugPrint('Logout failed: ${error.code}');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not log out. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      // IndexedStack keeps every tab's state alive in the background
      // instead of destroying/rebuilding it every time you switch tabs
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _KidBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

class _KidBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _KidBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  static const _items = [
    (label: 'Home', icon: Icons.home_rounded, color: AppColors.pink),
    (
      label: 'Play',
      icon: Icons.sports_esports_rounded,
      color: AppColors.yellow,
    ),
    (
      label: 'Progress',
      icon: Icons.emoji_events_rounded,
      color: AppColors.teal,
    ),
    (label: 'Profile', icon: Icons.person_rounded, color: AppColors.purple),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.fromLTRB(12, 8, 12, 10),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFFFFFFF), Color(0xFFFFF2F8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: AppColors.purple.withOpacity(0.18),
              blurRadius: 18,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            for (var index = 0; index < _items.length; index++)
              Expanded(
                child: _NavButton(
                  item: _items[index],
                  selected: currentIndex == index,
                  onTap: () => onTap(index),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final ({String label, IconData icon, Color color}) item;
  final bool selected;
  final VoidCallback onTap;

  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: selected ? item.color : Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: SizedBox(
            height: 64,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  size: 27,
                  color: selected ? Colors.white : item.color,
                ),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: selected ? Colors.white : AppColors.darkGray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
