import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';
import '../utils/reward_service.dart';

/// Letter tracing page — kid draws each letter stroke by stroke, guided by
/// dotted paths and a mascot that demonstrates before they try.
class AlphabetPage extends StatefulWidget {
  const AlphabetPage({super.key});

  @override
  State<AlphabetPage> createState() => _AlphabetPageState();
}

// ---------------------------------------------------------------------------
// Stroke data model
// ---------------------------------------------------------------------------
// Each stroke is a polyline of NORMALIZED points (0..1 within the canvas box).
// Curves are approximated with more points along the curve.
class TracingLetterData {
  final String letter;
  final Color color;
  final List<List<Offset>> strokes; // empty strokes => "coming soon"

  const TracingLetterData(this.letter, this.color, this.strokes);
}

const double kCanvasSize = 280;

// All 26 letters are fully defined below, in A-Z order (this order controls
// the swipe/strip order in the UI — keep it alphabetical when editing).
final List<TracingLetterData> _allLetters = [
  TracingLetterData('A', AppColors.pink, [
    [const Offset(0.18, 0.92), const Offset(0.5, 0.08)],
    [const Offset(0.5, 0.08), const Offset(0.82, 0.92)],
    [const Offset(0.30, 0.62), const Offset(0.70, 0.62)],
  ]),
  TracingLetterData('B', AppColors.yellow, [
    [const Offset(0.25, 0.08), const Offset(0.25, 0.92)],
    [
      const Offset(0.25, 0.08),
      const Offset(0.55, 0.08),
      const Offset(0.72, 0.20),
      const Offset(0.72, 0.32),
      const Offset(0.55, 0.44),
      const Offset(0.25, 0.46),
      const Offset(0.58, 0.48),
      const Offset(0.76, 0.62),
      const Offset(0.76, 0.76),
      const Offset(0.58, 0.90),
      const Offset(0.25, 0.92),
    ],
  ]),
  TracingLetterData('C', AppColors.teal, [
    [
      const Offset(0.80, 0.22),
      const Offset(0.55, 0.08),
      const Offset(0.30, 0.15),
      const Offset(0.15, 0.35),
      const Offset(0.12, 0.5),
      const Offset(0.15, 0.65),
      const Offset(0.30, 0.85),
      const Offset(0.55, 0.92),
      const Offset(0.80, 0.78),
    ],
  ]),
  TracingLetterData('D', AppColors.purple, [
    [const Offset(0.22, 0.08), const Offset(0.22, 0.92)],
    [
      const Offset(0.22, 0.08),
      const Offset(0.55, 0.10),
      const Offset(0.75, 0.28),
      const Offset(0.80, 0.5),
      const Offset(0.75, 0.72),
      const Offset(0.55, 0.90),
      const Offset(0.22, 0.92),
    ],
  ]),
  TracingLetterData('E', AppColors.yellow, [
    [const Offset(0.25, 0.08), const Offset(0.25, 0.92)],
    [const Offset(0.25, 0.08), const Offset(0.78, 0.08)],
    [const Offset(0.25, 0.5), const Offset(0.65, 0.5)],
    [const Offset(0.25, 0.92), const Offset(0.78, 0.92)],
  ]),
  TracingLetterData('F', AppColors.teal, [
    [const Offset(0.25, 0.08), const Offset(0.25, 0.92)],
    [const Offset(0.25, 0.08), const Offset(0.78, 0.08)],
    [const Offset(0.25, 0.5), const Offset(0.65, 0.5)],
  ]),
  TracingLetterData('G', AppColors.purple, [
    [
      const Offset(0.80, 0.22),
      const Offset(0.55, 0.08),
      const Offset(0.30, 0.15),
      const Offset(0.15, 0.35),
      const Offset(0.12, 0.5),
      const Offset(0.15, 0.65),
      const Offset(0.30, 0.85),
      const Offset(0.55, 0.92),
      const Offset(0.78, 0.80),
      const Offset(0.78, 0.55),
    ],
    [const Offset(0.78, 0.55), const Offset(0.5, 0.55)],
  ]),
  TracingLetterData('H', AppColors.pink, [
    [const Offset(0.22, 0.08), const Offset(0.22, 0.92)],
    [const Offset(0.78, 0.08), const Offset(0.78, 0.92)],
    [const Offset(0.22, 0.5), const Offset(0.78, 0.5)],
  ]),
  TracingLetterData('I', AppColors.yellow, [
    [const Offset(0.3, 0.08), const Offset(0.7, 0.08)],
    [const Offset(0.5, 0.08), const Offset(0.5, 0.92)],
    [const Offset(0.3, 0.92), const Offset(0.7, 0.92)],
  ]),
  TracingLetterData('J', AppColors.teal, [
    [const Offset(0.3, 0.08), const Offset(0.7, 0.08)],
    [
      const Offset(0.55, 0.08),
      const Offset(0.55, 0.65),
      const Offset(0.5, 0.8),
      const Offset(0.35, 0.88),
      const Offset(0.2, 0.78),
    ],
  ]),
  TracingLetterData('K', AppColors.purple, [
    [const Offset(0.22, 0.08), const Offset(0.22, 0.92)],
    [const Offset(0.22, 0.5), const Offset(0.78, 0.08)],
    [const Offset(0.22, 0.5), const Offset(0.78, 0.92)],
  ]),
  TracingLetterData('L', AppColors.pink, [
    [const Offset(0.25, 0.08), const Offset(0.25, 0.92)],
    [const Offset(0.25, 0.92), const Offset(0.75, 0.92)],
  ]),
  TracingLetterData('M', AppColors.yellow, [
    [
      const Offset(0.15, 0.92),
      const Offset(0.15, 0.08),
      const Offset(0.5, 0.55),
      const Offset(0.85, 0.08),
      const Offset(0.85, 0.92),
    ],
  ]),
  TracingLetterData('N', AppColors.teal, [
    [
      const Offset(0.2, 0.92),
      const Offset(0.2, 0.08),
      const Offset(0.8, 0.92),
      const Offset(0.8, 0.08),
    ],
  ]),
  TracingLetterData('O', AppColors.pink, [
    [
      const Offset(0.5, 0.08),
      const Offset(0.28, 0.15),
      const Offset(0.14, 0.35),
      const Offset(0.12, 0.5),
      const Offset(0.14, 0.65),
      const Offset(0.28, 0.85),
      const Offset(0.5, 0.92),
    ],
    [
      const Offset(0.5, 0.08),
      const Offset(0.72, 0.15),
      const Offset(0.86, 0.35),
      const Offset(0.88, 0.5),
      const Offset(0.86, 0.65),
      const Offset(0.72, 0.85),
      const Offset(0.5, 0.92),
    ],
  ]),
  TracingLetterData('P', AppColors.purple, [
    [const Offset(0.25, 0.08), const Offset(0.25, 0.92)],
    [
      const Offset(0.25, 0.08),
      const Offset(0.6, 0.08),
      const Offset(0.78, 0.22),
      const Offset(0.78, 0.34),
      const Offset(0.6, 0.48),
      const Offset(0.25, 0.48),
    ],
  ]),
  TracingLetterData('Q', AppColors.pink, [
    [
      const Offset(0.5, 0.08),
      const Offset(0.28, 0.15),
      const Offset(0.14, 0.35),
      const Offset(0.12, 0.5),
      const Offset(0.14, 0.65),
      const Offset(0.28, 0.85),
      const Offset(0.5, 0.92),
    ],
    [
      const Offset(0.5, 0.08),
      const Offset(0.72, 0.15),
      const Offset(0.86, 0.35),
      const Offset(0.88, 0.5),
      const Offset(0.86, 0.65),
      const Offset(0.72, 0.85),
      const Offset(0.5, 0.92),
    ],
    [const Offset(0.58, 0.72), const Offset(0.85, 0.98)],
  ]),
  TracingLetterData('R', AppColors.yellow, [
    [const Offset(0.25, 0.08), const Offset(0.25, 0.92)],
    [
      const Offset(0.25, 0.08),
      const Offset(0.6, 0.08),
      const Offset(0.78, 0.22),
      const Offset(0.78, 0.34),
      const Offset(0.6, 0.48),
      const Offset(0.25, 0.48),
    ],
    [const Offset(0.4, 0.48), const Offset(0.78, 0.92)],
  ]),
  TracingLetterData('S', AppColors.teal, [
    [
      const Offset(0.75, 0.2),
      const Offset(0.55, 0.08),
      const Offset(0.3, 0.12),
      const Offset(0.18, 0.28),
      const Offset(0.28, 0.42),
      const Offset(0.5, 0.5),
      const Offset(0.72, 0.58),
      const Offset(0.82, 0.72),
      const Offset(0.7, 0.88),
      const Offset(0.45, 0.92),
      const Offset(0.22, 0.82),
    ],
  ]),
  TracingLetterData('T', AppColors.purple, [
    [const Offset(0.2, 0.08), const Offset(0.8, 0.08)],
    [const Offset(0.5, 0.08), const Offset(0.5, 0.92)],
  ]),
  TracingLetterData('U', AppColors.pink, [
    [
      const Offset(0.2, 0.08),
      const Offset(0.2, 0.65),
      const Offset(0.25, 0.85),
      const Offset(0.5, 0.92),
      const Offset(0.75, 0.85),
      const Offset(0.8, 0.65),
      const Offset(0.8, 0.08),
    ],
  ]),
  TracingLetterData('V', AppColors.yellow, [
    [const Offset(0.18, 0.08), const Offset(0.5, 0.92)],
    [const Offset(0.5, 0.92), const Offset(0.82, 0.08)],
  ]),
  TracingLetterData('W', AppColors.teal, [
    [
      const Offset(0.12, 0.08),
      const Offset(0.3, 0.92),
      const Offset(0.5, 0.4),
      const Offset(0.7, 0.92),
      const Offset(0.88, 0.08),
    ],
  ]),
  TracingLetterData('X', AppColors.purple, [
    [const Offset(0.2, 0.08), const Offset(0.8, 0.92)],
    [const Offset(0.8, 0.08), const Offset(0.2, 0.92)],
  ]),
  TracingLetterData('Y', AppColors.pink, [
    [const Offset(0.2, 0.08), const Offset(0.5, 0.5)],
    [const Offset(0.8, 0.08), const Offset(0.5, 0.5)],
    [const Offset(0.5, 0.5), const Offset(0.5, 0.92)],
  ]),
  TracingLetterData('Z', AppColors.yellow, [
    [
      const Offset(0.2, 0.08),
      const Offset(0.8, 0.08),
      const Offset(0.2, 0.92),
      const Offset(0.8, 0.92),
    ],
  ]),
];

