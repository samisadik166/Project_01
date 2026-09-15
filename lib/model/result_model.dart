import 'package:cloud_firestore/cloud_firestore.dart';

class ResultModel {
  final String resultId;
  final String quizId;
  final int score;
  final int totalQuestions;
  final int stars;
  final DateTime completedAt;

  ResultModel({
    required this.resultId,
    required this.quizId,
    required this.score,
    required this.totalQuestions,
    required this.stars,
    required this.completedAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'resultId': resultId,
      'quizId': quizId,
      'score': score,
      'totalQuestions': totalQuestions,
      'stars': stars,
      'completedAt': Timestamp.fromDate(completedAt),
    };
  }

  factory ResultModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ResultModel(
      resultId: data['resultId']?.toString() ?? doc.id,
      quizId: data['quizId']?.toString() ?? '',
      score: data['score'] is int
          ? data['score'] as int
          : int.tryParse(data['score']?.toString() ?? '') ?? 0,
      totalQuestions: data['totalQuestions'] is int
          ? data['totalQuestions'] as int
          : int.tryParse(data['totalQuestions']?.toString() ?? '') ?? 0,
      stars: data['stars'] is int
          ? data['stars'] as int
          : int.tryParse(data['stars']?.toString() ?? '') ?? 0,
      completedAt:
          (data['completedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  static String generateId(String quizId) {
    return '${quizId}_${DateTime.now().millisecondsSinceEpoch}';
  }
}
