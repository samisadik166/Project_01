import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

abstract interface class QuizProgressRepository {
  Future<String> loadActiveChildId();

  Future<void> saveQuizResult({
    required String childId,
    required String quizId,
    required int score,
    required int totalQuestions,
    required int stars,
  });
}

class FirestoreQuizProgressRepository implements QuizProgressRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreQuizProgressRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  @override
  Future<String> loadActiveChildId() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Sign in to play quizzes.');
    }

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
    if (children.docs.isEmpty) {
      throw StateError('Add a child profile before playing quizzes.');
    }
    return children.docs.first.id;
  }

  @override
  Future<void> saveQuizResult({
    required String childId,
    required String quizId,
    required int score,
    required int totalQuestions,
    required int stars,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) {
      throw StateError('Sign in to save quiz progress.');
    }

    final childRef = _firestore
        .collection('users')
        .doc(uid)
        .collection('children')
        .doc(childId);
    final progressRef = childRef.collection('progress').doc(quizId);
    final activityRef = childRef.collection('activityLog').doc();

    await _firestore.runTransaction((transaction) async {
      final progressSnapshot = await transaction.get(progressRef);
      final progress = progressSnapshot.data() ?? const <String, dynamic>{};
      final previousBest = (progress['bestScore'] as num?)?.toInt() ?? 0;
      final bestScore = score > previousBest ? score : previousBest;
      final completedAt = Timestamp.now();

      transaction.set(progressRef, {
        'quizId': quizId,
        'score': score,
        'totalQuestions': totalQuestions,
        'bestScore': bestScore,
        'stars': FieldValue.increment(stars),
        'completedAt': completedAt,
      }, SetOptions(merge: true));

      transaction.set(childRef, {
        'totalStars': FieldValue.increment(stars),
      }, SetOptions(merge: true));
      transaction.set(activityRef, {
        'taskType': 'quiz',
        'taskId': quizId,
        'score': score,
        'totalQuestions': totalQuestions,
        'stars': stars,
        'completedAt': completedAt,
      });
    });
  }
}
