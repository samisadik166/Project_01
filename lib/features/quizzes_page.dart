import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Quizzes page
class QuizzesPage extends StatelessWidget {
  const QuizzesPage({super.key});

  static const _topics = [
    _QuizTopic(
      'Numbers Quiz',
      'Practice counting and simple sums.',
      Icons.looks_one_rounded,
      AppColors.yellow,
      [
        _Question('How many fingers are on one hand?', ['3', '5', '8'], 1),
        _Question('What comes after 4?', ['3', '5', '7'], 1),
        _Question('What is 1 + 1?', ['1', '2', '3'], 1),
      ],
    ),
    _QuizTopic(
      'Colors Quiz',
      'Learn the colors of the rainbow.',
      Icons.color_lens_rounded,
      AppColors.pink,
      [
        _Question('What color is a banana?', ['Blue', 'Yellow', 'Purple'], 1),
        _Question('Red and white make which color?', [
          'Pink',
          'Green',
          'Black',
        ], 0),
        _Question('What color is the sunny sky?', [
          'Orange',
          'Blue',
          'Brown',
        ], 1),
      ],
    ),
    _QuizTopic(
      'Animals Quiz',
      'Discover fun facts about animals.',
      Icons.pets_rounded,
      AppColors.teal,
      [
        _Question('Which animal says “moo”?', ['Cow', 'Cat', 'Duck'], 0),
        _Question('Which animal can fly?', ['Fish', 'Bird', 'Dog'], 1),
        _Question('Which animal has a long trunk?', [
          'Elephant',
          'Rabbit',
          'Frog',
        ], 0),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quizzes'),
        backgroundColor: AppColors.pink,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: AppColors.cream,
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'Choose a quiz!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Answer questions and earn stars.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 22),
            ..._topics.map(
              (topic) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _QuizCard(topic: topic),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizTopic {
  const _QuizTopic(
    this.title,
    this.subtitle,
    this.icon,
    this.color,
    this.questions,
  );
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<_Question> questions;
}

class _Question {
  const _Question(this.text, this.answers, this.correctAnswer);
  final String text;
  final List<String> answers;
  final int correctAnswer;
}

class _QuizCard extends StatelessWidget {
  const _QuizCard({required this.topic});
  final _QuizTopic topic;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    child: InkWell(
      onTap: () => Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => _QuizRoundPage(topic: topic))),
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: topic.color.withValues(alpha: 0.18),
              child: Icon(topic.icon, color: topic.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    topic.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    topic.subtitle,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Icon(Icons.play_circle_fill, color: topic.color),
          ],
        ),
      ),
    ),
  );
}

class _QuizRoundPage extends StatefulWidget {
  const _QuizRoundPage({required this.topic});
  final _QuizTopic topic;

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
      if (answer == widget.topic.questions[_questionIndex].correctAnswer)
        _score++;
    });
  }

  void _nextQuestion() {
    setState(() {
      _questionIndex++;
      _selectedAnswer = null;
      _answered = false;
    });
  }

  void _restart() => setState(() {
    _questionIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _answered = false;
  });

  @override
  Widget build(BuildContext context) {
    final complete = _questionIndex >= widget.topic.questions.length;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.topic.title),
        backgroundColor: widget.topic.color,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: AppColors.cream,
        padding: const EdgeInsets.all(20),
        child: complete ? _result() : _question(),
      ),
    );
  }

  Widget _question() {
    final question = widget.topic.questions[_questionIndex];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Question ${_questionIndex + 1} of ${widget.topic.questions.length}',
          style: TextStyle(
            color: widget.topic.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          question.text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: AppColors.darkGray,
          ),
        ),
        const SizedBox(height: 28),
        ...question.answers.asMap().entries.map(
          (entry) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _AnswerButton(
              text: entry.value,
              selected: _selectedAnswer == entry.key,
              correct: _answered && entry.key == question.correctAnswer,
              incorrect:
                  _answered &&
                  _selectedAnswer == entry.key &&
                  entry.key != question.correctAnswer,
              onTap: () => _chooseAnswer(entry.key),
              color: widget.topic.color,
            ),
          ),
        ),
        const Spacer(),
        if (_answered)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              _selectedAnswer == question.correctAnswer
                  ? 'Great job!'
                  : 'Good try! Keep learning!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: _selectedAnswer == question.correctAnswer
                    ? Colors.green
                    : Colors.orange,
              ),
            ),
          ),
        SizedBox(
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _answered ? _nextQuestion : null,
            icon: Icon(
              _questionIndex == widget.topic.questions.length - 1
                  ? Icons.check
                  : Icons.arrow_forward,
            ),
            label: Text(
              _questionIndex == widget.topic.questions.length - 1
                  ? 'See Score'
                  : 'Next Question',
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.topic.color,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _result() => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.emoji_events_rounded, size: 88, color: widget.topic.color),
        const SizedBox(height: 18),
        const Text(
          'Quiz complete!',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'You got $_score out of ${widget.topic.questions.length} correct.',
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: _restart,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: widget.topic.color,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    ),
  );
}

class _AnswerButton extends StatelessWidget {
  const _AnswerButton({
    required this.text,
    required this.selected,
    required this.correct,
    required this.incorrect,
    required this.onTap,
    required this.color,
  });
  final String text;
  final bool selected;
  final bool correct;
  final bool incorrect;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) => SizedBox(
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
