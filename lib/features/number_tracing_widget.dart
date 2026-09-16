import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_colors.dart';

/// Interactive number tracing experience for kids — same engine as the
/// alphabet tracing page: dotted stroke guides, a mascot that demonstrates
/// each stroke first, then the kid traces with their finger and gets checked.
class NumberTracingWidget extends StatefulWidget {
  const NumberTracingWidget({super.key});

  @override
  State<NumberTracingWidget> createState() => _NumberTracingWidgetState();
}

// ---------------------------------------------------------------------------
// Stroke data model — normalized 0..1 points per stroke, digits 0-9
// ---------------------------------------------------------------------------
class TracingNumberData {
  final String digit;
  final Color color;
  final List<List<Offset>> strokes;

  const TracingNumberData(this.digit, this.color, this.strokes);
}

const double kNumCanvasSize = 260;

final List<TracingNumberData> _allNumbers = [
  TracingNumberData('0', AppColors.pink, [
    [
      const Offset(0.5, 0.1),
      const Offset(0.28, 0.2),
      const Offset(0.15, 0.38),
      const Offset(0.14, 0.5),
      const Offset(0.15, 0.62),
      const Offset(0.28, 0.8),
      const Offset(0.5, 0.9),
    ],
    [
      const Offset(0.5, 0.1),
      const Offset(0.72, 0.2),
      const Offset(0.85, 0.38),
      const Offset(0.86, 0.5),
      const Offset(0.85, 0.62),
      const Offset(0.72, 0.8),
      const Offset(0.5, 0.9),
    ],
  ]),
  TracingNumberData('1', AppColors.yellow, [
    [const Offset(0.35, 0.22), const Offset(0.5, 0.1), const Offset(0.5, 0.9)],
  ]),
  TracingNumberData('2', AppColors.teal, [
    [
      const Offset(0.2, 0.25),
      const Offset(0.3, 0.1),
      const Offset(0.6, 0.1),
      const Offset(0.75, 0.25),
      const Offset(0.7, 0.4),
      const Offset(0.2, 0.85),
      const Offset(0.8, 0.85),
    ],
  ]),
  TracingNumberData('3', AppColors.purple, [
    [
      const Offset(0.2, 0.15),
      const Offset(0.55, 0.1),
      const Offset(0.72, 0.25),
      const Offset(0.6, 0.42),
      const Offset(0.35, 0.45),
      const Offset(0.6, 0.48),
      const Offset(0.75, 0.65),
      const Offset(0.6, 0.85),
      const Offset(0.2, 0.85),
    ],
  ]),
  TracingNumberData('4', AppColors.pink, [
    [const Offset(0.6, 0.1), const Offset(0.2, 0.65), const Offset(0.8, 0.65)],
    [const Offset(0.6, 0.1), const Offset(0.6, 0.9)],
  ]),
  TracingNumberData('5', AppColors.yellow, [
    [
      const Offset(0.7, 0.1),
      const Offset(0.25, 0.1),
      const Offset(0.25, 0.42),
      const Offset(0.5, 0.38),
      const Offset(0.72, 0.5),
      const Offset(0.72, 0.72),
      const Offset(0.5, 0.88),
      const Offset(0.25, 0.82),
    ],
  ]),
  TracingNumberData('6', AppColors.teal, [
    [
      const Offset(0.65, 0.12),
      const Offset(0.35, 0.2),
      const Offset(0.2, 0.45),
      const Offset(0.2, 0.7),
      const Offset(0.35, 0.88),
      const Offset(0.6, 0.88),
      const Offset(0.75, 0.72),
      const Offset(0.75, 0.55),
      const Offset(0.6, 0.42),
      const Offset(0.35, 0.45),
    ],
  ]),
  TracingNumberData('7', AppColors.purple, [
    [
      const Offset(0.22, 0.12),
      const Offset(0.78, 0.12),
      const Offset(0.42, 0.9),
    ],
  ]),
  TracingNumberData('8', AppColors.pink, [
    [
      const Offset(0.5, 0.48),
      const Offset(0.3, 0.4),
      const Offset(0.28, 0.22),
      const Offset(0.5, 0.12),
      const Offset(0.72, 0.22),
      const Offset(0.7, 0.4),
      const Offset(0.5, 0.48),
    ],
    [
      const Offset(0.5, 0.48),
      const Offset(0.28, 0.58),
      const Offset(0.25, 0.75),
      const Offset(0.5, 0.88),
      const Offset(0.75, 0.75),
      const Offset(0.72, 0.58),
      const Offset(0.5, 0.48),
    ],
  ]),
  TracingNumberData('9', AppColors.yellow, [
    [
      const Offset(0.65, 0.45),
      const Offset(0.5, 0.58),
      const Offset(0.3, 0.55),
      const Offset(0.22, 0.38),
      const Offset(0.3, 0.2),
      const Offset(0.55, 0.15),
      const Offset(0.72, 0.28),
      const Offset(0.72, 0.5),
      const Offset(0.6, 0.75),
      const Offset(0.4, 0.88),
    ],
  ]),
];

