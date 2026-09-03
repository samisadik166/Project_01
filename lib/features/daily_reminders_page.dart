import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Daily reminders page
class DailyRemindersPage extends StatelessWidget {
  const DailyRemindersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Reminders'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_active_rounded,
              size: 80,
              color: AppColors.purple,
            ),
            const SizedBox(height: 16),
            const Text(
              'Daily Reminders',
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
                'Set up daily reminders to keep learning on track.',
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
