import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/reward_service.dart';

/// A traceable picture made of normalised (0..1) polyline strokes.
class DrawingBlueprint {
  final String id;
  final String name;
  final String emoji;
  final Color color;
  final List<List<Offset>> strokes;

  /// Short, friendly instruction shouted at the child while they trace.
  final String tip;

  const DrawingBlueprint({
    required this.id,
    required this.name,
    required this.emoji,
    required this.color,
    required this.strokes,
    this.tip = 'Trace the dotted lines!',
  });
}

class BlueprintLibrary {
  static const List<DrawingBlueprint> all = [
    DrawingBlueprint(
      id: 'star',
      name: 'Star',
      emoji: '⭐',
      color: AppColors.yellow,
      tip: 'Start at the top and go zig-zag!',
      strokes: [
        [
          Offset(0.50, 0.08),
          Offset(0.61, 0.38),
          Offset(0.93, 0.38),
          Offset(0.68, 0.57),
          Offset(0.78, 0.90),
          Offset(0.50, 0.70),
          Offset(0.22, 0.90),
          Offset(0.32, 0.57),
          Offset(0.07, 0.38),
          Offset(0.39, 0.38),
          Offset(0.50, 0.08),
        ],
      ],
    ),
    DrawingBlueprint(
      id: 'house',
      name: 'House',
      emoji: '🏠',
      color: AppColors.pink,
      tip: 'Roof first, then the walls!',
      strokes: [
        [
          Offset(0.12, 0.44),
          Offset(0.50, 0.10),
          Offset(0.88, 0.44),
          Offset(0.78, 0.44),
          Offset(0.78, 0.90),
          Offset(0.22, 0.90),
          Offset(0.22, 0.44),
          Offset(0.12, 0.44),
        ],
      ],
    ),
    DrawingBlueprint(
      id: 'heart',
      name: 'Heart',
      emoji: '❤️',
      color: AppColors.purple,
      tip: 'Down one side, up the other!',
      strokes: [
        [
          Offset(0.50, 0.88),
          Offset(0.16, 0.55),
          Offset(0.10, 0.37),
          Offset(0.18, 0.20),
          Offset(0.34, 0.16),
          Offset(0.50, 0.31),
          Offset(0.66, 0.16),
          Offset(0.82, 0.20),
          Offset(0.90, 0.37),
          Offset(0.84, 0.55),
          Offset(0.50, 0.88),
        ],
      ],
    ),
    DrawingBlueprint(
      id: 'fish',
      name: 'Fish',
      emoji: '🐟',
      color: AppColors.sky,
      tip: 'Round the body, then the tail!',
      strokes: [
        [
          Offset(0.30, 0.50),
          Offset(0.36, 0.32),
          Offset(0.54, 0.28),
          Offset(0.72, 0.42),
          Offset(0.78, 0.55),
          Offset(0.68, 0.70),
          Offset(0.46, 0.74),
          Offset(0.32, 0.66),
          Offset(0.30, 0.50),
        ],
        [Offset(0.30, 0.50), Offset(0.10, 0.28), Offset(0.12, 0.52), Offset(0.10, 0.74), Offset(0.30, 0.50)],
      ],
    ),
    DrawingBlueprint(
      id: 'flower',
      name: 'Flower',
      emoji: '🌸',
      color: AppColors.pink,
      tip: 'Draw the petals all the way around!',
      strokes: [
        [Offset(0.50, 0.94), Offset(0.50, 0.58)],
        [Offset(0.50, 0.80), Offset(0.30, 0.68), Offset(0.50, 0.72)],
        [
          Offset(0.50, 0.14),
          Offset(0.64, 0.20),
          Offset(0.72, 0.34),
          Offset(0.72, 0.46),
          Offset(0.62, 0.58),
          Offset(0.50, 0.62),
          Offset(0.38, 0.58),
          Offset(0.28, 0.46),
          Offset(0.28, 0.34),
          Offset(0.36, 0.20),
          Offset(0.50, 0.14),
        ],
      ],
    ),
    DrawingBlueprint(
      id: 'butterfly',
      name: 'Butterfly',
      emoji: '🦋',
      color: AppColors.purple,
      tip: 'Two wings and a tummy in the middle!',
      strokes: [
        [
          Offset(0.50, 0.52),
          Offset(0.34, 0.30),
          Offset(0.16, 0.26),
          Offset(0.10, 0.40),
          Offset(0.24, 0.50),
          Offset(0.12, 0.62),
          Offset(0.20, 0.76),
          Offset(0.38, 0.68),
          Offset(0.50, 0.52),
        ],
        [
          Offset(0.50, 0.52),
          Offset(0.66, 0.30),
          Offset(0.84, 0.26),
          Offset(0.90, 0.40),
          Offset(0.76, 0.50),
          Offset(0.88, 0.62),
          Offset(0.80, 0.76),
          Offset(0.62, 0.68),
          Offset(0.50, 0.52),
        ],
        [Offset(0.50, 0.22), Offset(0.50, 0.78)],
      ],
    ),
    DrawingBlueprint(
      id: 'tree',
      name: 'Tree',
      emoji: '🌳',
      color: AppColors.green,
      tip: 'A big fluffy top and a brown trunk!',
      strokes: [
        [Offset(0.42, 0.92), Offset(0.42, 0.55)],
        [Offset(0.58, 0.92), Offset(0.58, 0.55)],
        [Offset(0.42, 0.92), Offset(0.58, 0.92)],
        [
          Offset(0.50, 0.12),
          Offset(0.70, 0.20),
          Offset(0.78, 0.40),
          Offset(0.62, 0.56),
          Offset(0.38, 0.56),
          Offset(0.22, 0.40),
          Offset(0.30, 0.20),
          Offset(0.50, 0.12),
        ],
      ],
    ),
    DrawingBlueprint(
      id: 'rainbow',
      name: 'Rainbow',
      emoji: '🌈',
      color: AppColors.sky,
      tip: 'Three big arches, one inside the other!',
      strokes: [
        [
          Offset(0.08, 0.88),
          Offset(0.12, 0.58),
          Offset(0.28, 0.34),
          Offset(0.50, 0.26),
          Offset(0.72, 0.34),
          Offset(0.88, 0.58),
          Offset(0.92, 0.88),
        ],
        [
          Offset(0.20, 0.88),
          Offset(0.24, 0.62),
          Offset(0.36, 0.44),
          Offset(0.50, 0.38),
          Offset(0.64, 0.44),
          Offset(0.76, 0.62),
          Offset(0.80, 0.88),
        ],
        [
          Offset(0.32, 0.88),
          Offset(0.36, 0.68),
          Offset(0.44, 0.54),
          Offset(0.50, 0.50),
          Offset(0.56, 0.54),
          Offset(0.64, 0.68),
          Offset(0.68, 0.88),
        ],
      ],
    ),
    DrawingBlueprint(
      id: 'cat',
      name: 'Cat',
      emoji: '🐱',
      color: AppColors.orange,
      tip: 'A round head with two pointy ears!',
      strokes: [
        [
          Offset(0.50, 0.32),
          Offset(0.72, 0.36),
          Offset(0.82, 0.54),
          Offset(0.78, 0.74),
          Offset(0.50, 0.86),
          Offset(0.22, 0.74),
          Offset(0.18, 0.54),
          Offset(0.28, 0.36),
          Offset(0.50, 0.32),
        ],
        [Offset(0.28, 0.36), Offset(0.22, 0.12), Offset(0.44, 0.30)],
        [Offset(0.72, 0.36), Offset(0.78, 0.12), Offset(0.56, 0.30)],
      ],
    ),
    DrawingBlueprint(
      id: 'ice_cream',
      name: 'Ice Cream',
      emoji: '🍦',
      color: AppColors.pink,
      tip: 'A scoop on top of a triangle cone!',
      strokes: [
        [
          Offset(0.28, 0.46),
          Offset(0.30, 0.26),
          Offset(0.44, 0.16),
          Offset(0.56, 0.16),
          Offset(0.70, 0.26),
          Offset(0.72, 0.46),
          Offset(0.50, 0.54),
          Offset(0.28, 0.46),
        ],
        [Offset(0.30, 0.50), Offset(0.50, 0.94), Offset(0.70, 0.50)],
      ],
    ),
    DrawingBlueprint(
      id: 'boat',
      name: 'Boat',
      emoji: '⛵',
      color: AppColors.teal,
      tip: 'A hull, a mast and a big sail!',
      strokes: [
        [Offset(0.14, 0.64), Offset(0.86, 0.64), Offset(0.70, 0.86), Offset(0.30, 0.86), Offset(0.14, 0.64)],
        [Offset(0.50, 0.64), Offset(0.50, 0.14)],
        [Offset(0.50, 0.16), Offset(0.80, 0.58), Offset(0.50, 0.58)],
      ],
    ),
    DrawingBlueprint(
      id: 'balloon',
      name: 'Balloon',
      emoji: '🎈',
      color: Colors.red,
      tip: 'A round balloon with a wiggly string!',
      strokes: [
        [
          Offset(0.50, 0.10),
          Offset(0.68, 0.20),
          Offset(0.74, 0.38),
          Offset(0.62, 0.54),
          Offset(0.50, 0.60),
          Offset(0.38, 0.54),
          Offset(0.26, 0.38),
          Offset(0.32, 0.20),
          Offset(0.50, 0.10),
        ],
        [Offset(0.50, 0.60), Offset(0.45, 0.72), Offset(0.55, 0.84), Offset(0.50, 0.94)],
      ],
    ),
  ];
}

