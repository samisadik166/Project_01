import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../model/child.dart';
import '../model/quiz_model.dart';
import '../model/result_model.dart';
import '../utils/app_colors.dart';

class QuizzesPage extends StatefulWidget {
  const QuizzesPage({super.key});

  @override
  State<QuizzesPage> createState() => _QuizzesPageState();
}

class _QuizzesPageState extends State<QuizzesPage> {
  late Future<_QuizPageData> _quizzesFuture;

  @override
  void initState() {
    super.initState();
    _quizzesFuture = _loadQuizData();
  }

  Future<_QuizPageData> _loadQuizData() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    int childAge = 4;

    if (uid != null) {
      try {
        final childSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('children')
            .orderBy('createdAt', descending: false)
            .limit(1)
            .get();

        if (childSnapshot.docs.isNotEmpty) {
          childAge = ChildModel.fromDoc(childSnapshot.docs.first).age;
        }
      } catch (error) {
        debugPrint('Failed to load child age for quizzes: $error');
      }
    }

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('quizzes')
          .where('isActive', isEqualTo: true)
          .get();

      final quizzes = snapshot.docs.map(QuizModel.fromDoc).where((quiz) {
        if (quiz.ageRange.length < 2) return false;
        return childAge >= quiz.ageRange[0] && childAge <= quiz.ageRange[1];
      }).toList();

      final grouped = <String, List<QuizModel>>{};
      for (final quiz in quizzes) {
        grouped.putIfAbsent(quiz.category, () => <QuizModel>[]).add(quiz);
      }

      if (grouped.isEmpty) {
        final fallback = _buildFallbackQuizzesForAge(childAge);
        for (final quiz in fallback) {
          grouped.putIfAbsent(quiz.category, () => <QuizModel>[]).add(quiz);
        }
      }

      return _QuizPageData(age: childAge, groupedQuizzes: grouped);
    } catch (error) {
      debugPrint('Failed to load quizzes: $error');
      final fallback = _buildFallbackQuizzesForAge(childAge);
      final grouped = <String, List<QuizModel>>{};
      for (final quiz in fallback) {
        grouped.putIfAbsent(quiz.category, () => <QuizModel>[]).add(quiz);
      }
      return _QuizPageData(age: childAge, groupedQuizzes: grouped);
    }
  }

  List<QuizModel> _buildFallbackQuizzesForAge(int childAge) {
    final adjustedAge = childAge < 3 ? 3 : childAge;
    final maxAge = adjustedAge > 6 ? 6 : adjustedAge;

    final quizList = <QuizModel>[
      QuizModel(
        quizId: 'little_kids_shapes',
        title: 'Shape Match',
        category: 'Math',
        ageRange: [3, 6],
        difficulty: 'easy',
        iconUrl: '',
        isActive: true,
        questions: [
          QuestionModel(
            questionText: 'Which shape looks like a ball?',
            type: 'multiple_choice',
            options: ['Circle', 'Square', 'Triangle'],
            correctIndex: 0,
            order: 1,
          ),
          QuestionModel(
            questionText: 'How many sides does a square have?',
            type: 'multiple_choice',
            options: ['1', '2', '4'],
            correctIndex: 2,
            order: 2,
          ),
        ],
      ),
      QuizModel(
        quizId: 'little_kids_counting',
        title: 'Count the Stars',
        category: 'Math',
        ageRange: [3, 6],
        difficulty: 'easy',
        iconUrl: '',
        isActive: true,
        questions: [
          QuestionModel(
            questionText: 'What number comes after 4?',
            type: 'multiple_choice',
            options: ['3', '5', '6'],
            correctIndex: 1,
            order: 1,
          ),
          QuestionModel(
            questionText: 'Which group has 3 stars?',
            type: 'multiple_choice',
            options: ['★ ★', '★ ★ ★', '★ ★ ★ ★ ★'],
            correctIndex: 1,
            order: 2,
          ),
        ],
      ),
      QuizModel(
        quizId: 'little_kids_colors',
        title: 'Color Fun',
        category: 'Science',
        ageRange: [3, 6],
        difficulty: 'easy',
        iconUrl: '',
        isActive: true,
        questions: [
          QuestionModel(
            questionText: 'Which color is the sky on a sunny day?',
            type: 'multiple_choice',
            options: ['Red', 'Blue', 'Green'],
            correctIndex: 1,
            order: 1,
          ),
          QuestionModel(
            questionText: 'Which fruit is usually yellow?',
            type: 'multiple_choice',
            options: ['Banana', 'Apple', 'Grapes'],
            correctIndex: 0,
            order: 2,
          ),
        ],
      ),
    ];

    if (maxAge >= 5) {
      quizList.add(
        QuizModel(
          quizId: 'little_kids_letters',
          title: 'Letter Friends',
          category: 'Reading',
          ageRange: [4, 6],
          difficulty: 'easy',
          iconUrl: '',
          isActive: true,
          questions: [
            QuestionModel(
              questionText: 'Which letter comes first in the alphabet?',
              type: 'multiple_choice',
              options: ['B', 'A', 'C'],
              correctIndex: 1,
              order: 1,
            ),
            QuestionModel(
              questionText: 'Which word starts with M?',
              type: 'multiple_choice',
              options: ['Sun', 'Moon', 'Tree'],
              correctIndex: 1,
              order: 2,
            ),
          ],
        ),
      );
    }

    return quizList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
        backgroundColor: AppColors.pink,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<_QuizPageData>(
        future: _quizzesFuture,
        builder: (context, snapshot) {
          final data = snapshot.data;
          final groups = data?.groupedQuizzes ?? const {};

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.pink),
            );
          }

          final categories = groups.keys.toList();
          return Container(
            color: AppColors.cream,
            padding: const EdgeInsets.all(20),
            child: categories.isEmpty
                ? const Center(
                    child: Text(
                      'No quizzes available for this age yet.\nCome back soon!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGray,
                      ),
                    ),
                  )
                : ListView(
                    children: [
                      const Text(
                        'Choose a quiz!',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.darkGray,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Answer questions and earn stars.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 22),
                      ...categories.map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(bottom: 18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                category,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.darkGray,
                                ),
                              ),
                              const SizedBox(height: 10),
                              ...groups[category]!.map(
                                (quiz) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _QuizCard(quiz: quiz),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }
}

