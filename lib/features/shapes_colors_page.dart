import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class _ColorItem {
  final String name;
  final Color color;
  final List<String> objects;
  final String fact;

  const _ColorItem({
    required this.name,
    required this.color,
    required this.objects,
    required this.fact,
  });
}

class _ShapeItem {
  final String name;
  final IconData icon;
  final List<String> objects;
  final String fact;

  const _ShapeItem({
    required this.name,
    required this.icon,
    required this.objects,
    required this.fact,
  });
}

const List<_ColorItem> _colors = [
  _ColorItem(
    name: 'Red',
    color: Color(0xFFE5484D),
    objects: ['❤️', '🍎', '🌹', '🚗'],
    fact: 'Red is the color of apples, roses, and fire trucks!',
  ),
  _ColorItem(
    name: 'Blue',
    color: Color(0xFF3B82F6),
    objects: ['💙', '🚙', '🌊', '👖'],
    fact: 'Blue is the color of the sky, ocean, and blueberries!',
  ),
  _ColorItem(
    name: 'Green',
    color: Color(0xFF10B981),
    objects: ['💚', '🥒', '🌲', '🐸'],
    fact: 'Green is the color of grass, trees, and frogs!',
  ),
  _ColorItem(
    name: 'Yellow',
    color: Color(0xFFEAB308),
    objects: ['💛', '🌻', '🍋', '⭐'],
    fact: 'Yellow is the color of the sun, bananas, and sunflowers!',
  ),
  _ColorItem(
    name: 'Orange',
    color: Color(0xFFF97316),
    objects: ['🧡', '🍊', '🏀', '🥕'],
    fact: 'Orange is the color of oranges, pumpkins, and carrots!',
  ),
  _ColorItem(
    name: 'Purple',
    color: AppColors.purple,
    objects: ['💜', '🍇', '🌂', '🎀'],
    fact: 'Purple is the color of grapes, plums, and lavender flowers!',
  ),
  _ColorItem(
    name: 'Pink',
    color: AppColors.pink,
    objects: ['💗', '🌸', '🎀', '🍩'],
    fact: 'Pink is the color of flowers, flamingos, and cotton candy!',
  ),
];

const List<_ShapeItem> _shapes = [
  _ShapeItem(
    name: 'Circle',
    icon: Icons.circle,
    objects: ['⭕', '☀️', '🍪', '🏀'],
    fact: 'A circle has no corners and looks like a ball or the sun!',
  ),
  _ShapeItem(
    name: 'Square',
    icon: Icons.square,
    objects: ['⬜', '🎁', '🧊', '📱'],
    fact: 'A square has 4 equal sides and 4 corners, like a box or phone!',
  ),
  _ShapeItem(
    name: 'Triangle',
    icon: Icons.change_history,
    objects: ['🔺', '⛺', '🍕', '📐'],
    fact: 'A triangle has 3 sides and 3 corners, like a tent or pizza slice!',
  ),
  _ShapeItem(
    name: 'Rectangle',
    icon: Icons.rectangle,
    objects: ['▬', '📖', '📺', '🚪'],
    fact: 'A rectangle has 2 long sides and 2 short sides, like a book or door!',
  ),
  _ShapeItem(
    name: 'Star',
    icon: Icons.star,
    objects: ['⭐', '🌟', '✨', '💫'],
    fact: 'A star has 5 points and shines bright in the night sky!',
  ),
  _ShapeItem(
    name: 'Heart',
    icon: Icons.favorite,
    objects: ['❤️', '💖', '💝', '💗'],
    fact: 'A heart shape shows love and looks like two bumps on top!',
  ),
];

/// Shapes and colors learning page
class ShapesColorsPage extends StatefulWidget {
  const ShapesColorsPage({super.key});

  @override
  State<ShapesColorsPage> createState() => _ShapesColorsPageState();
}

class _ShapesColorsPageState extends State<ShapesColorsPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showColorInfo(BuildContext context, _ColorItem colorItem) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colorItem.color,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                colorItem.name,
                style: const TextStyle(
                  color: AppColors.darkGray,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: colorItem.objects
                  .map((obj) => Text(
                        obj,
                        style: const TextStyle(fontSize: 40),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text(
              colorItem.fact,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.darkGray,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Close',
              style: TextStyle(color: colorItem.color, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  void _showShapeInfo(BuildContext context, _ShapeItem shapeItem) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Icon(shapeItem.icon, size: 40, color: AppColors.teal),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                shapeItem.name,
                style: const TextStyle(
                  color: AppColors.darkGray,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: shapeItem.objects
                  .map((obj) => Text(
                        obj,
                        style: const TextStyle(fontSize: 40),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 16),
            Text(
              shapeItem.fact,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.darkGray,
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Close',
              style: TextStyle(color: AppColors.teal, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          tabs: const [
            Tab(icon: Icon(Icons.palette), text: 'Colors'),
            Tab(icon: Icon(Icons.category), text: 'Shapes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Colors Tab
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _colors.length,
              itemBuilder: (context, index) {
                final colorItem = _colors[index];
                return GestureDetector(
                  onTap: () => _showColorInfo(context, colorItem),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: colorItem.color.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: colorItem.color,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          colorItem.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: colorItem.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          // Shapes Tab
          Padding(
            padding: const EdgeInsets.all(16),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: _shapes.length,
              itemBuilder: (context, index) {
                final shapeItem = _shapes[index];
                return GestureDetector(
                  onTap: () => _showShapeInfo(context, shapeItem),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          shapeItem.icon,
                          size: 64,
                          color: AppColors.teal,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          shapeItem.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
