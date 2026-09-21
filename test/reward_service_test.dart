import 'package:flutter_test/flutter_test.dart';
import 'package:preschool_learning_app/utils/reward_service.dart';

void main() {
  group('RewardService', () {
    test('builds stable task keys for alphabet and digits', () {
      expect(RewardService.taskKey('alphabet', 'A'), equals('alphabet_A'));
      expect(RewardService.taskKey('number', '7'), equals('number_7'));
    });

    test('does not re-award the same task when a duplicate is reported', () {
      final regular = RewardService.shouldAwardTask(
        completedKeys: {'alphabet_A', 'number_7'},
        taskType: 'alphabet',
        taskId: 'A',
      );
      final newTask = RewardService.shouldAwardTask(
        completedKeys: {'alphabet_A', 'number_7'},
        taskType: 'alphabet',
        taskId: 'B',
      );

      expect(regular, isFalse);
      expect(newTask, isTrue);
    });
  });
}
