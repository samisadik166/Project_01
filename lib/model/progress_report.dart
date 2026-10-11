import 'package:flutter/material.dart';

enum ProgressDateRange {
  week('This week'),
  month('This month'),
  allTime('All time');

  const ProgressDateRange(this.label);

  final String label;
}

class ProgressActivity {
  final String id;
  final String taskType;
  final String taskId;
  final DateTime completedAt;
  final int stars;

  const ProgressActivity({
    required this.id,
    required this.taskType,
    required this.taskId,
    required this.completedAt,
    required this.stars,
  });
}

class SubjectProgress {
  final String subject;
  final int percentage;
  final String encouragement;
  final Color color;

  const SubjectProgress({
    required this.subject,
    required this.percentage,
    required this.encouragement,
    required this.color,
  });
}

class ProgressReport {
  final String childId;
  final String childName;
  final int age;
  final String avatarId;
  final int totalStars;
  final int badgesEarned;
  final int activitiesCompleted;
  final int learningStreak;
  final List<SubjectProgress> subjects;
  final List<int> weeklyActivity;
  final List<ProgressActivity> activities;
  final Set<String> completedTasks;

  const ProgressReport({
    required this.childId,
    required this.childName,
    required this.age,
    required this.avatarId,
    required this.totalStars,
    required this.badgesEarned,
    required this.activitiesCompleted,
    required this.learningStreak,
    required this.subjects,
    required this.weeklyActivity,
    required this.activities,
    required this.completedTasks,
  });
}