class _QuizCard extends StatelessWidget {
  final QuizModel quiz;

  const _QuizCard({required this.quiz});

  @override
  Widget build(BuildContext context) {
    final cardColor = _colorForCategory(quiz.category);

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => _QuizRoundPage(quiz: quiz))),
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: cardColor.withOpacity(0.16),
                child: Icon(
                  _iconForCategory(quiz.category),
                  color: cardColor,
                  size: 28,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      quiz.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkGray,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${quiz.questions.length} questions • ${quiz.difficulty}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.play_circle_fill_rounded, color: cardColor, size: 28),
            ],
          ),
        ),
      ),
    );
  }

  Color _colorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'math':
        return AppColors.yellow;
      case 'science':
        return AppColors.teal;
      default:
        return AppColors.pink;
    }
  }

  IconData _iconForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'math':
        return Icons.calculate_rounded;
      case 'science':
        return Icons.science_rounded;
      default:
        return Icons.quiz_rounded;
    }
  }
}

class _QuizPageData {
  final int age;
  final Map<String, List<QuizModel>> groupedQuizzes;

  const _QuizPageData({required this.age, required this.groupedQuizzes});
}

class _QuizRoundPage extends StatefulWidget {
  final QuizModel quiz;

  const _QuizRoundPage({required this.quiz});

  @override
  State<_QuizRoundPage> createState() => _QuizRoundPageState();
}

class _QuizRoundPageState extends State<_QuizRoundPage> {
  int _questionIndex = 0;
  int _score = 0;
  int? _selectedAnswer;
  bool _answered = false;

