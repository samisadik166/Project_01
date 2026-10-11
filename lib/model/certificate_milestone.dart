import 'progress_report.dart';

class CertificateMilestone {
  final String id;
  final String title;
  final String achievement;
  final String emoji;
  final int requiredStars;
  final String requiredTaskPrefix;
  final int requiredTaskCount;

  const CertificateMilestone({
    required this.id,
    required this.title,
    required this.achievement,
    required this.emoji,
    this.requiredStars = 0,
    this.requiredTaskPrefix = '',
    this.requiredTaskCount = 0,
  });

  bool isUnlocked(ProgressReport report) {
    if (requiredStars > 0 && report.totalStars >= requiredStars) return true;
    if (requiredTaskCount == 0) return false;
    final completedCount = report.completedTasks
        .where((task) => task.startsWith(requiredTaskPrefix))
        .length;
    return completedCount >= requiredTaskCount;
  }

  String get goalDescription {
    if (requiredStars > 0) return 'Earn $requiredStars stars';
    return 'Finish $title';
  }
}

const certificateMilestones = <CertificateMilestone>[
  CertificateMilestone(
    id: 'alphabet_complete',
    title: 'Alphabet Star',
    achievement: 'Completed the Alphabet Tracing Level',
    emoji: '🔤',
    requiredTaskPrefix: 'alphabet_',
    requiredTaskCount: 26,
  ),
  CertificateMilestone(
    id: 'numbers_complete',
    title: 'Number Explorer',
    achievement: 'Completed the Number Tracing Level',
    emoji: '🔢',
    requiredTaskPrefix: 'number_',
    requiredTaskCount: 10,
  ),
  CertificateMilestone(
    id: 'fifty_stars',
    title: 'Shining Star',
    achievement: 'Earned 50 learning stars',
    emoji: '⭐',
    requiredStars: 50,
  ),
];
