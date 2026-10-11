import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class RewardService {
  static String taskKey(String taskType, String taskId) {
    final cleanTaskType = taskType.trim();
    final cleanTaskId = taskId.trim();
    if (cleanTaskType.isEmpty || cleanTaskId.isEmpty) {
      return 'task';
    }
    return '${cleanTaskType}_$cleanTaskId';
  }

  static bool shouldAwardTask({
    required Set<String> completedKeys,
    required String taskType,
    required String taskId,
  }) {
    return !completedKeys.contains(taskKey(taskType, taskId));
  }

  static Future<void> awardTaskStarsForCurrentChild({
    required String childId,
    required String taskType,
    required String taskId,
    int stars = 1,
  }) async {
    final rewardKey = taskKey(taskType, taskId);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      throw StateError('Sign in to save learning progress.');
    }

    try {
      final childDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('children')
          .doc(childId);
      final activityDoc = childDoc.collection('activityLog').doc();

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final freshDoc = await transaction.get(childDoc);
        if (!freshDoc.exists) {
          throw StateError('The selected child profile could not be found.');
        }
        final completedTasks = List<String>.from(
          (freshDoc.data()?['completedTasks'] as List? ?? const []).map(
            (value) => value.toString(),
          ),
        );

        final completedAt = Timestamp.now();
        final alreadyCompleted = completedTasks.contains(rewardKey);
        if (!alreadyCompleted) {
          transaction.set(childDoc, {
            'completedTasks': [...completedTasks, rewardKey],
            'totalStars': FieldValue.increment(stars),
          }, SetOptions(merge: true));
        }
        transaction.set(activityDoc, {
          'taskType': taskType,
          'taskId': taskId,
          'stars': alreadyCompleted ? 0 : stars,
          'completedAt': completedAt,
        });
      });
    } catch (error) {
      debugPrint('Could not award task stars for $taskType/$rewardKey: $error');
      rethrow;
    }
  }
}
