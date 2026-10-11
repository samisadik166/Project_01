import 'dart:math' as math;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../model/progress_report.dart';
import '../utils/app_colors.dart';

abstract interface class ProgressRepository {
  Future<String?> loadActiveChildId();

  Future<ProgressReport> loadReport({
    required String childId,
    required ProgressDateRange dateRange,
  });
}

class FirestoreProgressRepository implements ProgressRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final DateTime Function() _now;

  FirestoreProgressRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    DateTime Function()? now,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _now = now ?? DateTime.now;

  @override
  Future<String?> loadActiveChildId() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    final userRef = _firestore.collection('users').doc(uid);
    final userSnapshot = await userRef.get();
    final selectedChildId = userSnapshot.data()?['activeChildId']?.toString();
    if (selectedChildId != null && selectedChildId.isNotEmpty) {
      final selectedChild = await userRef
          .collection('children')
          .doc(selectedChildId)
          .get();
      if (selectedChild.exists) return selectedChildId;
    }

    final children = await userRef
        .collection('children')
        .orderBy('createdAt')
        .limit(1)
        .get();
    return children.docs.isEmpty ? null : children.docs.first.id;
  }

  @override
  Future<ProgressReport> loadReport({
    required String childId,
    required ProgressDateRange dateRange,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Sign in to view this report.');

    final childRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('children')
        .doc(childId);
    final childSnapshot = await childRef.get();
    final childData = childSnapshot.data() ?? const <String, dynamic>{};
    final start = _startFor(dateRange, _now());
    final activityCollection = childRef.collection('activityLog');
    final filteredQuery = start == null
        ? activityCollection.orderBy('completedAt', descending: true).limit(500)
        : activityCollection
              .where(
                'completedAt',
                isGreaterThanOrEqualTo: Timestamp.fromDate(start),
              )
              .orderBy('completedAt', descending: true)
              .limit(500);
    final activitySnapshot = await filteredQuery.get();

    final tasks = (childData['completedTasks'] as List? ?? const [])
        .map((value) => value.toString())
        .toSet();
    final activities = activitySnapshot.docs.map((doc) {
      final data = doc.data();
      return ProgressActivity(
        id: doc.id,
        taskType: data['taskType']?.toString() ?? 'activity',
        taskId: data['taskId']?.toString() ?? doc.id,
        completedAt: (data['completedAt'] as Timestamp?)?.toDate() ?? _now(),
        stars: (data['stars'] as num?)?.toInt() ?? 0,
      );
    }).toList();

    final childName = childData['name']?.toString().trim() ?? '';
    final totalStars = (childData['totalStars'] as num?)?.toInt() ?? 0;
    final reportDateActivities = activities;

    return ProgressReport(
      childId: childId,
      childName: childName.isEmpty ? 'Little Learner' : childName,
      age: (childData['age'] as num?)?.toInt() ?? 0,
      avatarId: childData['avatarId']?.toString() ?? '',
      totalStars: totalStars,
      badgesEarned: _badgeCount(totalStars),
      activitiesCompleted: reportDateActivities.length,
      learningStreak: _streak(reportDateActivities, _now()),
      subjects: _buildSubjects(
        reportDateActivities,
        dateRange == ProgressDateRange.allTime ? tasks : null,
      ),
      weeklyActivity: _weeklyCounts(reportDateActivities, _now()),
      activities: reportDateActivities,
      completedTasks: tasks,
    );
  }

  DateTime? _startFor(ProgressDateRange range, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    switch (range) {
      case ProgressDateRange.week:
        return today.subtract(Duration(days: today.weekday - 1));
      case ProgressDateRange.month:
        return DateTime(now.year, now.month);
      case ProgressDateRange.allTime:
        return null;
    }
  }

  int _badgeCount(int stars) =>
      [10, 25, 50].where((milestone) => stars >= milestone).length;

  int _streak(List<ProgressActivity> activities, DateTime now) {
    final activeDays = activities.map((activity) {
      final date = activity.completedAt;
      return DateTime(date.year, date.month, date.day);
    }).toSet();
    var day = DateTime(now.year, now.month, now.day);
    if (!activeDays.contains(day)) day = day.subtract(const Duration(days: 1));
    var streak = 0;
    while (activeDays.contains(day)) {
      streak++;
      day = day.subtract(const Duration(days: 1));
    }
    return streak;
  }

  List<int> _weeklyCounts(List<ProgressActivity> activities, DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final counts = List<int>.filled(7, 0);
    for (final activity in activities) {
      final date = activity.completedAt;
      final activityDay = DateTime(date.year, date.month, date.day);
      final index = activityDay.difference(monday).inDays;
      if (index >= 0 && index < counts.length) counts[index]++;
    }
    return counts;
  }

  List<SubjectProgress> _buildSubjects(
    List<ProgressActivity> activities,
    Set<String>? completedTasks,
  ) {
    final alphabetIds = completedTasks == null
        ? activities
              .where((activity) => activity.taskType == 'alphabet')
              .map((activity) => activity.taskId)
              .toSet()
        : completedTasks.where((key) => key.startsWith('alphabet_')).toSet();
    final numberIds = completedTasks == null
        ? activities
              .where((activity) => activity.taskType == 'number')
              .map((activity) => activity.taskId)
              .toSet()
        : completedTasks.where((key) => key.startsWith('number_')).toSet();
    final alphabet = alphabetIds.length;
    final numbers = numberIds.length;
    final quizCount = activities
        .where((activity) => activity.taskType == 'quiz')
        .map((activity) => activity.taskId)
        .toSet()
        .length;
    final drawingCount = activities
        .where((item) => item.taskType == 'drawing')
        .length;
    final gameCount = activities
        .where((item) => item.taskType == 'game')
        .length;

    return [
      _subject('Alphabet', alphabet, 26, AppColors.pink),
      _subject('Numbers', numbers, 10, AppColors.yellow),
      _subject('Quizzes', quizCount, 5, AppColors.teal),
      _subject('Drawing', drawingCount, 1, AppColors.purple),
      _subject('Games', gameCount, 3, AppColors.pink),
    ];
  }

  SubjectProgress _subject(String name, int count, int goal, Color color) {
    final percentage = (count * 100 / math.max(1, goal)).round().clamp(0, 100);
    return SubjectProgress(
      subject: name,
      percentage: percentage,
      encouragement: percentage >= 70 ? 'A strong area!' : 'Keep exploring!',
      color: color,
    );
  }
}
