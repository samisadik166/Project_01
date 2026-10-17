import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:preschool_learning_app/data/progress_repository.dart';
import 'package:preschool_learning_app/features/certificates_page.dart';
import 'package:preschool_learning_app/model/certificate_milestone.dart';
import 'package:preschool_learning_app/model/progress_report.dart';

void main() {
  test('certificate unlocks only when its milestone is reached', () {
    final milestone = certificateMilestones.first;
    final lockedReport = _report(
      totalStars: 49,
      tasks: {'alphabet_A', 'alphabet_B'},
    );
    final unlockedReport = _report(
      totalStars: 50,
      tasks: {
        for (var code = 65; code <= 90; code++)
          'alphabet_${String.fromCharCode(code)}',
      },
    );

    expect(milestone.isUnlocked(lockedReport), isFalse);
    expect(milestone.isUnlocked(unlockedReport), isTrue);
    expect(
      certificateMilestones.last.isUnlocked(
        _report(totalStars: 49, tasks: const {}),
      ),
      isFalse,
    );
    expect(
      certificateMilestones.last.isUnlocked(
        _report(totalStars: 50, tasks: const {}),
      ),
      isTrue,
    );
  });

  testWidgets('certificate card changes from locked to preview when earned', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(393, 852));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final repository = _FakeProgressRepository(49);
    await tester.pumpWidget(
      MaterialApp(
        home: CertificatesPage(childId: 'child-1', repository: repository),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Earn 50 stars'), findsOneWidget);

    repository.stars = 50;
    await tester.pumpWidget(
      MaterialApp(
        home: CertificatesPage(
          key: const ValueKey('unlocked'),
          childId: 'child-1',
          repository: repository,
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Earned 50 learning stars'), findsOneWidget);

    await tester.tap(find.text('Shining Star'));
    await tester.pumpAndSettle();
    expect(find.text('Certificate preview'), findsOneWidget);
    expect(find.text('Certificate of Achievement'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

ProgressReport _report({required int totalStars, required Set<String> tasks}) {
  return ProgressReport(
    childId: 'child-1',
    childName: 'Ari',
    age: 5,
    avatarId: 'bear_1',
    totalStars: totalStars,
    badgesEarned: 0,
    activitiesCompleted: tasks.length,
    learningStreak: 0,
    subjects: const [],
    weeklyActivity: const [0, 0, 0, 0, 0, 0, 0],
    activities: const [],
    completedTasks: tasks,
  );
}

class _FakeProgressRepository implements ProgressRepository {
  _FakeProgressRepository(this.stars);

  int stars;

  @override
  Future<String?> loadActiveChildId() async => 'child-1';

  @override
  Future<ProgressReport> loadReport({
    required String childId,
    required ProgressDateRange dateRange,
  }) async => _report(totalStars: stars, tasks: const {});
}
