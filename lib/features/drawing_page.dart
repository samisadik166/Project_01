import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Drawing and coloring page
class DrawingPage extends StatelessWidget {
  const DrawingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing & Coloring'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.brush_rounded, size: 80, color: AppColors.purple),
            const SizedBox(height: 16),
            const Text(
              'Drawing & Coloring',
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
                'Express creativity with drawing and coloring activities.',
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
