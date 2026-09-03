import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Helper function to show "coming soon" message
void showComingSoon(BuildContext context, String featureName) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$featureName is coming soon! 🚧 We\'ll build this next.'),
      backgroundColor: AppColors.teal,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