/// The kind of crayon the child is holding.
enum BrushKind { crayon, rainbow, glitter, eraser }

class DrawingPath {
  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final BrushKind kind;

  const DrawingPath({
    required this.points,
    required this.color,
    required this.strokeWidth,
    this.kind = BrushKind.crayon,
  });

  DrawingPath copyWith({List<Offset>? points}) => DrawingPath(
    points: points ?? this.points,
    color: color,
    strokeWidth: strokeWidth,
    kind: kind,
  );
}

/// A friendly emoji the child can stamp onto the paper.
class StickerStamp {
  final String emoji;
  final Offset position; // normalised 0..1
  final double scale;

  const StickerStamp({
    required this.emoji,
    required this.position,
    this.scale = 0.13,
  });
}

/// Number of samples used to check how much of a guide stroke was traced.
const int _guideSamples = 26;

/// Where a blueprint is drawn inside the paper, in normalised coordinates.
Rect blueprintBounds(Size size) {
  final side = math.min(size.width, size.height) * 0.82;
  final origin = Offset((size.width - side) / 2, (size.height - side) / 2);
  return Rect.fromLTWH(origin.dx, origin.dy, side, side);
}

Offset _mapTo(Rect bounds, Offset point) => Offset(
  bounds.left + point.dx * bounds.width,
  bounds.top + point.dy * bounds.height,
);

