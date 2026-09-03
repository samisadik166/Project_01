import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Shapes and colors learning page
class ShapesColorsPage extends StatelessWidget {
  const ShapesColorsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shapes & Colors'),
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.category_rounded, size: 80, color: AppColors.teal),
            const SizedBox(height: 16),
            const Text(
              'Shapes & Colors',
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
                'Identify shapes and explore a rainbow of colors.',
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
