import 'dart:math';

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'number_tracing_widget.dart';

/// Numbers and counting learning page
class NumbersPage extends StatefulWidget {
  const NumbersPage({super.key});

  @override
  State<NumbersPage> createState() => _NumbersPageState();
}

class _NumbersPageState extends State<NumbersPage> {
  final Random _random = Random();
  int _target = 4;
  int _selected = 0;
  bool _isComplete = false;
  bool _showTracing = false;

  void _tapStar() {
    if (_isComplete || _selected >= _target) return;

    setState(() {
      _selected++;
      _isComplete = _selected == _target;
    });
  }

  void _newRound() {
    setState(() {
      _target = 3 + _random.nextInt(6);
      _selected = 0;
      _isComplete = false;
    });
  }

  void _setMode(bool showTracing) {
    setState(() => _showTracing = showTracing);
  }

  @override
  Widget build(BuildContext context) {
    final content = _showTracing
        ? const NumberTracingWidget()
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(minWidth: double.infinity),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  const Text(
                    'Count the stars!',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap $_target stars',
                    style: const TextStyle(
                      fontSize: 20,
                      color: AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '$_selected / $_target',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.yellow,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 12,
                      runSpacing: 12,
                      children: List.generate(
                        _target,
                        (index) => _StarButton(
                          key: ValueKey('star-$index'),
                          isSelected: index < _selected,
                          onTap: _tapStar,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isComplete ? _newRound : null,
                      icon: Icon(_isComplete ? Icons.refresh : Icons.star),
                      label: Text(_isComplete ? 'Play Again' : 'Keep Counting'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.yellow,
                        foregroundColor: AppColors.darkGray,
                        disabledBackgroundColor: AppColors.yellow.withValues(
                          alpha: 0.45,
                        ),
                        disabledForegroundColor: AppColors.darkGray.withValues(
                          alpha: 0.6,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 32,
                    child: Text(
                      _isComplete
                          ? 'Great counting!'
                          : 'Choose a star to begin',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: _isComplete ? Colors.green : Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Numbers'),
        backgroundColor: AppColors.yellow,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: AppColors.cream,
        width: double.infinity,
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: _ModeCard(
                        label: 'Counting',
                        icon: Icons.star_rounded,
                        color: AppColors.yellow,
                        isSelected: !_showTracing,
                        onTap: () => _setMode(false),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _ModeCard(
                        label: 'Number Tracing',
                        icon: Icons.edit_rounded,
                        color: AppColors.teal,
                        isSelected: _showTracing,
                        onTap: () => _setMode(true),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: content),
            ],
          ),
        ),
      ),
    );
  }
}

/// Big square-ish rounded mode card — used for the Counting / Number Tracing
/// selector at the top of the page.
class _ModeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 34, color: isSelected ? Colors.white : color),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : AppColors.darkGray,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarButton extends StatelessWidget {
  const _StarButton({super.key, required this.isSelected, required this.onTap});

  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: isSelected ? 'Counted star' : 'Star to count',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.yellow : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.yellow, width: 3),
          ),
          child: Icon(
            isSelected ? Icons.star : Icons.star_border,
            size: 40,
            color: isSelected ? Colors.white : AppColors.yellow,
          ),
        ),
      ),
    );
  }
}
