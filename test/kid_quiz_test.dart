import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preschool_learning_app/data/quiz_progress_repository.dart';
import 'package:preschool_learning_app/features/kid_quiz_data.dart';
import 'package:preschool_learning_app/features/quizzes_page.dart';

void main() {
  test('all six quiz categories contain eight accessible questions', () {
    expect(quizCategories.map((category) => category.title).toList(), [
      'Colors',
      'Shapes',
      'Animals',
      'Fruits',
      'Opposites',
      'Vehicles',
    ]);

    for (final category in quizCategories) {
      expect(category.questions, hasLength(8));
      for (final question in category.questions) {
        expect(question.questionText, isNotEmpty);
        expect(question.emoji, isNotEmpty);
        expect(question.options.length, inInclusiveRange(3, 4));
        expect(
          question.correctAnswerIndex,
          inInclusiveRange(0, question.options.length - 1),
        );
        expect(
          question.options.every((option) => option.emoji.isNotEmpty),
          isTrue,
        );
      }
    }
  });

  test('shuffled question keeps its correct option paired', () {
    final question = quizCategories.first.questions.first;
    final correctOption = question.options[question.correctAnswerIndex];
    final shuffled = question.shuffled(Random(12));

    expect(shuffled.options[shuffled.correctAnswerIndex], same(correctOption));
    expect(shuffled.options.toSet(), question.options.toSet());
  });

  testWidgets('quiz selection shows six categories and opens a quiz', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: QuizzesPage(repository: _FakeQuizProgressRepository())),
    );
    await tester.pumpAndSettle();

    for (final title in [
      'Colors',
      'Shapes',
      'Animals',
      'Fruits',
      'Opposites',
      'Vehicles',
    ]) {
      expect(find.text(title), findsOneWidget);
    }

    await tester.tap(find.text('Colors'));
    await tester.pumpAndSettle();

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            quizCategories.first.questions.any(
              (question) => question.questionText == widget.data,
            ),
      ),
      findsOneWidget,
    );
    expect(find.byTooltip('Read question aloud'), findsOneWidget);
    expect(find.text('1/8'), findsOneWidget);
  });

  testWidgets('each completed quiz attempt awards stars', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    final repository = _FakeQuizProgressRepository();
    final category = quizCategories.first;

    for (var attempt = 0; attempt < 2; attempt++) {
      await tester.pumpWidget(
        MaterialApp(
          home: QuizScreen(
            key: ValueKey('quiz-attempt-$attempt'),
            category: category,
            childId: 'child-1',
            repository: repository,
          ),
        ),
      );
      await tester.pumpAndSettle();

      for (var index = 0; index < category.questions.length; index++) {
        final question = category.questions.firstWhere(
          (item) => find.text(item.questionText).evaluate().isNotEmpty,
          orElse: () => throw StateError(
            'No quiz question visible on step $index: '
            '${tester.widgetList<Text>(find.byType(Text)).map((text) => text.data).toList()}',
          ),
        );
        final correctOption = question.options[question.correctAnswerIndex];
        final answerFinder = find.text(correctOption.text);
        await tester.ensureVisible(answerFinder);
        await tester.tap(answerFinder);
        await tester.pumpAndSettle();

        final nextFinder = find.text(
          index == category.questions.length - 1 ? 'See my stars' : 'Next',
        );
        await tester.ensureVisible(nextFinder);
        await tester.tap(nextFinder);
        await tester.pumpAndSettle();
      }
      await tester.pumpWidget(const SizedBox.shrink());
    }

    expect(repository.awardedStars, hasLength(2));
    expect(repository.awardedStars.every((stars) => stars > 0), isTrue);
  });
}

class _FakeQuizProgressRepository implements QuizProgressRepository {
  final List<int> awardedStars = [];

  @override
  Future<String> loadActiveChildId() async => 'child-1';

  @override
  Future<void> saveQuizResult({
    required String childId,
    required String quizId,
    required int score,
    required int totalQuestions,
    required int stars,
  }) async {
    awardedStars.add(stars);
  }
}
