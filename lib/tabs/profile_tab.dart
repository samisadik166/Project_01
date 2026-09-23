import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/child.dart';
import '../utils/app_colors.dart';
import '../utils/feature_tile.dart';
import '../add_child_page.dart';

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  static const List<FeatureItem> _items = [
    FeatureItem('Child Profiles', Icons.face_rounded, AppColors.purple),
    FeatureItem(
      'Daily Reminders',
      Icons.notifications_active_rounded,
      AppColors.yellow,
    ),
    FeatureItem('Account Settings', Icons.settings_rounded, AppColors.teal),
    FeatureItem(
      'Offline Content',
      Icons.cloud_download_rounded,
      AppColors.pink,
    ),
  ];

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  late Future<List<ChildModel>> _childrenFuture;

  @override
  void initState() {
    super.initState();
    _childrenFuture = _loadChildren();
  }

  Future<List<ChildModel>> _loadChildren() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('children')
          .orderBy('createdAt', descending: false)
          .get();

      return snapshot.docs.map(ChildModel.fromDoc).toList();
    } catch (error) {
      debugPrint('Failed to load children: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not load your children right now.'),
          ),
        );
      }
      return [];
    }
  }

  Future<void> _refreshChildren() async {
    setState(() => _childrenFuture = _loadChildren());
  }

  void _showFeatureComingSoon(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label is coming soon! 🚧'),
        backgroundColor: AppColors.teal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: AppColors.darkGray,
            ),
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<ChildModel>>(
            future: _childrenFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              final children = snapshot.data ?? [];

              if (children.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _EmptyChildrenCard(),
                );
              }

              return Column(
                children: children
                    .map(
                      (child) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _ChildCard(
                          child: child,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => _ChildDetailPage(
                                  child: child,
                                  onSaved: _refreshChildren,
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    )
                    .toList(),
              );
            },
          ),
          const SizedBox(height: 8),
          ...ProfileTab._items
              .skip(1)
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: FeatureListTile(
                    item: item,
                    onTap: () => _showFeatureComingSoon(item.label),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

class _EmptyChildrenCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'No child profiles yet',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.darkGray,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add a child profile to start tracking their learning progress.',
            style: TextStyle(fontSize: 14, color: AppColors.darkGray),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => AddChildPage(
                    parentName:
                        FirebaseAuth.instance.currentUser?.displayName ??
                        'Parent',
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text('Add Child'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.purple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChildCard extends StatelessWidget {
  final ChildModel child;
  final VoidCallback onTap;

  const _ChildCard({required this.child, required this.onTap});

  static const List<_AvatarOption> _avatars = [
    _AvatarOption(id: 'bear_1', icon: Icons.pets, color: AppColors.pink),
    _AvatarOption(
      id: 'star_1',
      icon: Icons.star_rounded,
      color: AppColors.yellow,
    ),
    _AvatarOption(id: 'cat_1', icon: Icons.emoji_nature, color: AppColors.teal),
    _AvatarOption(
      id: 'rocket_1',
      icon: Icons.rocket_launch_rounded,
      color: AppColors.purple,
    ),
  ];

  IconData _avatarIcon(String avatarId) {
    final avatar = _avatars.firstWhere(
      (a) => a.id == avatarId,
      orElse: () => _avatars.first,
    );
    return avatar.icon;
  }

  Color _avatarColor(String avatarId) {
    final avatar = _avatars.firstWhere(
      (a) => a.id == avatarId,
      orElse: () => _avatars.first,
    );
    return avatar.color;
  }

  @override
  Widget build(BuildContext context) {
    final avatarColor = _avatarColor(child.avatarId);

    return GestureDetector(
      onTap: onTap,
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
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: avatarColor.withOpacity(0.16),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                _avatarIcon(child.avatarId),
                color: avatarColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${child.age} years old',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _AvatarOption {
  final String id;
  final IconData icon;
  final Color color;

  const _AvatarOption({
    required this.id,
    required this.icon,
    required this.color,
  });
}

class _ChildDetailPage extends StatefulWidget {
  final ChildModel child;
  final Future<void> Function() onSaved;

  const _ChildDetailPage({required this.child, required this.onSaved});

  @override
  State<_ChildDetailPage> createState() => _ChildDetailPageState();
}

class _ChildDetailPageState extends State<_ChildDetailPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late String _selectedAvatarId;

  static const List<_AvatarOption> _avatars = [
    _AvatarOption(id: 'bear_1', icon: Icons.pets, color: AppColors.pink),
    _AvatarOption(
      id: 'star_1',
      icon: Icons.star_rounded,
      color: AppColors.yellow,
    ),
    _AvatarOption(id: 'cat_1', icon: Icons.emoji_nature, color: AppColors.teal),
    _AvatarOption(
      id: 'rocket_1',
      icon: Icons.rocket_launch_rounded,
      color: AppColors.purple,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.child.name);
    _ageController = TextEditingController(text: widget.child.age.toString());
    _selectedAvatarId = widget.child.avatarId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveChild() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final trimmedName = _nameController.text.trim();
    final ageValue = int.tryParse(_ageController.text.trim());

    if (trimmedName.isEmpty || ageValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid name and age.')),
      );
      return;
    }

    final updatedChild = widget.child.copyWith(
      name: trimmedName,
      age: ageValue,
      avatarId: _selectedAvatarId,
    );

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('children')
          .doc(updatedChild.childId)
          .set(updatedChild.toMap(), SetOptions(merge: true));

      if (!mounted) return;
      await widget.onSaved();
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Child profile updated!')));
    } catch (error) {
      debugPrint('Failed to update child profile: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save the child profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Details'),
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Choose Avatar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: _avatars.map((avatar) {
                    final isSelected = _selectedAvatarId == avatar.id;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedAvatarId = avatar.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: isSelected ? avatar.color : Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: avatar.color, width: 3),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: avatar.color.withOpacity(0.5),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [],
                        ),
                        child: Icon(
                          avatar.icon,
                          color: isSelected ? Colors.white : avatar.color,
                          size: 32,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Child Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: _saveChild,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Save Changes'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pink,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
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
