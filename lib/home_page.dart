import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'login_page.dart';
import 'model/child.dart';
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
  List<ChildModel> _children = [];
  String? _selectedChildId;
  bool _childrenLoading = true;
  Object? _childrenError;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  Future<void> _loadChildren({String? preferredChildId}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        setState(() {
          _children = [];
          _selectedChildId = null;
          _childrenLoading = false;
          _childrenError = null;
        });
      }
      return;
    }

    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(uid);
      final results = await Future.wait([
        userRef.collection('children').orderBy('createdAt').get(),
        userRef.get(),
      ]);
      final children = (results[0] as QuerySnapshot<Map<String, dynamic>>).docs
          .map(ChildModel.fromDoc)
          .toList();
      final userData =
          (results[1] as DocumentSnapshot<Map<String, dynamic>>).data() ??
          const <String, dynamic>{};
      final savedChildId =
          preferredChildId ?? userData['activeChildId']?.toString();
      final savedChildExists = children.any(
        (child) => child.childId == savedChildId,
      );
      final selectedChildId = savedChildExists
          ? savedChildId
          : children.isEmpty
          ? null
          : children.first.childId;

      if (selectedChildId != null && selectedChildId != savedChildId) {
        await userRef.set({
          'activeChildId': selectedChildId,
        }, SetOptions(merge: true));
      }

      if (!mounted) return;
      setState(() {
        _children = children;
        _selectedChildId = selectedChildId;
        _childrenLoading = false;
        _childrenError = null;
      });
    } catch (error) {
      debugPrint('Could not load child profiles: $error');
      if (!mounted) return;
      setState(() {
        _childrenLoading = false;
        _childrenError = error;
      });
    }
  }

  Future<void> _selectChild(String childId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null || !_children.any((child) => child.childId == childId)) {
      return;
    }

    try {
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'activeChildId': childId,
      }, SetOptions(merge: true));
      if (!mounted) return;
      setState(() => _selectedChildId = childId);
    } catch (error) {
      debugPrint('Could not select child profile: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not switch child profiles. Please try again.'),
        ),
      );
    }
  }

  Future<void> _refreshChildren([String? preferredChildId]) async {
    await _loadChildren(preferredChildId: preferredChildId);
  }

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
    final pages = [
      HomeTab(
        userName: widget.userName,
        onLogout: _handleLogout,
        children: _children,
        selectedChildId: _selectedChildId,
        onChildrenChanged: _refreshChildren,
      ),
      PlayTab(childId: _selectedChildId),
      ProgressTab(childId: _selectedChildId),
      ProfileTab(
        children: _children,
        selectedChildId: _selectedChildId,
        onChildSelected: _selectChild,
        onChildrenChanged: _refreshChildren,
        childrenLoading: _childrenLoading,
        childrenError: _childrenError,
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.cream,
      // IndexedStack keeps every tab's state alive in the background
      // instead of destroying/rebuilding it every time you switch tabs
      body: IndexedStack(index: _selectedIndex, children: pages),
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
