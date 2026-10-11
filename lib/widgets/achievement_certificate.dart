import 'package:flutter/material.dart';

import '../model/certificate_milestone.dart';
import '../utils/app_colors.dart';

class AchievementCertificate extends StatelessWidget {
  final String childName;
  final CertificateMilestone milestone;
  final DateTime date;

  const AchievementCertificate({
    super.key,
    required this.childName,
    required this.milestone,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final dateLabel = '${date.day}/${date.month}/${date.year}';
    return AspectRatio(
      aspectRatio: 1.414,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFEFA),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.pink, width: 5),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.yellow, width: 2),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text('⭐  🌈  ⭐', style: TextStyle(fontSize: 18)),
              const Text(
                'Certificate of Achievement',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: AppColors.purple,
                ),
              ),
              Text(
                childName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkGray,
                ),
              ),
              Text(
                '${milestone.emoji} ${milestone.achievement}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGray,
                ),
              ),
              Text(
                dateLabel,
                style: const TextStyle(fontSize: 15, color: AppColors.darkGray),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _SignatureLine(label: 'Parent / Teacher'),
                  _SignatureLine(label: 'Little Learner'),
                ],
              ),
              const Text('⭐  ⭐  ⭐', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SignatureLine extends StatelessWidget {
  final String label;

  const _SignatureLine({required this.label});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 150,
    child: Column(
      children: [
        const Divider(color: AppColors.darkGray),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 12, color: AppColors.darkGray),
        ),
      ],
    ),
  );
}
