import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

/// Interactive games page.
class GamesPage extends StatelessWidget {
  const GamesPage({super.key});

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Interactive Games'),
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
                      builder: (_) => _GameRoundPage(info: game),
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
  const _GameRoundPage({required this.info});
  final _GameInfo info;

  @override
  State<_GameRoundPage> createState() => _GameRoundPageState();
}

class _GameRoundPageState extends State<_GameRoundPage> {
  int _target = 5;
  int _count = 0;
  int _colorTarget = 0;
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
    if (_count < _target) setState(() => _count++);
  }

  void _nextNumber() => setState(() {
    _target = _target == 9 ? 3 : _target + 1;
    _count = 0;
  });

  void _tapColor(int index) {
    if (index == _colorTarget)
      setState(() => _colorTarget = (_colorTarget + 1) % colors.length);
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
    } else {
      setState(() => _firstCard = null);
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

  Widget _countGame() => Column(
    children: [
      Text('Tap $_target stars', style: const TextStyle(fontSize: 22)),
      const SizedBox(height: 12),
      Text(
        '$_count / $_target',
        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
      ),
      Expanded(
        child: Center(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              _target,
              (i) => IconButton(
                onPressed: _tapStar,
                icon: Icon(
                  i < _count ? Icons.star : Icons.star_border,
                  color: AppColors.yellow,
                ),
                iconSize: 58,
              ),
            ),
          ),
        ),
      ),
      _button(
        _count == _target ? 'Next Number' : 'Keep Counting',
        Icons.star,
        _count == _target ? _nextNumber : null,
      ),
    ],
  );

  Widget _colorGame() => Column(
    children: [
      Text(
        'Tap the ${colorNames[_colorTarget]} circle',
        style: const TextStyle(fontSize: 22),
      ),
      Expanded(
        child: Center(
          child: Wrap(
            spacing: 18,
            runSpacing: 18,
            children: List.generate(
              colors.length,
              (i) => InkWell(
                onTap: () => _tapColor(i),
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: colors[i],
                  child: i == _colorTarget
                      ? const Icon(Icons.touch_app, color: Colors.white)
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
      const Text(
        'Keep going!',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    ],
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