/// Point at fraction [t] (0..1) along a normalised polyline.
Offset _pointAlong(List<Offset> points, double t) {
  if (points.length == 1) return points.first;
  final segments = <double>[];
  var total = 0.0;
  for (var i = 0; i < points.length - 1; i++) {
    final d = (points[i + 1] - points[i]).distance;
    segments.add(d);
    total += d;
  }
  if (total == 0) return points.first;
  var target = t.clamp(0.0, 1.0) * total;
  for (var i = 0; i < segments.length; i++) {
    if (target <= segments[i] || i == segments.length - 1) {
      final f = segments[i] == 0
          ? 0.0
          : (target / segments[i]).clamp(0.0, 1.0);
      return Offset.lerp(points[i], points[i + 1], f)!;
    }
    target -= segments[i];
  }
  return points.last;
}

class DrawingPage extends StatefulWidget {
  final String childId;

  const DrawingPage({super.key, required this.childId});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage>
    with TickerProviderStateMixin {
  final List<DrawingPath> _paths = [];
  final List<StickerStamp> _stickers = [];
  DrawingPath? _currentPath;
  DrawingBlueprint? _selectedBlueprint;
  Color _selectedColor = AppColors.purple;
  double _strokeWidth = 6;
  bool _hasRecordedDrawing = false;
  bool _finished = false;

  BrushKind _brushKind = BrushKind.crayon;
  String? _activeSticker;

  Size _canvasSize = Size.zero;
  Set<int> _completedStrokes = {};
  int _activeStroke = 0;
  String? _celebratedBlueprintId;

  late final AnimationController _pulseController;
  late final AnimationController _demoController;
  late final AnimationController _celebrateController;
  int _demoStroke = 0;
  bool _celebrating = false;
  List<_Confetti> _confetti = const [];
  String _celebrationMessage = 'Yay! 🎉';

  static const List<Color> _colorPalette = [
    Colors.black,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    AppColors.pink,
    AppColors.yellow,
    AppColors.teal,
    AppColors.purple,
    AppColors.sky,
    Colors.brown,
    Colors.white,
  ];

  static const List<String> _stickerChoices = [
    '⭐',
    '❤️',
    '🌈',
    '🌸',
    '🦋',
    '🐟',
    '🐱',
    '🎈',
    '🍦',
    '☀️',
    '🐢',
    '🚀',
  ];

  static const List<String> _cheers = [
    'Yay! You did it! 🎉',
    'Wow, so pretty! 🌟',
    'Amazing colouring! 🎨',
    'You are an artist! 🖍️',
    'Super duper! 🦄',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 950),
    )..repeat(reverse: true);
    _demoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _celebrateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => _celebrating = false);
        }
      });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _demoController.dispose();
    _celebrateController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Drawing
  // ---------------------------------------------------------------------------
  void _onPanStart(DragStartDetails details) {
    // While a sticker is selected, stamps are placed by onTapDown so a single
    // touch never drops two stickers.
    if (_activeSticker != null) return;
    setState(() {
      _finished = false;
      _currentPath = DrawingPath(
        points: [details.localPosition],
        color: _selectedColor,
        strokeWidth: _strokeWidth,
        kind: _brushKind,
      );
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_activeSticker != null || _currentPath == null) return;
    setState(() {
      _currentPath = _currentPath!.copyWith(
        points: [..._currentPath!.points, details.localPosition],
      );
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_activeSticker != null) return;
    setState(() {
      if (_currentPath != null) _paths.add(_currentPath!);
      _currentPath = null;
    });
    _updateTraceProgress();
    _recordFirstDrawing();
  }

  void _stampSticker(Offset position) {
    if (_canvasSize.isEmpty) return;
    setState(() {
      _finished = false;
      _stickers.add(
        StickerStamp(
          emoji: _activeSticker!,
          position: Offset(
            (position.dx / _canvasSize.width).clamp(0.03, 0.97),
            (position.dy / _canvasSize.height).clamp(0.03, 0.97),
          ),
        ),
      );
    });
  }

  Future<void> _recordFirstDrawing() async {
    if (_hasRecordedDrawing || _paths.isEmpty) return;
    _hasRecordedDrawing = true;
    try {
      await RewardService.awardTaskStarsForCurrentChild(
        childId: widget.childId,
        taskType: 'drawing',
        taskId: 'first_drawing',
      );
    } catch (error) {
      debugPrint('Could not save drawing activity: $error');
    }
  }

  // ---------------------------------------------------------------------------
  // Guided tracing helpers
  // ---------------------------------------------------------------------------
  void _updateTraceProgress() {
    final blueprint = _selectedBlueprint;
    if (blueprint == null || _canvasSize.isEmpty) return;

    final bounds = blueprintBounds(_canvasSize);
    final drawn = <Offset>[
      for (final path in _paths) ...path.points,
      if (_currentPath != null) ..._currentPath!.points,
    ];
    final tolerance = bounds.width * 0.13;

    final completed = <int>{};
    for (var i = 0; i < blueprint.strokes.length; i++) {
      final stroke = blueprint.strokes[i];
      if (stroke.isEmpty) continue;
      var covered = 0;
      for (var s = 0; s < _guideSamples; s++) {
        final t = _guideSamples == 1 ? 0.0 : s / (_guideSamples - 1);
        final target = _mapTo(bounds, _pointAlong(stroke, t));
        if (_isCovered(target, drawn, tolerance)) covered++;
      }
      if (covered / _guideSamples >= 0.5) completed.add(i);
    }

    final firstIncomplete = List.generate(blueprint.strokes.length, (i) => i)
        .firstWhere((i) => !completed.contains(i), orElse: () => -1);

    final changed =
        completed.length != _completedStrokes.length ||
        !completed.containsAll(_completedStrokes);
    final newActive = firstIncomplete < 0 ? _activeStroke : firstIncomplete;

    if (changed || newActive != _activeStroke) {
      setState(() {
        _completedStrokes = completed;
        _activeStroke = newActive;
      });
    }

    final allDone =
        completed.length == blueprint.strokes.length &&
        blueprint.strokes.isNotEmpty;
    if (allDone && _celebratedBlueprintId != blueprint.id) {
      _celebratedBlueprintId = blueprint.id;
      _awardBlueprintStar(blueprint);
      _celebrate('You drew a ${blueprint.name}! ${blueprint.emoji}');
    }
  }

  bool _isCovered(Offset target, List<Offset> drawn, double tolerance) {
    for (var i = 0; i < drawn.length; i += 2) {
      if ((drawn[i] - target).distance <= tolerance) return true;
    }
    // Always include the final point so short, quick strokes still count.
    if (drawn.isNotEmpty && (drawn.last - target).distance <= tolerance) {
      return true;
    }
    return false;
  }

  Future<void> _awardBlueprintStar(DrawingBlueprint blueprint) async {
    try {
      await RewardService.awardTaskStarsForCurrentChild(
        childId: widget.childId,
        taskType: 'drawing',
        taskId: 'blueprint_${blueprint.id}',
        stars: 2,
      );
    } catch (error) {
      debugPrint('Could not save blueprint reward: $error');
    }
  }

  // ---------------------------------------------------------------------------
  // Celebrations
  // ---------------------------------------------------------------------------
  void _celebrate([String? message]) {
    final random = math.Random();
    final colors = [
      AppColors.pink,
      AppColors.yellow,
      AppColors.teal,
      AppColors.purple,
      AppColors.sky,
      AppColors.orange,
      AppColors.green,
    ];
    setState(() {
      _celebrating = true;
      _celebrationMessage =
          message ?? _cheers[random.nextInt(_cheers.length)];
      _confetti = List.generate(70, (index) {
        return _Confetti(
          x: random.nextDouble(),
          delay: random.nextDouble() * 0.35,
          speed: 0.75 + random.nextDouble() * 0.6,
          drift: (random.nextDouble() - 0.5) * 0.35,
          size: 6 + random.nextDouble() * 9,
          spin: random.nextDouble() * math.pi,
          color: colors[random.nextInt(colors.length)],
        );
      });
    });
    _celebrateController.forward(from: 0);
  }

  void _finishDrawing() {
    setState(() => _finished = true);
    _celebrate();
    if (_selectedBlueprint != null) {
      _awardBlueprintStar(_selectedBlueprint!);
    }
  }

  void _startDemo() {
    final blueprint = _selectedBlueprint;
    if (blueprint == null || blueprint.strokes.isEmpty) return;
    _demoStroke = _activeStroke.clamp(0, blueprint.strokes.length - 1);
    _demoController.forward(from: 0);
  }

  // ---------------------------------------------------------------------------
  // Editing
  // ---------------------------------------------------------------------------
  void _selectBlueprint(DrawingBlueprint? blueprint) {
    setState(() {
      _selectedBlueprint = blueprint;
      _paths.clear();
      _stickers.clear();
      _currentPath = null;
      _finished = false;
      _completedStrokes = {};
      _activeStroke = 0;
      _celebratedBlueprintId = null;
      _demoController.reset();
    });
  }

  void _selectBrush(BrushKind kind) {
    setState(() {
      _brushKind = kind;
      _activeSticker = null;
      if (kind == BrushKind.eraser) {
        _strokeWidth = math.max(_strokeWidth, 12);
      }
    });
  }

  void _undo() {
    if (_paths.isEmpty && _stickers.isEmpty) return;
    setState(() {
      if (_paths.isNotEmpty) {
        _paths.removeLast();
      } else {
        _stickers.removeLast();
      }
      _finished = false;
      _completedStrokes = {};
      _activeStroke = 0;
      _celebratedBlueprintId = null;
    });
  }

  void _clear() {
    setState(() {
      _paths.clear();
      _stickers.clear();
      _currentPath = null;
      _finished = false;
      _completedStrokes = {};
      _activeStroke = 0;
      _celebratedBlueprintId = null;
    });
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final hasDrawing =
        _paths.isNotEmpty || _currentPath != null || _stickers.isNotEmpty;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Drawing & Coloring'),
        backgroundColor: AppColors.purple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.undo_rounded),
            onPressed: (_paths.isNotEmpty || _stickers.isNotEmpty)
                ? _undo
                : null,
            tooltip: 'Undo',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            onPressed: hasDrawing ? _clear : null,
            tooltip: 'Clear',
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.cream, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildPicker(),
              _buildHeader(hasDrawing),
              Expanded(child: _buildCanvas()),
              _buildControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPicker() => SizedBox(
    height: 84,
    child: ListView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      children: [
        _BlueprintChip(
          label: 'Free Draw',
          selected: _selectedBlueprint == null,
          onTap: () => _selectBlueprint(null),
        ),
        for (final blueprint in BlueprintLibrary.all)
          _BlueprintChip(
            label: blueprint.name,
            emoji: blueprint.emoji,
            color: blueprint.color,
            selected: _selectedBlueprint?.id == blueprint.id,
            onTap: () => _selectBlueprint(blueprint),
          ),
      ],
    ),
  );

  Widget _buildHeader(bool hasDrawing) {
    final blueprint = _selectedBlueprint;
    if (blueprint == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            Text('🖍️', style: TextStyle(fontSize: 18)),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Free Draw — doodle anything you like!',
                style: TextStyle(
                  color: AppColors.darkGray,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    final total = blueprint.strokes.length;
    final done = _completedStrokes.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _finished
                      ? 'Lovely drawing! ⭐'
                      : 'Drawing ${blueprint.emoji} ${blueprint.name}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.darkGray,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  done == total
                      ? 'All finished! ☑️'
                      : '${blueprint.tip}  (${done + (done == total ? 0 : 1)}/$total)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.darkGray.withValues(alpha: 0.6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          _PillButton(
            label: 'Show me',
            emoji: '👀',
            color: AppColors.sky,
            onTap: _startDemo,
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.pink,
              minimumSize: const Size(0, 46),
              padding: const EdgeInsets.symmetric(horizontal: 14),
            ),
            onPressed: hasDrawing ? _finishDrawing : null,
            child: const Text('I finished! ⭐'),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvas() => Container(
    margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.purple.withValues(alpha: 0.18)),
      boxShadow: [
        BoxShadow(
          color: AppColors.purple.withValues(alpha: 0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        _canvasSize = size;
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                onTapDown: (details) {
                  if (_activeSticker != null) {
                    _stampSticker(details.localPosition);
                  }
                },
                child: AnimatedBuilder(
                  animation: Listenable.merge([
                    _pulseController,
                    _demoController,
                  ]),
                  builder: (context, _) => CustomPaint(
                    size: Size.infinite,
                    painter: _DrawingPainter(
                      paths: _paths,
                      currentPath: _currentPath,
                      blueprint: _selectedBlueprint,
                      stickers: _stickers,
                      completedStrokes: _completedStrokes,
                      activeStroke: _activeStroke,
                      pulse: _pulseController.value,
                      demoT: _demoController.value,
                      demoStroke: _demoStroke,
                      demoRunning: _demoController.isAnimating,
                    ),
                  ),
                ),
              ),
            ),
            if (_celebrating)
              Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _celebrateController,
                    builder: (context, _) => _CelebrationOverlay(
                      progress: _celebrateController.value,
                      confetti: _confetti,
                      message: _celebrationMessage,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );

  Widget _buildControls() => Container(
    padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 10,
          offset: const Offset(0, -3),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _ToolButton(
              emoji: '🖍️',
              label: 'Crayon',
              selected: _activeSticker == null && _brushKind == BrushKind.crayon,
              onTap: () => _selectBrush(BrushKind.crayon),
            ),
            _ToolButton(
              emoji: '🌈',
              label: 'Rainbow',
              selected: _activeSticker == null && _brushKind == BrushKind.rainbow,
              onTap: () => _selectBrush(BrushKind.rainbow),
            ),
            _ToolButton(
              emoji: '✨',
              label: 'Glitter',
              selected: _activeSticker == null && _brushKind == BrushKind.glitter,
              onTap: () => _selectBrush(BrushKind.glitter),
            ),
            _ToolButton(
              emoji: '🧽',
              label: 'Eraser',
              selected: _activeSticker == null && _brushKind == BrushKind.eraser,
              onTap: () => _selectBrush(BrushKind.eraser),
            ),
            const Spacer(),
            _BrushSizeDial(
              width: _strokeWidth,
              color: _selectedColor,
              onChanged: (value) => setState(() => _strokeWidth = value),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.brush_rounded, color: AppColors.darkGray, size: 22),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 6,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 12,
                  ),
                ),
                child: Slider(
                  value: _strokeWidth,
                  min: 2,
                  max: 26,
                  divisions: 24,
                  activeColor: _selectedColor,
                  onChanged: (value) => setState(() => _strokeWidth = value),
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final color in _colorPalette)
                _ColorChoice(
                  color: color,
                  selected: _activeSticker == null && color == _selectedColor,
                  onTap: () => setState(() {
                    _selectedColor = color;
                    _activeSticker = null;
                    if (_brushKind == BrushKind.eraser) {
                      _brushKind = BrushKind.crayon;
                    }
                  }),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Stickers',
            style: TextStyle(
              color: AppColors.darkGray.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        SizedBox(
          height: 46,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              for (final emoji in _stickerChoices)
                _StickerChoice(
                  emoji: emoji,
                  selected: _activeSticker == emoji,
                  onTap: () => setState(
                    () => _activeSticker = _activeSticker == emoji ? null : emoji,
                  ),
                ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _BlueprintChip extends StatelessWidget {
  final String label;
  final String? emoji;
  final Color? color;
  final bool selected;
  final VoidCallback onTap;

  const _BlueprintChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.emoji,
    this.color,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4),
    child: Material(
      color: selected
          ? (color ?? AppColors.purple).withValues(alpha: 0.16)
          : Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: 78,
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: selected
                  ? (color ?? AppColors.purple)
                  : Colors.black12,
              width: selected ? 2.4 : 1,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji ?? '🖍️', style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.darkGray,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class _PillButton extends StatelessWidget {
  final String label;
  final String emoji;
  final Color color;
  final VoidCallback onTap;

  const _PillButton({
    required this.label,
    required this.emoji,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: color.withValues(alpha: 0.18),
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.darkGray,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ToolButton extends StatelessWidget {
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ToolButton({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Material(
        color: selected ? AppColors.purple.withValues(alpha: 0.16) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.purple : Colors.black12,
                width: selected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(emoji, style: const TextStyle(fontSize: 20)),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: selected ? AppColors.purple : AppColors.darkGray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class _BrushSizeDial extends StatelessWidget {
  final double width;
  final Color color;
  final ValueChanged<double> onChanged;

  const _BrushSizeDial({
    required this.width,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      GestureDetector(
        onTap: () => onChanged((width - 2).clamp(2, 26)),
        child: const Text('➖', style: TextStyle(fontSize: 16)),
      ),
      const SizedBox(width: 6),
      Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.black12),
        ),
        child: Container(
          width: width.clamp(6, 30),
          height: width.clamp(6, 30),
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
      const SizedBox(width: 6),
      GestureDetector(
        onTap: () => onChanged((width + 2).clamp(2, 26)),
        child: const Text('➕', style: TextStyle(fontSize: 16)),
      ),
    ],
  );
}

class _ColorChoice extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ColorChoice({
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      width: selected ? 42 : 36,
      height: selected ? 42 : 36,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? AppColors.darkGray : Colors.black12,
          width: selected ? 3 : 1,
        ),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.5),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    ),
  );
}

class _StickerChoice extends StatelessWidget {
  final String emoji;
  final bool selected;
  final VoidCallback onTap;

  const _StickerChoice({
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.yellow.withValues(alpha: 0.3)
            : AppColors.lightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? AppColors.orange : Colors.transparent,
          width: 2,
        ),
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
    ),
  );
}

class _DrawingPainter extends CustomPainter {
  final List<DrawingPath> paths;
  final DrawingPath? currentPath;
  final DrawingBlueprint? blueprint;
  final List<StickerStamp> stickers;
  final Set<int> completedStrokes;
  final int activeStroke;
  final double pulse;
  final double demoT;
  final int demoStroke;
  final bool demoRunning;

  _DrawingPainter({
    required this.paths,
    required this.currentPath,
    required this.blueprint,
    required this.stickers,
    required this.completedStrokes,
    required this.activeStroke,
    required this.pulse,
    required this.demoT,
    required this.demoStroke,
    required this.demoRunning,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintPaper(canvas, size);

    final bounds = blueprintBounds(size);
    if (blueprint != null) {
      _paintGuides(canvas, size, bounds, blueprint!);
    }

    for (final path in paths) {
      _drawPath(canvas, path);
    }
    if (currentPath != null) _drawPath(canvas, currentPath!);

    for (final sticker in stickers) {
      _paintSticker(canvas, size, sticker);
    }

    if (blueprint != null && demoRunning) {
      _paintDemoCrayon(canvas, size, bounds, blueprint!);
    }
  }

  void _paintPaper(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = AppColors.sky.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;
    const spacing = 26.0;
    for (var x = spacing; x < size.width; x += spacing) {
      for (var y = spacing; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.4, dotPaint);
      }
    }
  }

  void _paintGuides(Canvas canvas, Size size, Rect bounds, DrawingBlueprint bp) {
    for (var i = 0; i < bp.strokes.length; i++) {
      final stroke = bp.strokes[i];
      if (stroke.isEmpty) continue;
      final isDone = completedStrokes.contains(i);
      final isActive = i == activeStroke && !isDone;

      if (isDone) {
        _drawPolyline(
          canvas,
          stroke,
          bounds,
          Paint()
            ..color = bp.color
            ..strokeWidth = 8
            ..strokeCap = StrokeCap.round
            ..strokeJoin = StrokeJoin.round
            ..style = PaintingStyle.stroke,
        );
        continue;
      }

      final guidePaint = Paint()
        ..color = isActive
            ? bp.color.withValues(alpha: 0.35 + pulse * 0.45)
            : bp.color.withValues(alpha: 0.22)
        ..strokeWidth = isActive ? 5 : 4
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = _polylinePath(stroke, bounds);
      if (isActive) {
        _drawDashed(
          canvas,
          path,
          guidePaint,
          dash: 10 + pulse * 4,
          gap: 8,
        );
      } else {
        _drawDashed(canvas, path, guidePaint, dash: 5, gap: 9);
      }
    }

    // Numbered start badges for the strokes still to be traced.
    var number = 0;
    for (var i = 0; i < bp.strokes.length; i++) {
      if (completedStrokes.contains(i) || bp.strokes[i].isEmpty) continue;
      number++;
      final start = _mapTo(bounds, bp.strokes[i].first);
      final isActive = i == activeStroke;
      if (isActive) {
        final halo = Paint()
          ..color = bp.color.withValues(alpha: 0.25 + (1 - pulse) * 0.25);
        canvas.drawCircle(start, 16 + pulse * 6, halo);
      }
      _paintBadge(canvas, start, number.toString(), bp.color, isActive);
    }
  }

  void _paintBadge(
    Canvas canvas,
    Offset center,
    String text,
    Color color,
    bool highlighted,
  ) {
    final radius = highlighted ? 14.0 : 12.0;
    canvas.drawCircle(
      center,
      radius,
      Paint()..color = highlighted ? color : Colors.white,
    );
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = color
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: highlighted ? Colors.white : color,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  void _paintDemoCrayon(
    Canvas canvas,
    Size size,
    Rect bounds,
    DrawingBlueprint bp,
  ) {
    if (bp.strokes.isEmpty || demoStroke >= bp.strokes.length) return;
    final stroke = bp.strokes[demoStroke];
    if (stroke.isEmpty) return;
    final progress = Curves.easeInOut.transform(demoT.clamp(0.0, 1.0));
    final point = _mapTo(bounds, _pointAlong(stroke, progress));

    // Trailing highlight that grows behind the crayon.
    final trail = <Offset>[
      for (var i = 0; i <= 20; i++) _pointAlong(stroke, progress * i / 20),
    ];
    _drawPolyline(
      canvas,
      trail,
      bounds,
      Paint()
        ..color = bp.color.withValues(alpha: 0.7)
        ..strokeWidth = 9
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke,
    );

    final painter = TextPainter(
      text: const TextSpan(text: '✏️', style: TextStyle(fontSize: 30)),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, point - Offset(painter.width / 2, painter.height));
  }

  void _paintSticker(Canvas canvas, Size size, StickerStamp sticker) {
    final painter = TextPainter(
      text: TextSpan(
        text: sticker.emoji,
        style: TextStyle(fontSize: sticker.scale * size.shortestSide),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final center = Offset(
      sticker.position.dx * size.width,
      sticker.position.dy * size.height,
    );
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  Path _polylinePath(List<Offset> points, Rect bounds) {
    final first = _mapTo(bounds, points.first);
    final path = Path()..moveTo(first.dx, first.dy);
    for (final point in points.skip(1)) {
      final mapped = _mapTo(bounds, point);
      path.lineTo(mapped.dx, mapped.dy);
    }
    return path;
  }

  void _drawPolyline(
    Canvas canvas,
    List<Offset> points,
    Rect bounds,
    Paint paint,
  ) {
    if (points.isEmpty) return;
    canvas.drawPath(_polylinePath(points, bounds), paint);
  }

  void _drawDashed(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dash,
    required double gap,
  }) {
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + dash, metric.length);
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gap;
      }
    }
  }

  void _drawPath(Canvas canvas, DrawingPath path) {
    if (path.points.isEmpty) return;
    switch (path.kind) {
      case BrushKind.eraser:
        final eraser = Paint()
          ..color = Colors.white
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = path.strokeWidth * 1.8
          ..style = PaintingStyle.stroke;
        if (path.points.length == 1) {
          canvas.drawCircle(path.points.first, path.strokeWidth, eraser);
          return;
        }
        canvas.drawPath(_strokePath(path.points), eraser);
        return;
      case BrushKind.rainbow:
        _drawRainbow(canvas, path);
        return;
      case BrushKind.glitter:
        _drawGlitter(canvas, path);
        return;
      case BrushKind.crayon:
        final paint = Paint()
          ..color = path.color
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round
          ..strokeWidth = path.strokeWidth
          ..style = PaintingStyle.stroke;
        if (path.points.length == 1) {
          canvas.drawCircle(path.points.first, path.strokeWidth / 2, paint);
          return;
        }
        canvas.drawPath(_strokePath(path.points), paint);
        return;
    }
  }

  void _drawRainbow(Canvas canvas, DrawingPath path) {
    if (path.points.length == 1) {
      final paint = Paint()..color = path.color;
      canvas.drawCircle(path.points.first, path.strokeWidth / 2, paint);
      return;
    }
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = path.strokeWidth
      ..style = PaintingStyle.stroke;
    for (var i = 0; i < path.points.length - 1; i++) {
      final hue = (i * 12.0) % 360;
      paint.color = HSVColor.fromAHSV(1, hue, 0.85, 1).toColor();
      canvas.drawLine(path.points[i], path.points[i + 1], paint);
    }
  }

  void _drawGlitter(Canvas canvas, DrawingPath path) {
    final base = Paint()
      ..color = path.color
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = path.strokeWidth
      ..style = PaintingStyle.stroke;
    if (path.points.length == 1) {
      canvas.drawCircle(path.points.first, path.strokeWidth / 2, base);
    } else {
      canvas.drawPath(_strokePath(path.points), base);
    }

    final sparkle = Paint()..color = Colors.white;
    final sparkleColor = Paint()..color = path.color.withValues(alpha: 0.9);
    for (var i = 0; i < path.points.length; i += 4) {
      final point = path.points[i];
      final radius = 2.0 + (i % 3);
      canvas.drawCircle(point, radius + 1.5, sparkleColor);
      canvas.drawCircle(point, radius, sparkle);
    }
  }

  Path _strokePath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(covariant _DrawingPainter oldDelegate) => true;
}

class _Confetti {
  final double x;
  final double delay;
  final double speed;
  final double drift;
  final double size;
  final double spin;
  final Color color;

  const _Confetti({
    required this.x,
    required this.delay,
    required this.speed,
    required this.drift,
    required this.size,
    required this.spin,
    required this.color,
  });
}

class _CelebrationOverlay extends StatelessWidget {
  final double progress;
  final List<_Confetti> confetti;
  final String message;

  const _CelebrationOverlay({
    required this.progress,
    required this.confetti,
    required this.message,
  });

  @override
  Widget build(BuildContext context) => CustomPaint(
    size: Size.infinite,
    painter: _ConfettiPainter(progress: progress, confetti: confetti),
    child: Center(
      child: Opacity(
        opacity: (1 - ((progress - 0.7) / 0.3).clamp(0.0, 1.0)).clamp(0.0, 1.0),
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.6, end: 1.0).animate(
            CurvedAnimation(
              parent: AlwaysStoppedAnimation(progress.clamp(0.0, 0.35) / 0.35),
              curve: Curves.elasticOut,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: AppColors.purple.withValues(alpha: 0.3),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: AppColors.darkGray,
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class _ConfettiPainter extends CustomPainter {
  final double progress;
  final List<_Confetti> confetti;

  const _ConfettiPainter({required this.progress, required this.confetti});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final piece in confetti) {
      final t = ((progress - piece.delay) / (1 - piece.delay)).clamp(0.0, 1.0);
      final y = -0.1 + t * piece.speed * 1.35;
      if (y < -0.05 || y > 1.05) continue;
      final x = piece.x + piece.drift * math.sin(t * 6 + piece.spin);
      final center = Offset(x * size.width, y * size.height);
      paint.color = piece.color.withValues(
        alpha: (1 - (t - 0.7).clamp(0.0, 0.3) / 0.3).clamp(0.0, 1.0),
      );
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(piece.spin + t * 9);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: piece.size,
            height: piece.size * 0.6,
          ),
          const Radius.circular(2),
        ),
        paint,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
