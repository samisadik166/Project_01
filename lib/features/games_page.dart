import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/reward_service.dart';

/// Interactive games page.
class GamesPage extends StatelessWidget {
  const GamesPage({super.key, required this.childId, this.initialGameIndex});

  final String childId;
  final int? initialGameIndex;

  @override
  Widget build(BuildContext context) {
    final games = [
      const _GameInfo(
        'Count the Stars',
        'Tap stars to reach the number.',
        Icons.star_rounded,
        AppColors.yellow,
        _GameKind.count,
      ),
      const _GameInfo(
        'Find the Color',
        'Tap the color named at the top.',
        Icons.palette_rounded,
        AppColors.teal,
        _GameKind.color,
      ),
      const _GameInfo(
        'Memory Match',
        'Find pairs of friendly pictures.',
        Icons.grid_view_rounded,
        AppColors.purple,
        _GameKind.memory,
      ),
    ];

    final selectedGame = initialGameIndex == null
        ? null
        : games[initialGameIndex!];

    if (selectedGame != null) {
      return _GameRoundPage(info: selectedGame, childId: childId);
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.yellow,
        foregroundColor: Colors.white,
      ),
      body: Container(
        color: AppColors.cream,
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            const Text(
              'Pick a game!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGray,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Learn, play, and collect stars as you go.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            const SizedBox(height: 22),
            ...games.map(
              (game) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: _GameCard(
                  info: game,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          _GameRoundPage(info: game, childId: childId),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum _GameKind { count, color, memory }

class _GameInfo {
  const _GameInfo(
    this.title,
    this.description,
    this.icon,
    this.color,
    this.kind,
  );
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final _GameKind kind;
}

class _GameCard extends StatelessWidget {
  const _GameCard({required this.info, required this.onTap});
  final _GameInfo info;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    elevation: 0,
    color: Colors.white,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: info.color.withValues(alpha: 0.18),
              child: Icon(info.icon, color: info.color),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    info.description,
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            Icon(Icons.play_circle_fill, color: info.color),
          ],
        ),
      ),
    ),
  );
}

class _GameRoundPage extends StatefulWidget {
  const _GameRoundPage({required this.info, required this.childId});
  final _GameInfo info;
  final String childId;

  @override
  State<_GameRoundPage> createState() => _GameRoundPageState();
}

class _GameRoundPageState extends State<_GameRoundPage> {
  int _target = 5;
  int _count = 0;
  int _colorTarget = 0;
  int _colorCorrectTaps = 0;
  String? _colorFeedback;
  int? _firstCard;
  final Set<int> _matchedCards = {};
  final List<IconData> _memoryCards = [
    Icons.apple,
    Icons.apple,
    Icons.pets,
    Icons.pets,
    Icons.cake,
    Icons.cake,
    Icons.wb_sunny,
    Icons.wb_sunny,
  ];
  static const colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.pink,
  ];
  static const colorNames = [
    'red',
    'blue',
    'green',
    'orange',
    'purple',
    'pink',
  ];

  void _tapStar() {
    if (_count >= _target) return;
    setState(() => _count++);
    if (_count == _target) _recordGameCompletion('count_$_target');
  }

  void _nextNumber() => setState(() {
    _target = _target == 9 ? 3 : _target + 1;
    _count = 0;
  });

  void _tapColor(int index) {
    if (_colorCorrectTaps >= colors.length) return;
    final colorIndex = (index + _colorCorrectTaps * 2) % colors.length;
    if (colorIndex != _colorTarget) {
      setState(() {
        _colorFeedback = 'Almost! Find ${colorNames[_colorTarget]} again.';
      });
      return;
    }

    setState(() {
      _colorCorrectTaps++;
      _colorFeedback = _colorCorrectTaps == colors.length
          ? 'Color champion! You found them all!'
          : 'Great finding! Now look for ${colorNames[_colorCorrectTaps]}.';
      if (_colorCorrectTaps < colors.length) {
        _colorTarget = _colorCorrectTaps;
      }
    });
    if (_colorCorrectTaps == colors.length) {
      _recordGameCompletion('color_round');
    }
  }

  void _restartColorRound() {
    setState(() {
      _colorTarget = 0;
      _colorCorrectTaps = 0;
      _colorFeedback = null;
    });
  }

