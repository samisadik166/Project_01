import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preschool_learning_app/features/drawing_page.dart';

void main() {
  group('drawing blueprints', () {
    test('each blueprint has a unique id, a name and at least one stroke', () {
      expect(BlueprintLibrary.all, isNotEmpty);

      final ids = BlueprintLibrary.all.map((blueprint) => blueprint.id);
      expect(ids.toSet().length, BlueprintLibrary.all.length);

      for (final blueprint in BlueprintLibrary.all) {
        expect(blueprint.name, isNotEmpty, reason: blueprint.id);
        expect(blueprint.strokes, isNotEmpty, reason: blueprint.id);
      }
    });

    test('outlines stay inside the normalised 0..1 canvas', () {
      for (final blueprint in BlueprintLibrary.all) {
        for (final stroke in blueprint.strokes) {
          expect(stroke, isNotEmpty, reason: blueprint.id);
          for (final point in stroke) {
            expect(
              point.dx,
              inInclusiveRange(-0.02, 1.02),
              reason: '${blueprint.id} x out of range: ${point.dx}',
            );
            expect(
              point.dy,
              inInclusiveRange(-0.02, 1.02),
              reason: '${blueprint.id} y out of range: ${point.dy}',
            );
          }
        }
      }
    });

    test('outlines fill a reasonable portion of the canvas', () {
      for (final blueprint in BlueprintLibrary.all) {
        final points = blueprint.strokes.expand((stroke) => stroke);
        final xs = points.map((point) => point.dx);
        final ys = points.map((point) => point.dy);

        final width = xs.reduce(math.max) - xs.reduce(math.min);
        final height = ys.reduce(math.max) - ys.reduce(math.min);

        expect(width, greaterThan(0.3), reason: '${blueprint.id} too narrow');
        expect(height, greaterThan(0.3), reason: '${blueprint.id} too short');
      }
    });
  });

  testWidgets('picker offers free draw plus every blueprint', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: DrawingPage(childId: 'child-1')),
    );
    await tester.pump();

    expect(find.text('Free Draw'), findsOneWidget);
    expect(find.text('Star'), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);
  });

  testWidgets('selecting a blueprint reveals the finish button', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: DrawingPage(childId: 'child-1')),
    );
    await tester.pump();

    expect(find.text('I finished! ⭐'), findsNothing);

    await tester.tap(find.text('Star'));
    await tester.pump();

    expect(find.text('I finished! ⭐'), findsOneWidget);
    expect(find.text('Drawing ⭐ Star'), findsOneWidget);

    // Untouched canvas cannot be "finished" yet.
    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
  });

  test('library includes the extra kid favourite pictures', () {
    final ids = BlueprintLibrary.all.map((blueprint) => blueprint.id).toSet();
    for (final id in [
      'fish',
      'flower',
      'butterfly',
      'tree',
      'rainbow',
      'cat',
      'ice_cream',
      'boat',
      'balloon',
    ]) {
      expect(ids, contains(id));
    }
  });

  testWidgets('offers playful tools, stickers and a demo button', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: DrawingPage(childId: 'child-1')),
    );
    await tester.pump();

    expect(find.text('Rainbow'), findsWidgets);
    expect(find.text('Glitter'), findsOneWidget);
    expect(find.text('Stickers'), findsOneWidget);

    // The "show me" demo only appears once a picture is chosen.
    expect(find.text('Show me'), findsNothing);
    await tester.tap(find.text('Star'));
    await tester.pump();
    expect(find.text('Show me'), findsOneWidget);
  });

  testWidgets('drawing then finishing triggers the celebration', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: DrawingPage(childId: 'child-1')),
    );
    await tester.pump();

    await tester.tap(find.text('Star'));
    await tester.pump();

    // Scribble somewhere in the middle of the paper.
    final gesture = await tester.startGesture(const Offset(200, 420));
    await gesture.moveBy(const Offset(50, 30));
    await gesture.moveBy(const Offset(-30, 40));
    await gesture.up();
    await tester.pump();

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNotNull);

    await tester.tap(find.text('I finished! ⭐'));
    await tester.pump();
    expect(find.text('Lovely drawing! ⭐'), findsOneWidget);

    // Let the celebration animation finish without leaking timers.
    await tester.pump(const Duration(milliseconds: 2500));
  });
}
