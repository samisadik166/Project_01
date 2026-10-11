import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import 'number_tracing_widget.dart';

/// Numbers learning page with tracing only.
class NumbersPage extends StatelessWidget {
  final String childId;

  const NumbersPage({super.key, required this.childId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.yellow,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: AppColors.cream,
        width: double.infinity,
        child: SafeArea(child: NumberTracingWidget(childId: childId)),
      ),
    );
  }
}
