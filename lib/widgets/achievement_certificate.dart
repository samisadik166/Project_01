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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxHeight < 300;
          return Container(
            padding: EdgeInsets.all(compact ? 5 : 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFEFA),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.pink, width: compact ? 3 : 5),
            ),
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: compact ? 8 : 16,
                vertical: compact ? 3 : 6,
              ),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.yellow, width: 2),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    '⭐  🌈  ⭐',
                    style: TextStyle(fontSize: compact ? 14 : 18),
                  ),
                  Text(
                    'Certificate of Achievement',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: compact ? 17 : 21,
                      fontWeight: FontWeight.w900,
                      color: AppColors.purple,
                    ),
                  ),
                  Text(
                    childName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: compact ? 20 : 25,
                      fontWeight: FontWeight.w900,
                      color: AppColors.darkGray,
                    ),
                  ),
                  Text(
                    '${milestone.emoji} ${milestone.achievement}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: compact ? 12 : 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGray,
                    ),
                  ),
                  Text(
                    dateLabel,
                    style: TextStyle(
                      fontSize: compact ? 12 : 15,
                      color: AppColors.darkGray,
                    ),
                  ),
                  Row(
                    children: [
                      const Expanded(
                        child: _SignatureLine(label: 'Parent / Teacher'),
                      ),
                      SizedBox(width: compact ? 6 : 12),
                      const Expanded(
                        child: _SignatureLine(label: 'Little Learner'),
                      ),
                    ],
                  ),
                  Text(
                    '⭐  ⭐  ⭐',
                    style: TextStyle(fontSize: compact ? 14 : 18),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SignatureLine extends StatelessWidget {
  final String label;

  const _SignatureLine({required this.label});

  @override
  Widget build(BuildContext context) => Column(
    children: [
      const Divider(color: AppColors.darkGray),
      Text(
        label,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12, color: AppColors.darkGray),
      ),
    ],
  );
}
