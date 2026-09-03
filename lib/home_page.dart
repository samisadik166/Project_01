import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'utils/app_colors.dart';
import 'tabs/home_tab.dart';
import 'tabs/learn_tab.dart';
import 'tabs/play_tab.dart';
import 'tabs/progress_tab.dart';
import 'tabs/profile_tab.dart';

// HOME PAGE — hosts the bottom navigation bar and switches between 5 tabs

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
    const LearnTab(),
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
