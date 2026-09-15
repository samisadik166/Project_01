import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'model/child.dart';

// ---------------------------------------------------------------------------
// ADD CHILD PAGE — shown right after sign-up so every parent account has
// at least one child profile before reaching the home screen.
// ---------------------------------------------------------------------------
class AddChildPage extends StatefulWidget {
  final String parentName;

  const AddChildPage({super.key, required this.parentName});

  @override
  State<AddChildPage> createState() => _AddChildPageState();
}

class _AddChildPageState extends State<AddChildPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  bool _isLoading = false;

  // A small fixed set of avatars a kid can pick from — avoids needing
  // image upload/storage for now.
  final List<_AvatarOption> _avatars = const [
    _AvatarOption(id: 'bear_1', icon: Icons.pets, color: Color(0xFFFF6B9D)),
    _AvatarOption(
      id: 'star_1',
      icon: Icons.star_rounded,
      color: Color(0xFFFFC93C),
    ),
    _AvatarOption(
      id: 'cat_1',
      icon: Icons.emoji_nature,
      color: Color(0xFF4EE0C1),
    ),
    _AvatarOption(
      id: 'rocket_1',
      icon: Icons.rocket_launch_rounded,
      color: Color(0xFF9B7EDE),
    ),
  ];
  String _selectedAvatarId = 'bear_1';

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _handleAddChild() async {
    if (!_formKey.currentState!.validate()) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      // Shouldn't happen if navigation flow is correct, but guard anyway.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Something went wrong. Please log in again.'),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Firestore auto-generates a unique document ID for the child.
      final childRef = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('children')
          .doc();

      final child = ChildModel(
        childId: childRef.id,
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text.trim()),
        avatarId: _selectedAvatarId,
        createdAt: DateTime.now(),
      );

      await childRef.set(child.toMap());

      debugPrint('Child added: ${child.childId}');

      if (!mounted) return;

      final childName = _nameController.text.trim();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => HomePage(userName: childName)),
      );
    } catch (e) {
      debugPrint('Failed to add child: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Couldn't save your child's profile. Please try again.",
          ),
          backgroundColor: const Color(0xFFFF6B9D),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF9B7EDE), Color(0xFFFFF8E7)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Row(
                    children: [
                      Icon(
                        Icons.child_care_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                      SizedBox(width: 10),
                      Text(
                        "Add Your Child",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Let's set up your child's learning profile! 🎈",
                    style: TextStyle(fontSize: 15, color: Colors.white),
                  ),
                  const SizedBox(height: 30),

                  const Text(
                    'Choose an Avatar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

                  _KidTextField(
                    controller: _nameController,
                    label: "Child's Name",
                    icon: Icons.person_rounded,
                    validator: (value) => (value == null || value.isEmpty)
                        ? "Please enter your child's name"
                        : null,
                  ),
                  const SizedBox(height: 16),

                  _KidTextField(
                    controller: _ageController,
                    label: "Child's Age",
                    icon: Icons.cake_rounded,
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return "Please enter your child's age";
                      }
                      final age = int.tryParse(value);
                      if (age == null || age < 1 || age > 12) {
                        return 'Enter a valid age (1-12)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleAddChild,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF9B7EDE),
                        disabledBackgroundColor: const Color(
                          0xFF9B7EDE,
                        ).withOpacity(0.6),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 4,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const Text(
                              'Continue 🌟',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
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

// Same reusable text field pattern used in login_page.dart / sign_up_page.dart
class _KidTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;

  const _KidTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF9B7EDE)),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 18,
            horizontal: 16,
          ),
        ),
      ),
    );
  }
}
