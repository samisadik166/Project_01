import 'dart:math';

import 'package:flutter/material.dart';

class QuizOption {
  final String text;
  final String emoji;

  const QuizOption({required this.text, required this.emoji});
}

class QuizQuestion {
  final String questionText;
  final String emoji;
  final List<QuizOption> options;
  final int correctAnswerIndex;
  final String? hint;

  const QuizQuestion({
    required this.questionText,
    required this.emoji,
    required this.options,
    required this.correctAnswerIndex,
    this.hint,
  });

  QuizQuestion shuffled(Random random) {
    final indexedOptions = [
      for (var index = 0; index < options.length; index++)
        (index: index, option: options[index]),
    ]..shuffle(random);

    return QuizQuestion(
      questionText: questionText,
      emoji: emoji,
      options: indexedOptions.map((entry) => entry.option).toList(),
      correctAnswerIndex: indexedOptions.indexWhere(
        (entry) => entry.index == correctAnswerIndex,
      ),
      hint: hint,
    );
  }
}

class QuizCategory {
  final String quizId;
  final String title;
  final String emoji;
  final Color color;
  final List<QuizQuestion> questions;

  const QuizCategory({
    required this.quizId,
    required this.title,
    required this.emoji,
    required this.color,
    required this.questions,
  });

  QuizCategory shuffled(Random random) {
    final randomizedQuestions =
        questions.map((question) => question.shuffled(random)).toList()
          ..shuffle(random);
    return QuizCategory(
      quizId: quizId,
      title: title,
      emoji: emoji,
      color: color,
      questions: randomizedQuestions,
    );
  }
}
