import 'package:cloud_firestore/cloud_firestore.dart';

class QuestionModel {
  final String questionText;
  final String type;
  final List<String> options;
  final int correctIndex;
  final int order;

  QuestionModel({
    required this.questionText,
    required this.type,
    required this.options,
    required this.correctIndex,
    required this.order,
  });

  Map<String, dynamic> toMap() {
    return {
      'questionText': questionText,
      'type': type,
      'options': options,
      'correctIndex': correctIndex,
      'order': order,
    };
  }

  factory QuestionModel.fromMap(Map<String, dynamic> map) {
    final rawOptions = map['options'] as List? ?? const [];

    return QuestionModel(
      questionText: map['questionText']?.toString() ?? '',
      type: map['type']?.toString() ?? 'multiple_choice',
      options: rawOptions
          .map((option) => option.toString())
          .toList(growable: false),
      correctIndex: map['correctIndex'] is int
          ? map['correctIndex'] as int
          : int.tryParse(map['correctIndex']?.toString() ?? '') ?? 0,
      order: map['order'] is int
          ? map['order'] as int
          : int.tryParse(map['order']?.toString() ?? '') ?? 0,
    );
  }
}

class QuizModel {
  final String quizId;
  final String title;
  final String category;
  final List<int> ageRange;
  final String difficulty;
  final String iconUrl;
  final bool isActive;
  final List<QuestionModel> questions;

  QuizModel({
    required this.quizId,
    required this.title,
    required this.category,
    required this.ageRange,
    required this.difficulty,
    required this.iconUrl,
    required this.isActive,
    required this.questions,
  });

  Map<String, dynamic> toMap() {
    return {
      'quizId': quizId,
      'title': title,
      'category': category,
      'ageRange': ageRange,
      'difficulty': difficulty,
      'iconUrl': iconUrl,
      'isActive': isActive,
      'questions': questions.map((question) => question.toMap()).toList(),
    };
  }

  factory QuizModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final rawAgeRange = data['ageRange'] as List? ?? const [];
    final questionsData = data['questions'] as List? ?? const [];

    return QuizModel(
      quizId: data['quizId']?.toString() ?? doc.id,
      title: data['title']?.toString() ?? 'Quiz',
      category: data['category']?.toString() ?? 'General',
      ageRange: rawAgeRange
          .map((value) => int.tryParse(value.toString()) ?? 0)
          .toList(growable: false),
      difficulty: data['difficulty']?.toString() ?? 'easy',
      iconUrl: data['iconUrl']?.toString() ?? '',
      isActive: data['isActive'] == true,
      questions: questionsData
          .map(
            (question) => QuestionModel.fromMap(
              Map<String, dynamic>.from(question as Map? ?? {}),
            ),
          )
          .toList(growable: false),
    );
  }
}
