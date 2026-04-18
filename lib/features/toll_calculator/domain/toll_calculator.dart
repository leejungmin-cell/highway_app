import 'toll_calculation_result.dart';

class TollCalculator {
  const TollCalculator();

  static const int _nightStartMinutes = 22 * 60;
  static const int _nightEndMinutes = 30 * 60;
  static const double _fiftyPercentRate = 0.7;
  static const double _thirtyPercentRate = 0.2;

  TollCalculationResult calculate(DateTime entryTime) {
    final entrySystemMinutes = _toSystemMinutes(entryTime);

    if (entrySystemMinutes < _nightStartMinutes) {
      return TollCalculationResult(
        fiftyPercent: DiscountWindow(
          minimumExitTime: _calculateMinimumExitTime(
            entryTime: entryTime,
            entrySystemMinutes: entrySystemMinutes,
            rate: _fiftyPercentRate,
          ),
          maximumExitTime: _toExitDateTime(
            entryTime: entryTime,
            entrySystemMinutes: entrySystemMinutes,
            targetSystemMinutes: _inverseMaximum(
              entrySystemMinutes,
              _fiftyPercentRate,
            ),
          ),
        ),
        thirtyPercent: DiscountWindow(
          minimumExitTime: _calculateMinimumThirtyPercentExitTime(
            entryTime,
            entrySystemMinutes,
          ),
          maximumExitTime: _toExitDateTime(
            entryTime: entryTime,
            entrySystemMinutes: entrySystemMinutes,
            targetSystemMinutes: _inverseMaximum(
              entrySystemMinutes,
              _thirtyPercentRate,
            ),
          ),
        ),
      );
    }

    return TollCalculationResult(
      fiftyPercent: DiscountWindow(
        minimumExitTime: entryTime.add(const Duration(minutes: 1)),
        maximumExitTime: _toExitDateTime(
          entryTime: entryTime,
          entrySystemMinutes: entrySystemMinutes,
          targetSystemMinutes: _inverseMaximum(
            entrySystemMinutes,
            _fiftyPercentRate,
          ),
        ),
      ),
      thirtyPercent: DiscountWindow(
        minimumExitTime: entryTime.add(const Duration(minutes: 1)),
        maximumExitTime: _toExitDateTime(
          entryTime: entryTime,
          entrySystemMinutes: entrySystemMinutes,
          targetSystemMinutes: _inverseMaximum(
            entrySystemMinutes,
            _thirtyPercentRate,
          ),
        ),
      ),
    );
  }

  DateTime? _calculateMinimumExitTime({
    required DateTime entryTime,
    required int entrySystemMinutes,
    required double rate,
  }) {
    final minimumTargetSystemMinutes =
        (_nightStartMinutes - rate * entrySystemMinutes) / (1 - rate);

    if (minimumTargetSystemMinutes > _nightEndMinutes) {
      return null;
    }

    return _toExitDateTime(
      entryTime: entryTime,
      entrySystemMinutes: entrySystemMinutes,
      targetSystemMinutes: minimumTargetSystemMinutes,
    );
  }

  DateTime _calculateMinimumThirtyPercentExitTime(
    DateTime entryTime,
    int entrySystemMinutes,
  ) {
    final minimumTargetSystemMinutes =
        (_nightStartMinutes - _thirtyPercentRate * entrySystemMinutes) /
        (1 - _thirtyPercentRate);

    if (minimumTargetSystemMinutes <= _nightEndMinutes) {
      return _toExitDateTime(
        entryTime: entryTime,
        entrySystemMinutes: entrySystemMinutes,
        targetSystemMinutes: minimumTargetSystemMinutes,
      );
    }

    return _toExitDateTime(
      entryTime: entryTime,
      entrySystemMinutes: entrySystemMinutes,
      targetSystemMinutes: (_nightStartMinutes + 10).toDouble(),
    );
  }

  int _toSystemMinutes(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;

    if (hour < 6) {
      return (hour + 24) * 60 + minute;
    }

    return hour * 60 + minute;
  }

  DateTime _toExitDateTime({
    required DateTime entryTime,
    required int entrySystemMinutes,
    required double targetSystemMinutes,
  }) {
    return entryTime.add(
      Duration(minutes: (targetSystemMinutes - entrySystemMinutes).round()),
    );
  }

  double _inverseMaximum(int entrySystemMinutes, double rate) {
    final numerator = entrySystemMinutes < _nightStartMinutes
        ? (_nightEndMinutes - _nightStartMinutes)
        : (_nightEndMinutes - entrySystemMinutes);

    return numerator / rate + entrySystemMinutes;
  }
}
