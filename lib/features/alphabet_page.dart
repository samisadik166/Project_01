import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Alphabet learning page
class AlphabetPage extends StatelessWidget {
  const AlphabetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alphabet A–Z'),
        backgroundColor: AppColors.pink,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.abc_rounded, size: 80, color: AppColors.pink),
            const SizedBox(height: 16),
            const Text(
              'Alphabet Learning',
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
                'Learn letters A through Z with interactive lessons and exercises.',
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