class _NumberTracingWidgetState extends State<NumberTracingWidget> {
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
    return Column(
      children: [
        // Jump-to-digit strip
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            itemCount: _allNumbers.length,
            itemBuilder: (context, index) {
              final isSelected = index == _currentIndex;
              return GestureDetector(
                onTap: () => _goTo(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isSelected ? 42 : 34,
                  height: isSelected ? 42 : 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected ? _allNumbers[index].color : Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _allNumbers[index].color,
                      width: 2,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.12),
                              blurRadius: 6,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Text(
                    _allNumbers[index].digit,
                    style: TextStyle(
                      fontSize: isSelected ? 18 : 14,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? Colors.white
                          : _allNumbers[index].color,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        SizedBox(
          height: 560,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _allNumbers.length,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) =>
                _NumberTracingCard(data: _allNumbers[index]),
          ),
        ),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _NavButton(
                icon: Icons.arrow_back_rounded,
                enabled: _currentIndex > 0,
                onTap: () => _goTo(_currentIndex - 1),
              ),
              Text(
                '${_currentIndex + 1} / ${_allNumbers.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGray,
                  fontSize: 14,
                ),
              ),
              _NavButton(
                icon: Icons.arrow_forward_rounded,
                enabled: _currentIndex < _allNumbers.length - 1,
                onTap: () => _goTo(_currentIndex + 1),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Tracing card: mascot bubble + canvas + controls, for one digit
// ---------------------------------------------------------------------------
class _NumberTracingCard extends StatefulWidget {
  final TracingNumberData data;
  const _NumberTracingCard({required this.data});

  @override
  State<_NumberTracingCard> createState() => _NumberTracingCardState();
}

class _NumberTracingCardState extends State<_NumberTracingCard>
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
    _resetForNumber();
  }

  @override
  void didUpdateWidget(covariant _NumberTracingCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.digit != widget.data.digit) _resetForNumber();
  }

  void _resetForNumber() {
    _activeStroke = 0;
    _completedStrokes.clear();
    _drawnPoints = [];
    _celebrating = false;
    _mascotMessage = "Watch me first, then trace stroke 1! 🐻";
    WidgetsBinding.instance.addPostFrameCallback((_) => _playDemo());
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
    path.moveTo(first.dx * kNumCanvasSize, first.dy * kNumCanvasSize);
    for (final p in normPoints.skip(1)) {
      path.lineTo(p.dx * kNumCanvasSize, p.dy * kNumCanvasSize);
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
    const tolerance = kNumCanvasSize * 0.16;
    int covered = 0;
    for (final gp in samples) {
      final hit = _drawnPoints.any((dp) => (dp - gp).distance < tolerance);
      if (hit) covered++;
    }
    return covered / samples.length >= 0.6;
  }

  void _onPanStart(DragStartDetails details) {
    if (_celebrating) return;
    setState(() => _drawnPoints = [details.localPosition]);
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_celebrating) return;
    setState(() => _drawnPoints.add(details.localPosition));
  }

  Future<void> _onPanEnd(DragEndDetails details) async {
    if (_celebrating) return;

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
              "You wrote the number ${widget.data.digit}! Amazing job! 🎉";
        } else {
          _activeStroke++;
          _mascotMessage =
              "Great job! ⭐ Now watch stroke ${_activeStroke + 1}.";
        }
      });
      if (!isLastStroke) await _playDemo();
    } else {
      setState(() {
        _drawnPoints = [];
        _mascotMessage = "Almost! Follow the dots closely — try again! 💪";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Text('🐻', style: TextStyle(fontSize: 32)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _mascotMessage,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.darkGray,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          Text(
            widget.data.digit,
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: widget.data.color,
            ),
          ),
          const SizedBox(height: 10),

          GestureDetector(
            onPanStart: _onPanStart,
            onPanUpdate: _onPanUpdate,
            onPanEnd: _onPanEnd,
            child: Container(
              width: kNumCanvasSize,
              height: kNumCanvasSize,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: widget.data.color.withOpacity(0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _demoController,
                builder: (context, _) {
                  return CustomPaint(
                    painter: _NumberTracingPainter(
                      data: widget.data,
                      activeStroke: _activeStroke,
                      completedStrokes: _completedStrokes,
                      drawnPoints: _drawnPoints,
                      demoProgress: _demoController.value,
                    ),
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 14),

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
                        ? widget.data.color
                        : widget.data.color.withOpacity(0.25),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          if (!_celebrating)
            TextButton.icon(
              onPressed: _playDemo,
              icon: Icon(Icons.visibility_rounded, color: widget.data.color),
              label: Text(
                'Show Me Again',
                style: TextStyle(
                  color: widget.data.color,
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
class _NumberTracingPainter extends CustomPainter {
  final TracingNumberData data;
  final int activeStroke;
  final Set<int> completedStrokes;
  final List<Offset> drawnPoints;
  final double demoProgress;

  _NumberTracingPainter({
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
  bool shouldRepaint(covariant _NumberTracingPainter oldDelegate) => true;
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
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          color: enabled ? AppColors.yellow : Colors.grey.shade300,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}