class _AlphabetPageState extends State<AlphabetPage> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  void _goTo(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final current = _allLetters[_currentIndex];

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [current.color, AppColors.cream],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const Expanded(
                      child: Text(
                        'Let\'s Write! ✏️',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                child: Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var index = 0; index < _allLetters.length; index++)
                      _LetterButton(
                        letter: _allLetters[index].letter,
                        color: _allLetters[index].color,
                        selected: index == _currentIndex,
                        onTap: () => _goTo(index),
                      ),
                  ],
                ),
              ),

              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _allLetters.length,
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (index) =>
                      setState(() => _currentIndex = index),
                  itemBuilder: (context, index) => _TracingCard(
                    data: _allLetters[index],
                    onComplete: () async {
                      await RewardService.awardTaskStarsForCurrentChild(
                        taskType: 'alphabet',
                        taskId: _allLetters[index].letter,
                      );

                      if (index < _allLetters.length - 1) {
                        Future.delayed(
                          const Duration(milliseconds: 1200),
                          () => _goTo(index + 1),
                        );
                      }
                    },
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _NavButton(
                      icon: Icons.arrow_back_rounded,
                      enabled: _currentIndex > 0,
                      onTap: () => _goTo(_currentIndex - 1),
                    ),
                    Text(
                      '${_currentIndex + 1} / ${_allLetters.length}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                    _NavButton(
                      icon: Icons.arrow_forward_rounded,
                      enabled: _currentIndex < _allLetters.length - 1,
                      onTap: () => _goTo(_currentIndex + 1),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LetterButton extends StatelessWidget {
  final String letter;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _LetterButton({
    required this.letter,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? Colors.white : Colors.white.withOpacity(0.38),
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Text(
              letter,
              style: TextStyle(
                fontSize: selected ? 19 : 16,
                fontWeight: FontWeight.w800,
                color: selected ? color : Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Tracing card: mascot bubble + canvas + controls, for one letter
// ---------------------------------------------------------------------------
class _TracingCard extends StatefulWidget {
  final TracingLetterData data;
  final Future<void> Function() onComplete;

  const _TracingCard({required this.data, required this.onComplete});

  @override
  State<_TracingCard> createState() => _TracingCardState();
}

class _TracingCardState extends State<_TracingCard>
    with TickerProviderStateMixin {
  int _activeStroke = 0;
  final Set<int> _completedStrokes = {};
  List<Offset> _drawnPoints = [];
  String _mascotMessage = '';
  bool _celebrating = false;

  late final AnimationController _demoController;

  @override
  void initState() {
    super.initState();
    _demoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _resetForLetter();
  }

  @override
  void didUpdateWidget(covariant _TracingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.letter != widget.data.letter) _resetForLetter();
  }

  void _resetForLetter() {
    _activeStroke = 0;
    _completedStrokes.clear();
    _drawnPoints = [];
    _celebrating = false;
    _mascotMessage = widget.data.strokes.isEmpty
        ? "We're still learning to draw this one — try A, B, C, D or O for now! 🐻"
        : "Watch me first, then trace stroke 1! 🐻";
    if (widget.data.strokes.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _playDemo());
    }
  }

  @override
  void dispose() {
    _demoController.dispose();
    super.dispose();
  }

  Future<void> _playDemo() async {
    _demoController.reset();
    await _demoController.forward();
  }

  Path _buildScaledPath(List<Offset> normPoints) {
    final path = Path();
    final first = normPoints.first;
    path.moveTo(first.dx * kCanvasSize, first.dy * kCanvasSize);
    for (final p in normPoints.skip(1)) {
      path.lineTo(p.dx * kCanvasSize, p.dy * kCanvasSize);
    }
    return path;
  }

  List<Offset> _sampleAlongPath(Path path, int count) {
    final metrics = path.computeMetrics().toList();
    if (metrics.isEmpty) return [];
    final metric = metrics.first;
    final pts = <Offset>[];
    for (int i = 0; i < count; i++) {
      final dist = metric.length * i / (count - 1);
      final tangent = metric.getTangentForOffset(dist);
      if (tangent != null) pts.add(tangent.position);
    }
    return pts;
  }

  bool _checkStroke() {
    if (_drawnPoints.length < 4) return false;
    final guidePath = _buildScaledPath(widget.data.strokes[_activeStroke]);
    final samples = _sampleAlongPath(guidePath, 18);
    if (samples.isEmpty) return false;
    const tolerance = kCanvasSize * 0.16;
    int covered = 0;
    for (final gp in samples) {
      final hit = _drawnPoints.any((dp) => (dp - gp).distance < tolerance);
      if (hit) covered++;
    }
    return covered / samples.length >= 0.6;
  }

  void _onPanStart(DragStartDetails details) {
    if (widget.data.strokes.isEmpty || _celebrating) return;
    setState(() => _drawnPoints = [details.localPosition]);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (widget.data.strokes.isEmpty || _celebrating) return;
    setState(() => _drawnPoints.add(details.localPosition));
  }

  Future<void> _onPanEnd(DragEndDetails details) async {
    if (widget.data.strokes.isEmpty || _celebrating) return;

    final passed = _checkStroke();
    HapticFeedback.lightImpact();

    if (passed) {
      final isLastStroke = _activeStroke == widget.data.strokes.length - 1;
      setState(() {
        _completedStrokes.add(_activeStroke);
        _drawnPoints = [];
        if (isLastStroke) {
          _celebrating = true;
          _mascotMessage =
              "You wrote the letter ${widget.data.letter}! Amazing job! 🎉";
        } else {
          _activeStroke++;
          _mascotMessage =
              "Great job! ⭐ Now watch stroke ${_activeStroke + 1}.";
        }
      });
      if (isLastStroke) {
        await widget.onComplete();
      } else {
        await _playDemo();
      }
    } else {
      setState(() {
        _drawnPoints = [];
        _mascotMessage = "Almost! Follow the dots closely — try again! 💪";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasStrokes = widget.data.strokes.isNotEmpty;

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🐻', style: TextStyle(fontSize: 36)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _mascotMessage,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            widget.data.letter,
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.w900,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Container(
              width: kCanvasSize,
              height: kCanvasSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: hasStrokes
                  ? AnimatedBuilder(
                      animation: _demoController,
                      builder: (context, _) {
                        return CustomPaint(
                          painter: _TracingPainter(
                            data: widget.data,
                            activeStroke: _activeStroke,
                            completedStrokes: _completedStrokes,
                            drawnPoints: _drawnPoints,
                            demoProgress: _demoController.value,
                          ),
                        );
                      },
                    )
                  : const Center(
                      child: Text('🚧', style: TextStyle(fontSize: 48)),
                    ),
            ),
          ),
          const SizedBox(height: 16),

          if (hasStrokes)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 0; i < widget.data.strokes.length; i++)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _completedStrokes.contains(i)
                          ? Colors.white
                          : Colors.white.withOpacity(0.35),
                    ),
                  ),
              ],
            ),
          const SizedBox(height: 12),

          if (hasStrokes && !_celebrating)
            TextButton.icon(
              onPressed: _playDemo,
              icon: const Icon(Icons.visibility_rounded, color: Colors.white),
              label: const Text(
                'Show Me Again',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Painter: dashed guide strokes + mascot demo line + kid's drawn strokes
// ---------------------------------------------------------------------------
class _TracingPainter extends CustomPainter {
  final TracingLetterData data;
  final int activeStroke;
  final Set<int> completedStrokes;
  final List<Offset> drawnPoints;
  final double demoProgress;

  _TracingPainter({
    required this.data,
    required this.activeStroke,
    required this.completedStrokes,
    required this.drawnPoints,
    required this.demoProgress,
  });

  Path _scaledPath(List<Offset> normPoints, Size size) {
    final path = Path();
    final first = normPoints.first;
    path.moveTo(first.dx * size.width, first.dy * size.height);
    for (final p in normPoints.skip(1)) {
      path.lineTo(p.dx * size.width, p.dy * size.height);
    }
    return path;
  }

  void _drawDashed(Canvas canvas, Path path, Paint paint) {
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      const dash = 8.0, gap = 6.0;
      while (distance < metric.length) {
        final next = (distance + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < data.strokes.length; i++) {
      final path = _scaledPath(data.strokes[i], size);

      if (completedStrokes.contains(i)) {
        canvas.drawPath(
          path,
          Paint()
            ..color = data.color
            ..strokeWidth = 8
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke,
        );
      } else {
        _drawDashed(
          canvas,
          path,
          Paint()
            ..color = i == activeStroke
                ? data.color.withOpacity(0.6)
                : Colors.grey.withOpacity(0.25)
            ..strokeWidth = 5
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke,
        );
      }
    }

    if (activeStroke < data.strokes.length &&
        demoProgress < 1.0 &&
        demoProgress > 0.0) {
      final activePath = _scaledPath(data.strokes[activeStroke], size);
      final metrics = activePath.computeMetrics().toList();
      if (metrics.isNotEmpty) {
        final metric = metrics.first;
        final partial = metric.extractPath(0, metric.length * demoProgress);
        canvas.drawPath(
          partial,
          Paint()
            ..color = data.color
            ..strokeWidth = 6
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke,
        );
        final tip = metric.getTangentForOffset(metric.length * demoProgress);
        if (tip != null) {
          canvas.drawCircle(tip.position, 9, Paint()..color = data.color);
        }
      }
    }

    if (drawnPoints.length > 1) {
      final drawnPath = Path()
        ..moveTo(drawnPoints.first.dx, drawnPoints.first.dy);
      for (final p in drawnPoints.skip(1)) {
        drawnPath.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        drawnPath,
        Paint()
          ..color = AppColors.darkGray
          ..strokeWidth = 7
          ..strokeCap = StrokeCap.round
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _TracingPainter oldDelegate) => true;
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : Colors.white.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: enabled ? AppColors.darkGray : Colors.white70),
      ),
    );
  }
}
