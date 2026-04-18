class TollCalculationResult {
  const TollCalculationResult({
    required this.fiftyPercent,
    required this.thirtyPercent,
  });

  final DiscountWindow fiftyPercent;
  final DiscountWindow thirtyPercent;
}

class DiscountWindow {
  const DiscountWindow({
    required this.minimumExitTime,
    required this.maximumExitTime,
  });

  final DateTime? minimumExitTime;
  final DateTime? maximumExitTime;

  bool get isAchievable {
    return minimumExitTime != null && maximumExitTime != null;
  }
}
