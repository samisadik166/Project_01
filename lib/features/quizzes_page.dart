import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Quizzes page
class QuizzesPage extends StatelessWidget {
  const QuizzesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
        backgroundColor: AppColors.pink,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz_rounded, size: 80, color: AppColors.pink),
            const SizedBox(height: 16),
            const Text(
              'Quizzes',
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
                'Test your knowledge with fun and engaging quizzes.',
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
