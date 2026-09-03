import 'dart:math';

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Numbers & Counting'),
        backgroundColor: AppColors.yellow,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: AppColors.cream,
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
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
                style: const TextStyle(fontSize: 20, color: AppColors.darkGray),
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
              Expanded(
                child: Center(
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
              ),
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
                  _isComplete ? 'Great counting!' : 'Choose a star to begin',
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
