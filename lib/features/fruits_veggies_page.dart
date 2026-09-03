import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Fruits and vegetables learning page
class FruitsVeggiesPage extends StatelessWidget {
  const FruitsVeggiesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fruits & Vegetables'),
        backgroundColor: AppColors.pink,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.eco_rounded, size: 80, color: AppColors.pink),
            const SizedBox(height: 16),
            const Text(
              'Fruits & Vegetables',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Discover healthy fruits and vegetables.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
