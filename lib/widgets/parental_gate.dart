import 'dart:math' as math;

import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

Future<bool> showParentalGate(BuildContext context) async {
  final random = math.Random();
  final first = random.nextInt(10) + 1;
  final second = random.nextInt(10) + 1;
  final answer = first + second;
  final controller = TextEditingController();

  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Parent Check',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.darkGray,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Please solve this to continue.',
              style: TextStyle(fontSize: 15, color: AppColors.darkGray),
            ),
            const SizedBox(height: 16),
            Text(
              '$first + $second = ?',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w800,
                color: AppColors.pink,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Your answer',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text.trim());
              Navigator.of(dialogContext).pop(value == answer);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Continue'),
          ),
        ],
      );
    },
  );

  if (result != true) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('That answer was not correct. Please try again.'),
        ),
      );
    }
    return false;
  }

  return true;
}
