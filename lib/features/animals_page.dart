import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';

class _Animal {
  final String name;
  final String emoji;
  final String sound;
  final String soundFile; // lives in assets/sounds/
  final String fact;
  final Color color; // soft pastel card colour

  const _Animal({
    required this.name,
    required this.emoji,
    required this.sound,
    required this.soundFile,
    required this.fact,
    required this.color,
  });
}

const List<_Animal> _animals = [
  _Animal(
    name: 'Dog',
    emoji: '🐶',
    sound: 'Woof!',
    soundFile: 'dog.wav',
    fact: 'Dogs love to play fetch and wag their tails when they are happy!',
    color: Color(0xFFFFE0B2),
  ),
  _Animal(
    name: 'Cat',
    emoji: '🐱',
    sound: 'Meow!',
    soundFile: 'cat.wav',
    fact: 'Cats purr when they are happy. They have long whiskers too!',
    color: Color(0xFFF8BBD0),
  ),
  _Animal(
    name: 'Cow',
    emoji: '🐮',
    sound: 'Moo!',
    soundFile: 'cow.wav',
    fact: 'Cows give us milk and love to eat grass all day long.',
    color: Color(0xFFD7CCC8),
  ),
  _Animal(
    name: 'Monkey',
    emoji: '🐵',
    sound: 'Ooh ooh ah ah!',
    soundFile: 'monkey.wav',
    fact: 'Monkeys love bananas and swing from branch to branch!',
    color: Color(0xFFFFCCBC),
  ),
  _Animal(
    name: 'Lion',
    emoji: '🦁',
    sound: 'Roar!',
    soundFile: 'lion.wav',
    fact: 'Lions are the kings of the jungle. They live with their big family!',
    color: Color(0xFFFFF59D),
  ),
  _Animal(
    name: 'Duck',
    emoji: '🦆',
    sound: 'Quack!',
    soundFile: 'duck.wav',
    fact: 'Ducks love to swim in the pond. Their feathers keep them dry!',
    color: Color(0xFFB3E5FC),
  ),
  _Animal(
    name: 'Sheep',
    emoji: '🐑',
    sound: 'Baa!',
    soundFile: 'sheep.wav',
    fact: 'Sheep have soft, fluffy wool. It makes warm sweaters and blankets!',
    color: Color(0xFFE1BEE7),
  ),
  _Animal(
    name: 'Frog',
    emoji: '🐸',
    sound: 'Ribbit!',
    soundFile: 'frog.wav',
    fact: 'Frogs can jump very far and catch flies with their sticky tongues!',
    color: Color(0xFFC8E6C9),
  ),
  _Animal(
    name: 'Pig',
    emoji: '🐷',
    sound: 'Oink!',
    soundFile: 'pig.wav',
    fact: 'Pigs are very smart. They roll in mud to stay cool!',
    color: Color(0xFFFFCDD2),
  ),
];

/// Animals learning page for young children (3-6 years).
/// Tap an animal to hear its sound. Tap the "i" for a fun fact.
/// Tap "Guess!" to play a listening game.
class AnimalsPage extends StatefulWidget {
  const AnimalsPage({super.key});

  @override
  State<AnimalsPage> createState() => _AnimalsPageState();
}

