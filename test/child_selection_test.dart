import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preschool_learning_app/model/child.dart';
import 'package:preschool_learning_app/tabs/profile_tab.dart';

void main() {
  testWidgets('parent can select a child profile', (tester) async {
    final selectedChildIds = <String>[];
    final createdAt = DateTime(2026, 1, 1);

    await tester.pumpWidget(
      MaterialApp(
        home: ProfileTab(
          children: [
            ChildModel(
              childId: 'child-1',
              name: 'Ava',
              age: 4,
              avatarId: 'bear_1',
              createdAt: createdAt,
            ),
            ChildModel(
              childId: 'child-2',
              name: 'Noah',
              age: 5,
              avatarId: 'star_1',
              createdAt: createdAt,
            ),
          ],
          selectedChildId: 'child-1',
          onChildSelected: (childId) async {
            selectedChildIds.add(childId);
          },
          onChildrenChanged: ([childId]) async {},
          childrenLoading: false,
          childrenError: null,
        ),
      ),
    );

    expect(find.text('Ava'), findsOneWidget);
    expect(find.text('Noah'), findsOneWidget);
    expect(find.byTooltip('Selected child'), findsOneWidget);

    await tester.tap(find.byTooltip('Select child'));
    await tester.pump();

    expect(selectedChildIds, ['child-2']);
  });
}