  void _tapMemory(int index) {
    if (_matchedCards.contains(index) || _firstCard == index) return;
    if (_firstCard == null) {
      setState(() => _firstCard = index);
    } else if (_memoryCards[_firstCard!] == _memoryCards[index]) {
      setState(() {
        _matchedCards.addAll([_firstCard!, index]);
        _firstCard = null;
      });
      if (_matchedCards.length == _memoryCards.length) {
        _recordGameCompletion('memory_pairs');
      }
    } else {
      setState(() => _firstCard = null);
    }
  }

  Future<void> _recordGameCompletion(String taskId) async {
    try {
      await RewardService.awardTaskStarsForCurrentChild(
        childId: widget.childId,
        taskType: 'game',
        taskId: taskId,
      );
    } catch (error) {
      debugPrint('Could not save game activity: $error');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.info.title),
      backgroundColor: widget.info.color,
      foregroundColor: Colors.white,
    ),
    body: Container(
      color: AppColors.cream,
      padding: const EdgeInsets.all(20),
      child: _buildGame(),
    ),
  );

  Widget _buildGame() {
    switch (widget.info.kind) {
      case _GameKind.count:
        return _countGame();
      case _GameKind.color:
        return _colorGame();
      case _GameKind.memory:
        return _memoryGame();
    }
  }

  Widget _countGame() => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxHeight < 500;
      final complete = _count == _target;

      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(compact ? 12 : 20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.yellow,
                  AppColors.yellow.withValues(alpha: 0.78),
                ],
              ),
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: AppColors.yellow.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Row(
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0x44FFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(compact ? 8 : 12),
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: AppColors.darkGray,
                      size: compact ? 26 : 34,
                    ),
                  ),
                ),
                SizedBox(width: compact ? 10 : 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        complete ? 'Star catcher!' : 'Ready, star catcher?',
                        style: TextStyle(
                          color: AppColors.darkGray,
                          fontSize: compact ? 18 : 21,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        complete
                            ? 'You caught them all! ⭐'
                            : 'Catch $_target twinkly stars!',
                        style: const TextStyle(
                          color: AppColors.darkGray,
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: compact ? 10 : 20),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 18,
              vertical: compact ? 10 : 14,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your star pocket',
                      style: TextStyle(
                        color: AppColors.darkGray,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 220),
                      transitionBuilder: (child, animation) =>
                          ScaleTransition(scale: animation, child: child),
                      child: Text(
                        '$_count / $_target',
                        key: ValueKey('star-count-$_count'),
                        style: TextStyle(
                          color: AppColors.darkGray,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: compact ? 7 : 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: LinearProgressIndicator(
                    value: _count / _target,
                    minHeight: 12,
                    backgroundColor: AppColors.yellow.withValues(alpha: 0.18),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.yellow,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: compact ? 8 : 12),
          Expanded(
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: compact ? 8 : 12,
                runSpacing: compact ? 6 : 10,
                children: List.generate(_target, (i) {
                  final collected = i < _count;
                  return Semantics(
                    button: true,
                    label: 'Star ${i + 1}${collected ? ', caught' : ''}',
                    child: InkWell(
                      key: ValueKey('count-star-$i'),
                      onTap: collected ? null : _tapStar,
                      borderRadius: BorderRadius.circular(24),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.easeOutBack,
                        width: compact ? 54 : 66,
                        height: compact ? 54 : 66,
                        decoration: BoxDecoration(
                          color: collected
                              ? AppColors.yellow.withValues(alpha: 0.22)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: collected
                                ? AppColors.yellow
                                : AppColors.yellow.withValues(alpha: 0.28),
                            width: collected ? 2.5 : 1.5,
                          ),
                          boxShadow: collected
                              ? [
                                  BoxShadow(
                                    color: AppColors.yellow.withValues(
                                      alpha: 0.22,
                                    ),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: AnimatedScale(
                          scale: collected ? 1.12 : 1,
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutBack,
                          child: Icon(
                            collected
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: AppColors.yellow,
                            size: compact ? 38 : 46,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          if (complete)
            _button(
              'Catch more stars!',
              Icons.auto_awesome_rounded,
              _nextNumber,
            )
          else
            const Padding(
              padding: EdgeInsets.only(bottom: 8, top: 4),
              child: Text(
                'Tap each star to catch it!',
                style: TextStyle(
                  color: AppColors.darkGray,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      );
    },
  );

  Widget _colorGame() => LayoutBuilder(
    builder: (context, constraints) {
      final compact = constraints.maxHeight < 500;
      final complete = _colorCorrectTaps == colors.length;

      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(compact ? 12 : 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.teal, AppColors.sky],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color: AppColors.teal.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: compact ? 48 : 58,
                  height: compact ? 48 : 58,
                  decoration: const BoxDecoration(
                    color: Color(0x44FFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    complete
                        ? Icons.emoji_events_rounded
                        : Icons.color_lens_rounded,
                    color: AppColors.darkGray,
                    size: compact ? 28 : 34,
                  ),
                ),
                SizedBox(width: compact ? 10 : 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        complete ? 'Color champion!' : 'Color quest',
                        style: TextStyle(
                          color: AppColors.darkGray,
                          fontSize: compact ? 19 : 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              complete
                                  ? 'You found every color!'
                                  : 'Find this color:',
                              style: const TextStyle(
                                color: AppColors.darkGray,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (!complete) ...[
                            const SizedBox(width: 7),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Text(
                                colorNames[_colorTarget].toUpperCase(),
                                style: TextStyle(
                                  color: colors[_colorTarget],
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: compact ? 10 : 16),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 12 : 16,
              vertical: compact ? 9 : 12,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Colors found',
                      style: TextStyle(
                        color: AppColors.darkGray,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      '$_colorCorrectTaps / ${colors.length}',
                      style: const TextStyle(
                        color: AppColors.darkGray,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: List.generate(
                    colors.length,
                    (i) => Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        height: 9,
                        margin: EdgeInsets.only(
                          right: i == colors.length - 1 ? 0 : 5,
                        ),
                        decoration: BoxDecoration(
                          color: i < _colorCorrectTaps
                              ? colors[i]
                              : colors[i].withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: compact ? 10 : 14,
                runSpacing: compact ? 8 : 12,
                children: List.generate(colors.length, (slot) {
                  final colorIndex =
                      (slot + _colorCorrectTaps * 2) % colors.length;
                  return Semantics(
                    button: !complete,
                    label: '${colorNames[colorIndex]} color',
                    child: InkWell(
                      key: ValueKey('color-choice-$slot'),
                      onTap: complete ? null : () => _tapColor(slot),
                      borderRadius: BorderRadius.circular(22),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 240),
                        curve: Curves.easeOutBack,
                        width: compact ? 76 : 88,
                        height: compact ? 76 : 88,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: colors[colorIndex].withValues(alpha: 0.35),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors[colorIndex].withValues(alpha: 0.15),
                              blurRadius: 9,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 240),
                            width: compact ? 48 : 56,
                            height: compact ? 48 : 56,
                            decoration: BoxDecoration(
                              color: colors[colorIndex],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              colorIndex == _colorTarget && !complete
                                  ? Icons.touch_app_rounded
                                  : Icons.star_rounded,
                              color: Colors.white,
                              size: compact ? 27 : 32,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          if (complete)
            _button(
              'Play again',
              Icons.refresh_rounded,
              _restartColorRound,
            )
          else
            Padding(
              padding: const EdgeInsets.only(bottom: 8, top: 4),
              child: Text(
                _colorFeedback ?? 'Look carefully — the colors can move!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _colorFeedback?.startsWith('Almost') == true
                      ? AppColors.orange
                      : AppColors.darkGray,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      );
    },
  );

  Widget _memoryGame() => Column(
    children: [
      const Text('Find matching pictures', style: TextStyle(fontSize: 22)),
      const SizedBox(height: 16),
      Expanded(
        child: GridView.builder(
          itemCount: _memoryCards.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (_, i) {
            final visible = _matchedCards.contains(i) || _firstCard == i;
            return InkWell(
              onTap: () => _tapMemory(i),
              child: Container(
                decoration: BoxDecoration(
                  color: visible ? AppColors.purple : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  visible ? _memoryCards[i] : Icons.question_mark_rounded,
                  color: visible ? Colors.white : AppColors.purple,
                ),
              ),
            );
          },
        ),
      ),
      _button(
        'Start Over',
        Icons.refresh,
        () => setState(() {
          _firstCard = null;
          _matchedCards.clear();
        }),
      ),
    ],
  );

  Widget _button(String label, IconData icon, VoidCallback? onPressed) =>
      SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon),
          label: Text(label),
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.info.color,
            foregroundColor: Colors.white,
          ),
        ),
      );
}