  void _chooseAnswer(int answer) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = answer;
      _answered = true;
      final question = widget.quiz.questions[_questionIndex];
      if (answer == question.correctIndex) {
        _score++;
      }
    });
  }

  Future<void> _submitResult() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save quiz results.')),
      );
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
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please add a child profile before playing.'),
          ),
        );
        return;
      }

      final childId = childSnapshot.docs.first.id;
      final childDoc = childSnapshot.docs.first.reference;
      final resultId = ResultModel.generateId(widget.quiz.quizId);
      final result = ResultModel(
        resultId: resultId,
        quizId: widget.quiz.quizId,
        score: _score,
        totalQuestions: widget.quiz.questions.length,
        stars: _starsForScore(),
        completedAt: DateTime.now(),
      );

      await childDoc.collection('results').doc(resultId).set(result.toMap());
      await childDoc.update({'totalStars': FieldValue.increment(result.stars)});

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => _QuizResultPage(
            quizTitle: widget.quiz.title,
            score: _score,
            totalQuestions: widget.quiz.questions.length,
            stars: result.stars,
            onPlayAgain: () => Navigator.of(context).pop(),
          ),
        ),
      );
    } catch (error) {
      debugPrint('Failed to save quiz result: $error');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not save your quiz results.')),
      );
    }
  }

  void _nextQuestion() {
    if (_questionIndex < widget.quiz.questions.length - 1) {
      setState(() {
        _questionIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
      return;
    }

    _submitResult();
  }

  int _starsForScore() {
    final percent = (widget.quiz.questions.isEmpty)
        ? 0
        : ((_score / widget.quiz.questions.length) * 100).round();

    if (percent >= 80) return 3;
    if (percent >= 50) return 2;
    if (_score > 0) return 1;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final complete = _questionIndex >= widget.quiz.questions.length;
    final question = widget.quiz.questions[_questionIndex];
    final barColor = _colorForCategory(widget.quiz.category);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        backgroundColor: barColor,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: AppColors.cream,
        padding: const EdgeInsets.all(20),
        child: complete
            ? const SizedBox.shrink()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.quiz.questions.length,
                      (index) => Container(
                        width: 10,
                        height: 10,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _questionIndex
                              ? barColor
                              : Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 26),
                  Text(
                    'Question ${_questionIndex + 1}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: barColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    question.questionText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: AppColors.darkGray,
                    ),
                  ),
                  const SizedBox(height: 28),
                  ...question.options.asMap().entries.map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _AnswerButton(
                        text: entry.value,
                        selected: _selectedAnswer == entry.key,
                        correct:
                            _answered && entry.key == question.correctIndex,
                        incorrect:
                            _answered &&
                            _selectedAnswer == entry.key &&
                            entry.key != question.correctIndex,
                        onTap: () => _chooseAnswer(entry.key),
                        color: barColor,
                      ),
                    ),
                  ),
                  const Spacer(),
                  if (_answered)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        _selectedAnswer == question.correctIndex
                            ? 'Great job!'
                            : 'Nice try! Keep going!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: _selectedAnswer == question.correctIndex
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ),
                  ElevatedButton.icon(
                    onPressed: _answered ? _nextQuestion : null,
                    icon: Icon(
                      _questionIndex == widget.quiz.questions.length - 1
                          ? Icons.check_rounded
                          : Icons.arrow_forward_rounded,
                    ),
                    label: Text(
                      _questionIndex == widget.quiz.questions.length - 1
                          ? 'Finish Quiz'
                          : 'Next Question',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: barColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Color _colorForCategory(String category) {
    switch (category.toLowerCase()) {
      case 'math':
        return AppColors.yellow;
      case 'science':
        return AppColors.teal;
      default:
        return AppColors.pink;
    }
  }
}

class _QuizResultPage extends StatelessWidget {
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final int stars;
  final VoidCallback onPlayAgain;

  const _QuizResultPage({
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.stars,
    required this.onPlayAgain,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.cream,
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                size: 72,
                color: AppColors.yellow,
              ),
              const SizedBox(height: 20),
              Text(
                'Great job!',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '$quizTitle complete',
                style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
              ),
              const SizedBox(height: 20),
              Text(
                'You earned $stars star${stars == 1 ? '' : 's'}!',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.pink,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Score: $score / $totalQuestions',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onPlayAgain,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.pink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Play Again'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnswerButton extends StatelessWidget {
  final String text;
  final bool selected;
  final bool correct;
  final bool incorrect;
  final VoidCallback onTap;
  final Color color;

  const _AnswerButton({
    required this.text,
    required this.selected,
    required this.correct,
    required this.incorrect,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 58,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: correct
              ? Colors.green
              : incorrect
              ? Colors.redAccent
              : Colors.white,
          foregroundColor: correct || incorrect
              ? Colors.white
              : AppColors.darkGray,
          side: BorderSide(
            color: selected ? color : Colors.grey.shade300,
            width: selected ? 3 : 1,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
