// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:preschool_learning_app/features/alphabet_page.dart';
import 'package:preschool_learning_app/features/number_tracing_widget.dart';
import 'package:preschool_learning_app/features/numbers_page.dart';
import 'package:preschool_learning_app/login_page.dart';
import 'package:preschool_learning_app/main.dart';

void main() {
  testWidgets('renders the splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(const PreschoolApp());

    expect(find.text('Little Learners'), findsOneWidget);
    expect(find.text('Learning is fun!'), findsOneWidget);
  });

  testWidgets('login page shows a Google sign-in option', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    expect(find.text('Continue with Google'), findsOneWidget);
  });

  testWidgets('number tracing remains visible in landscape mode', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: NumbersPage(childId: 'child-1')),
    );

    await tester.pumpAndSettle();

    final tracingRect = tester.getRect(find.byType(NumberTracingWidget));
    final canvasFinder = find.byKey(const ValueKey('number-tracing-canvas-0'));
    final canvasRect = tester.getRect(canvasFinder);
    final viewportHeight = tester.binding.renderView.size.height;

    expect(find.byType(NumberTracingWidget), findsOneWidget);
    expect(canvasFinder, findsOneWidget);
    expect(tracingRect.bottom <= viewportHeight, isTrue);
    expect(canvasRect.bottom <= viewportHeight, isTrue);
    expect(canvasRect.width, greaterThan(200));
    expect(find.text('1 / 10'), findsOneWidget);
  });

  testWidgets('alphabet tracing canvas remains visible in landscape mode', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(900, 400));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const MaterialApp(home: AlphabetPage(childId: 'child-1')),
    );
    await tester.pump();

    final canvas = find.byKey(const ValueKey('alphabet-tracing-canvas-A'));
    final canvasRect = tester.getRect(canvas);
    final viewportHeight = tester.binding.renderView.size.height;

    expect(canvas, findsOneWidget);
    expect(canvasRect.bottom <= viewportHeight, isTrue);
    expect(canvasRect.width, greaterThan(200));
    expect(tester.takeException(), isNull);
  });
}
