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
    required String taskType,
    required String taskId,
    int stars = 1,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return;
    }

    try {
      final childSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection('children')
          .orderBy('createdAt', descending: false)
          .limit(1)
          .get();

      if (childSnapshot.docs.isEmpty) {
        return;
      }

      final childDoc = childSnapshot.docs.first.reference;
      final rewardKey = taskKey(taskType, taskId);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final freshDoc = await transaction.get(childDoc);
        final completedTasks = List<String>.from(
          (freshDoc.data()?['completedTasks'] as List? ?? const []).map(
            (value) => value.toString(),
          ),
        );

        if (completedTasks.contains(rewardKey)) {
          return;
        }

        transaction.update(childDoc, {
          'completedTasks': [...completedTasks, rewardKey],
          'totalStars': FieldValue.increment(stars),
        });
      });
    } catch (error) {
      debugPrint('Could not award task stars for $taskType/$taskKey: $error');
    }
  }
}
