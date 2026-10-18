import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'add_child_page.dart';
import 'login_page.dart';
import 'model/child.dart';
import 'utils/app_colors.dart';

// ---------------------------------------------------------------------------
// ACCOUNT SETTINGS — edit the parent's name, manage child profiles, sign out.
//
// Child editing is NOT duplicated here: it reuses the existing "Child Details"
// screen owned by ProfileTab through the [onEditChild] callback.
// ---------------------------------------------------------------------------
class AccountSettingsPage extends StatefulWidget {
  /// Lets ProfileTab refresh its own child list after an add/edit/delete.
  final Future<void> Function([String?]) onChildrenChanged;

  /// Opens the existing child-editing flow (the "Child Details" screen).
  final Future<void> Function(ChildModel child) onEditChild;

  const AccountSettingsPage({
    super.key,
    required this.onChildrenChanged,
    required this.onEditChild,
  });

  @override
  State<AccountSettingsPage> createState() => _AccountSettingsPageState();
}

class _AccountSettingsPageState extends State<AccountSettingsPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _loadingProfile = true;
  bool _savingProfile = false;
  bool _childrenLoading = true;
  bool _signingOut = false;
  List<ChildModel> _children = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
    _loadChildren();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.pink,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.teal,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // --- Edit Profile -------------------------------------------------------

  Future<void> _loadProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      if (mounted) setState(() => _loadingProfile = false);
      return;
    }

    // Fallback to Firebase Auth, then prefer the Firestore record.
    _nameController.text = user.displayName ?? '';
    _emailController.text = user.email ?? '';

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = doc.data();
      final name = data?['name']?.toString().trim() ?? '';
      final email = data?['email']?.toString().trim() ?? '';

      if (!mounted) return;
      setState(() {
        if (name.isNotEmpty) _nameController.text = name;
        if (email.isNotEmpty) _emailController.text = email;
        _loadingProfile = false;
      });
    } catch (error) {
      debugPrint('Could not load account profile: $error');
      if (!mounted) return;
      setState(() => _loadingProfile = false);
      _showError('Could not load your profile. Check your connection.');
    }
  }

  Future<void> _saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final trimmedName = _nameController.text.trim();

    if (uid == null) {
      _showError('Something went wrong. Please log in again.');
      return;
    }
    if (trimmedName.isEmpty) {
      _showError('Please enter a valid name.');
      return;
    }

    setState(() => _savingProfile = true);

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'name': trimmedName}, SetOptions(merge: true));

      if (!mounted) return;
      _showSuccess('Profile updated! 🎉');
    } catch (error) {
      debugPrint('Failed to update account profile: $error');
      _showError('Could not save your profile. Please try again.');
    } finally {
      if (mounted) setState(() => _savingProfile = false);
    }
  }

  // --- Manage Children ----------------------------------------------------

  Future<void> _loadChildren() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        setState(() {
          _children = [];
          _childrenLoading = false;
        });
      }
      return;
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('children')
          .orderBy('createdAt')
          .get();

      if (!mounted) return;
      setState(() {
        _children = snapshot.docs.map(ChildModel.fromDoc).toList();
        _childrenLoading = false;
      });
    } catch (error) {
      debugPrint('Could not load child profiles: $error');
      if (!mounted) return;
      setState(() => _childrenLoading = false);
      _showError('Could not load child profiles. Check your connection.');
    }
  }

  Future<void> _addChild() async {
    final childId = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => AddChildPage(
          parentName:
              FirebaseAuth.instance.currentUser?.displayName ?? 'Parent',
          returnToPrevious: true,
        ),
      ),
    );

    if (!mounted || childId == null) return;
    await _loadChildren();
    await widget.onChildrenChanged(childId);
  }

  Future<void> _editChild(ChildModel child) async {
    // Duplicates nothing: ProfileTab owns the existing edit screen.
    await widget.onEditChild(child);
    if (!mounted) return;
    await _loadChildren();
  }

  Future<void> _confirmDeleteChild(ChildModel child) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove child?'),
        content: Text(
          'Are you sure you want to remove ${child.name}?',
          style: const TextStyle(color: AppColors.darkGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.pink,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    try {
      // Only the child document is removed for now — quiz results under this
      // child are intentionally left in place (no cascade delete yet).
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('children')
          .doc(child.childId)
          .delete();

      await _loadChildren();
      await widget.onChildrenChanged();

      if (!mounted) return;
      _showSuccess('${child.name} was removed.');
    } catch (error) {
      debugPrint('Failed to remove child: $error');
      _showError('Could not remove ${child.name}. Please try again.');
    }
  }

  // --- Sign Out -----------------------------------------------------------

  bool get _signedInWithGoogle => FirebaseAuth.instance.currentUser?.providerData
      .any((info) => info.providerId == 'google.com') ??
      false;

  Future<void> _signOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log out?'),
        content: const Text(
          'Are you sure you want to log out?',
          style: TextStyle(color: AppColors.darkGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.pink,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    setState(() => _signingOut = true);

    try {
      if (_signedInWithGoogle) {
        await GoogleSignIn.instance.signOut();
      }
      await FirebaseAuth.instance.signOut();

      debugPrint('Logged out');
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (route) => false,
      );
    } catch (error) {
      debugPrint('Logout failed: $error');
      if (!mounted) return;
      setState(() => _signingOut = false);
      _showError('Could not log out. Please try again.');
    }
  }

  // --- UI -----------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        title: const Text('Account Settings'),
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _SectionCard(
              title: 'Edit Profile',
              icon: Icons.badge_rounded,
              iconColor: AppColors.teal,
              children: [
                _loadingProfile
                    ? const Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Center(child: CircularProgressIndicator()),
                      )
                    : TextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Name',
                          prefixIcon: Icon(Icons.person_rounded),
                        ),
                      ),
                if (!_loadingProfile) ...[
                  const SizedBox(height: 16),
                  TextField(
                    controller: _emailController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_rounded),
                      suffixIcon: Icon(Icons.lock_rounded),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton.icon(
                      onPressed: _savingProfile ? null : _saveProfile,
                      icon: _savingProfile
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Icon(Icons.save_rounded),
                      label: const Text('Save Changes'),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 24),
            _SectionCard(
              title: 'Manage Children',
              icon: Icons.child_care_rounded,
              iconColor: AppColors.purple,
              children: [
                if (_childrenLoading)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_children.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'No child profiles yet. Add one below to get started.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.darkGray,
                      ),
                    ),
                  )
                else ...[
                  for (var index = 0; index < _children.length; index++)
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: index == _children.length - 1 ? 0 : 12,
                      ),
                      child: _ChildRow(
                        child: _children[index],
                        onEdit: () => _editChild(_children[index]),
                        onDelete: () => _confirmDeleteChild(_children[index]),
                      ),
                    ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: OutlinedButton.icon(
                    onPressed: _childrenLoading ? null : _addChild,
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(
                      'Add Child',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGray,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(
                        color: AppColors.purple,
                        width: 1.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _signingOut ? null : _signOut,
                icon: _signingOut
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : const Icon(Icons.logout_rounded),
                label: const Text('Sign Out'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.pink,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// PRIVATE WIDGETS
// ---------------------------------------------------------------------------

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGray,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _ChildRow extends StatelessWidget {
  final ChildModel child;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ChildRow({
    required this.child,
    required this.onEdit,
    required this.onDelete,
  });

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

  IconData get _avatarIcon => _avatars
      .firstWhere(
        (avatar) => avatar.id == child.avatarId,
        orElse: () => _avatars.first,
      )
      .icon;

  Color get _avatarColor => _avatars
      .firstWhere(
        (avatar) => avatar.id == child.avatarId,
        orElse: () => _avatars.first,
      )
      .color;

  @override
  Widget build(BuildContext context) {
    final color = _avatarColor;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 6),
      decoration: BoxDecoration(
        color: AppColors.cream,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(_avatarIcon, color: color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${child.age} years old',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 20),
                label: const Text('Edit'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.teal,
                  minimumSize: const Size(48, 48),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_rounded, size: 20),
                label: const Text('Delete'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.pink,
                  minimumSize: const Size(48, 48),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
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
