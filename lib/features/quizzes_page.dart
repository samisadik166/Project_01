import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../data/quiz_progress_repository.dart';
import '../model/kid_quiz.dart';
import '../utils/app_colors.dart';
import 'kid_quiz_data.dart';

class QuizzesPage extends StatefulWidget {
  final QuizProgressRepository? repository;
  final String? childId;

  const QuizzesPage({super.key, this.repository, this.childId});

  @override
  State<QuizzesPage> createState() => _QuizzesPageState();
}

class _QuizzesPageState extends State<QuizzesPage> {
  static final _defaultRepository = FirestoreQuizProgressRepository();
  QuizProgressRepository get _repository =>
      widget.repository ?? _defaultRepository;

  late Future<String> _childIdFuture;

  @override
  void initState() {
    super.initState();
    _childIdFuture = widget.childId == null
        ? _repository.loadActiveChildId()
        : Future.value(widget.childId);
  }

  void _retryLoading() {
    setState(() {
      _childIdFuture = widget.childId == null
          ? _repository.loadActiveChildId()
          : Future.value(widget.childId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.pink,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<String>(
        future: _childIdFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.pink),
            );
          }
          if (snapshot.hasError) {
            final message = snapshot.error is StateError
                ? (snapshot.error as StateError).message
                : 'Could not load your child profile. Please try again.';
            return _LoadError(message: message, onRetry: _retryLoading);
          }

          final childId = snapshot.data;
          if (childId == null) {
            return _LoadError(
              message: 'Could not find a child profile. Please try again.',
              onRetry: _retryLoading,
            );
          }

          return _CategorySelection(childId: childId, repository: _repository);
        },
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🐻', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.pink,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
              child: const Text('Try again', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySelection extends StatelessWidget {
  final String childId;
  final QuizProgressRepository repository;

  const _CategorySelection({required this.childId, required this.repository});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.cream,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 20, 20, 4),
            child: Text(
              'Pick a quiz!',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w900,
                color: AppColors.darkGray,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Look, listen, and have fun!',
              style: TextStyle(fontSize: 18, color: AppColors.darkGray),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final columns = constraints.maxWidth >= 600 ? 3 : 2;
                return GridView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: quizCategories.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: columns,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, index) {
                    final category = quizCategories[index];
                    return _CategoryCard(
                      category: category,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => QuizScreen(
                              category: category,
                              childId: childId,
                              repository: repository,
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final QuizCategory category;
  final VoidCallback onTap;

  const _CategoryCard({required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: category.color,
      borderRadius: BorderRadius.circular(26),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(category.emoji, style: const TextStyle(fontSize: 58)),
              const SizedBox(height: 8),
              Text(
                category.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                '8 fun questions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final QuizCategory category;
  final String childId;
  final QuizProgressRepository repository;

  const QuizScreen({
    super.key,
    required this.category,
    required this.childId,
    required this.repository,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen>
    with SingleTickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  late final QuizCategory _quiz;
  late final AnimationController _correctAnimation;
  int _questionIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;
  bool _isSaving = false;
  String? _saveError;

  QuizQuestion get _question => _quiz.questions[_questionIndex];

  @override
  void initState() {
    super.initState();
    _quiz = widget.category.shuffled(Random());
    _correctAnimation = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _readQuestion());
  }

  @override
  void dispose() {
    _correctAnimation.dispose();
    unawaited(_tts.stop());
    super.dispose();
  }

  Future<void> _speak(String text) async {
    try {
      await _tts.setLanguage('en-US');
      await _tts.setSpeechRate(0.42);
      await _tts.speak(text);
    } catch (error) {
      debugPrint('Could not speak quiz prompt: $error');
    }
  }

  Future<void> _readQuestion() {
    final hint = _question.hint;
    return _speak(
      hint == null ? _question.questionText : '${_question.questionText} $hint',
    );
  }

  void _chooseAnswer(int index) {
    if (_answered || _isSaving) return;

    setState(() {
      _selectedAnswer = index;
      if (index == _question.correctAnswerIndex) {
        _answered = true;
        _score++;
      }
    });

    if (index == _question.correctAnswerIndex) {
      _correctAnimation.forward(from: 0);
      unawaited(_speak('Great job!'));
    }
  }

  Future<void> _nextQuestion() async {
    if (_questionIndex < _quiz.questions.length - 1) {
      setState(() {
        _questionIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
      await _correctAnimation.reverse();
      await _readQuestion();
      return;
    }
    await _saveResult();
  }

  int get _earnedStars {
    final scoreRatio = _score / _quiz.questions.length;
    if (scoreRatio >= 0.8) return 3;
    if (scoreRatio >= 0.5) return 2;
    return 1;
  }

  Future<void> _saveResult() async {
    if (_isSaving) return;
    setState(() {
      _isSaving = true;
      _saveError = null;
    });

    try {
      await widget.repository.saveQuizResult(
        childId: widget.childId,
        quizId: _quiz.quizId,
        score: _score,
        totalQuestions: _quiz.questions.length,
        stars: _earnedStars,
      );
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) => _QuizResultScreen(
            category: _quiz,
            score: _score,
            stars: _earnedStars,
          ),
        ),
      );
    } catch (error) {
      debugPrint('Could not save quiz progress: $error');
      if (!mounted) return;
      setState(() {
        _isSaving = false;
        _saveError = 'We could not save your stars. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _question;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: _quiz.color,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _readQuestion,
            tooltip: 'Read question aloud',
            icon: const Icon(Icons.volume_up_rounded, size: 30),
          ),
        ],
      ),
      body: ColoredBox(
        color: AppColors.cream,
        child: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value:
                                    (_questionIndex + 1) /
                                    _quiz.questions.length,
                                minHeight: 14,
                                color: _quiz.color,
                                backgroundColor: _quiz.color.withValues(
                                  alpha: 0.2,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '${_questionIndex + 1}/${_quiz.questions.length}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.darkGray,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Center(
                        child: AnimatedBuilder(
                          animation: _correctAnimation,
                          builder: (context, child) => Transform.scale(
                            scale: 1 + (_correctAnimation.value * 0.18),
                            child: child,
                          ),
                          child: Text(
                            question.emoji,
                            style: const TextStyle(fontSize: 74),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        question.questionText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 20),
                      for (
                        var index = 0;
                        index < question.options.length;
                        index++
                      )
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _AnswerCard(
                            option: question.options[index],
                            selected: _selectedAnswer == index,
                            correct:
                                _answered &&
                                index == question.correctAnswerIndex,
                            color: _quiz.color,
                            onTap: () => _chooseAnswer(index),
                          ),
                        ),
                      if (_selectedAnswer != null)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            _answered ? 'Great job! 🌟' : 'Try again! 💛',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: _answered
                                  ? const Color(0xFF2E9D65)
                                  : AppColors.darkGray,
                            ),
                          ),
                        ),
                      if (_saveError != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _saveError!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: AppColors.darkGray,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      if (_saveError != null)
                        FilledButton(
                          onPressed: _saveResult,
                          style: FilledButton.styleFrom(
                            backgroundColor: _quiz.color,
                            minimumSize: const Size.fromHeight(60),
                          ),
                          child: const Text(
                            'Save stars',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      if (_answered && _saveError == null)
                        FilledButton.icon(
                          onPressed: _isSaving ? null : _nextQuestion,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Colors.white,
                                  ),
                                )
                              : Icon(
                                  _questionIndex == _quiz.questions.length - 1
                                      ? Icons.emoji_events_rounded
                                      : Icons.arrow_forward_rounded,
                                ),
                          label: Text(
                            _isSaving
                                ? 'Saving stars...'
                                : _questionIndex == _quiz.questions.length - 1
                                ? 'See my stars'
                                : 'Next',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          style: FilledButton.styleFrom(
                            backgroundColor: _quiz.color,
                            minimumSize: const Size.fromHeight(64),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AnswerCard extends StatelessWidget {
  final QuizOption option;
  final bool selected;
  final bool correct;
  final Color color;
  final VoidCallback onTap;

  const _AnswerCard({
    required this.option,
    required this.selected,
    required this.correct,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background = correct
        ? const Color(0xFFE0F5E9)
        : selected
        ? const Color(0xFFFFF1D1)
        : Colors.white;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          constraints: const BoxConstraints(minHeight: 82),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: correct ? const Color(0xFF2E9D65) : color,
              width: selected ? 3 : 2,
            ),
          ),
          child: Row(
            children: [
              Text(option.emoji, style: const TextStyle(fontSize: 38)),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  option.text,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGray,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuizResultScreen extends StatelessWidget {
  final QuizCategory category;
  final int score;
  final int stars;

  const _QuizResultScreen({
    required this.category,
    required this.score,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('🎉', style: TextStyle(fontSize: 82)),
                const SizedBox(height: 12),
                const Text(
                  'You did it!',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${category.emoji} ${category.title}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  List.filled(stars, '⭐').join(' '),
                  style: const TextStyle(fontSize: 44),
                ),
                const SizedBox(height: 12),
                Text(
                  '$score of ${category.questions.length} right!',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGray,
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: FilledButton.styleFrom(
                    backgroundColor: category.color,
                    minimumSize: const Size.fromHeight(64),
                  ),
                  child: const Text(
                    'Pick another quiz',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
