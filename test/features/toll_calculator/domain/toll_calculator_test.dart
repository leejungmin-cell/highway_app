import 'package:flutter_test/flutter_test.dart';
import 'package:highway_app/features/toll_calculator/domain/toll_calculator.dart';

void main() {
  const calculator = TollCalculator();

  group('TollCalculator', () {
    test('returns expected windows for entry before night period', () {
      final result = calculator.calculate(DateTime(2026, 1, 1, 21, 0));

      expect(result.fiftyPercent.minimumExitTime, DateTime(2026, 1, 2, 0, 20));
      expect(
        result.thirtyPercent.minimumExitTime,
        DateTime(2026, 1, 1, 22, 15),
      );
      expect(
        result.fiftyPercent.maximumExitTime!.isAfter(
          result.fiftyPercent.minimumExitTime!,
        ),
        isTrue,
      );
      expect(
        result.thirtyPercent.maximumExitTime!.isAfter(
          result.thirtyPercent.minimumExitTime!,
        ),
        isTrue,
      );
    });

    test('returns immediate minimum exits for entry during night period', () {
      final result = calculator.calculate(DateTime(2026, 1, 1, 23, 30));

      expect(result.fiftyPercent.minimumExitTime, DateTime(2026, 1, 1, 23, 31));
      expect(
        result.thirtyPercent.minimumExitTime,
        DateTime(2026, 1, 1, 23, 31),
      );
      expect(
        result.fiftyPercent.maximumExitTime!.isAfter(
          result.fiftyPercent.minimumExitTime!,
        ),
        isTrue,
      );
      expect(
        result.thirtyPercent.maximumExitTime!.isAfter(
          result.thirtyPercent.minimumExitTime!,
        ),
        isTrue,
      );
    });
  });
}