class _AnimalsPageState extends State<AnimalsPage> {
  final AudioPlayer _player = AudioPlayer();
  int? _activeIndex;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  Future<void> _playSound(_Animal animal) async {
    HapticFeedback.lightImpact();
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/${animal.soundFile}'));
    } catch (e) {
      // Missing/unsupported file should never crash the page.
      debugPrint('Could not play ${animal.soundFile}: $e');
    }
  }

  Future<void> _onAnimalTap(int index) async {
    setState(() => _activeIndex = index);
    _playSound(_animals[index]);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted && _activeIndex == index) {
      setState(() => _activeIndex = null);
    }
  }

  void _showAnimalInfo(_Animal animal) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: animal.color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(animal.emoji, style: const TextStyle(fontSize: 96)),
              Text(
                '${animal.name[0]} is for ${animal.name}',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkGray,
                ),
              ),
              const SizedBox(height: 14),
              ElevatedButton.icon(
                onPressed: () => _playSound(animal),
                icon: const Icon(Icons.volume_up_rounded, size: 32),
                label: Text(
                  animal.sound,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.purple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(180, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(28),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  animal.fact,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 19,
                    height: 1.4,
                    color: AppColors.darkGray,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: () => Navigator.of(ctx).pop(),
                icon: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.purple,
                  size: 30,
                ),
                label: const Text(
                  'Got it!',
                  style: TextStyle(
                    color: AppColors.purple,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showGuessGame() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _GuessDialog(onPlay: _playSound),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF0),
      appBar: AppBar(
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showGuessGame,
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.hearing_rounded, size: 30),
        label: const Text(
          'Guess!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      body: GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.8,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
        ),
        itemCount: _animals.length,
        itemBuilder: (context, index) {
          final animal = _animals[index];
          final active = _activeIndex == index;
          return AnimatedScale(
            scale: active ? 1.08 : 1.0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.elasticOut,
            child: GestureDetector(
              onTap: () => _onAnimalTap(index),
              child: Container(
                decoration: BoxDecoration(
                  color: animal.color,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: active ? AppColors.purple : Colors.transparent,
                    width: 4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            animal.emoji,
                            style: const TextStyle(fontSize: 76),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            animal.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.darkGray,
                            ),
                          ),
                          const SizedBox(height: 8),
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.purple
                                  : Colors.white.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.volume_up_rounded,
                                  size: 20,
                                  color: active
                                      ? Colors.white
                                      : AppColors.purple,
                                ),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    animal.sound,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: active
                                          ? Colors.white
                                          : AppColors.purple,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: IconButton(
                        onPressed: () => _showAnimalInfo(animal),
                        icon: const Icon(Icons.info_rounded, size: 30),
                        color: AppColors.purple,
                        tooltip: 'Learn more',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// "Which animal says this?" listening game.
class _GuessDialog extends StatefulWidget {
  final Future<void> Function(_Animal animal) onPlay;
  const _GuessDialog({required this.onPlay});

  @override
  State<_GuessDialog> createState() => _GuessDialogState();
}

class _GuessDialogState extends State<_GuessDialog> {
  final Random _random = Random();
  late _Animal _target;
  late List<_Animal> _options;
  final Set<String> _wrong = {};
  String _message = 'Listen... who is it?';
  bool _solved = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _newRound();
  }

  void _newRound() {
    final target = _animals[_random.nextInt(_animals.length)];
    final others = _animals.where((a) => a != target).toList()..shuffle();
    setState(() {
      _target = target;
      _options = [target, others[0], others[1]]..shuffle();
      _wrong.clear();
      _solved = false;
      _message = 'Listen... who is it?';
    });
    widget.onPlay(target);
  }

  Future<void> _choose(_Animal animal) async {
    if (_solved || _wrong.contains(animal.name)) return;
    if (animal == _target) {
      setState(() {
        _solved = true;
        _score++;
        _message = 'Yay! It is a ${animal.name}! 🎉';
      });
      await Future.delayed(const Duration(milliseconds: 1800));
      if (mounted) _newRound();
    } else {
      HapticFeedback.mediumImpact();
      setState(() {
        _wrong.add(animal.name);
        _message = 'Oops, try again! 🙂';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      color: Colors.amber,
                      size: 30,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$_score',
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkGray,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded, size: 30),
                  color: AppColors.darkGray,
                ),
              ],
            ),
            ElevatedButton.icon(
              onPressed: () => widget.onPlay(_target),
              icon: const Icon(Icons.volume_up_rounded, size: 34),
              label: const Text(
                'Listen',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                foregroundColor: Colors.white,
                minimumSize: const Size(180, 60),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: _options.map((animal) {
                final wrong = _wrong.contains(animal.name);
                final correct = _solved && animal == _target;
                return GestureDetector(
                  onTap: () => _choose(animal),
                  child: AnimatedOpacity(
                    opacity: wrong ? 0.3 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: AnimatedScale(
                      scale: correct ? 1.15 : 1.0,
                      duration: const Duration(milliseconds: 350),
                      curve: Curves.elasticOut,
                      child: Container(
                        width: 84,
                        height: 84,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: animal.color,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: correct ? Colors.green : Colors.transparent,
                            width: 4,
                          ),
                        ),
                        child: Text(
                          animal.emoji,
                          style: const TextStyle(fontSize: 48),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
