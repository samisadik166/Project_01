import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preschool_learning_app/model/quiz_model.dart';
import 'package:preschool_learning_app/model/result_model.dart';

void main() {
  test('QuizModel parses nested questions from Firestore map', () {
    final quiz = QuizModel.fromDoc(
      FakeDoc({
        'quizId': 'quiz_1',
        'title': 'Numbers',
        'category': 'Math',
        'ageRange': [3, 5],
        'difficulty': 'easy',
        'iconUrl': 'https://example.com/icon.png',
        'isActive': true,
        'questions': [
          {
            'questionText': 'What is 1 + 1?',
            'type': 'multiple_choice',
            'options': ['1', '2', '3'],
            'correctIndex': 1,
            'order': 1,
          },
        ],
      }),
    );

    expect(quiz.title, 'Numbers');
    expect(quiz.questions.length, 1);
    expect(quiz.questions.first.questionText, 'What is 1 + 1?');
    expect(quiz.questions.first.correctIndex, 1);
  });

  test('ResultModel.generateId returns a unique quiz-specific id', () {
    final id = ResultModel.generateId('quiz_1');

    expect(id.startsWith('quiz_1_'), isTrue);
    expect(id.length > 'quiz_1_'.length, isTrue);
  });
}

class FakeDoc implements DocumentSnapshot<Map<String, dynamic>> {
  const FakeDoc(this.dataMap);

  final Map<String, dynamic> dataMap;

  @override
  String get id => 'test-doc';

  @override
  DocumentReference<Map<String, dynamic>> get reference =>
      throw UnimplementedError('Not needed for model parsing tests');

  @override
  SnapshotMetadata get metadata =>
      throw UnimplementedError('Not needed for model parsing tests');

  @override
  bool get exists => true;

  @override
  Map<String, dynamic>? data() => dataMap;

  @override
  dynamic get(Object field) => dataMap[field];

  @override
  dynamic operator [](Object field) => dataMap[field];
}
