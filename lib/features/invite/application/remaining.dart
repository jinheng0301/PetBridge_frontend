/// How long an unused code stays valid, rounded for display.
sealed class Remaining {
  const new();
}

final class RemainingDays extends Remaining {
  const new(this.days);

  final int days;
}

final class RemainingHours extends Remaining {
  const new(this.hours);

  final int hours;
}

/// Under an hour, or already past.
final class RemainingSoon extends Remaining {
  const new();
}

Remaining remainingUntil(DateTime expiresAt, DateTime now) {
  final left = expiresAt.difference(now);
  if (left.inHours >= 24) return RemainingDays(left.inDays);
  if (left.inHours >= 1) return RemainingHours(left.inHours);
  return const RemainingSoon();
}
