import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/features/invite/application/remaining.dart';

void main() {
  final now = DateTime.utc(2026, 11, 21, 12);

  test('a day or more counts whole days', () {
    final r = remainingUntil(now.add(const Duration(days: 6, hours: 3)), now);
    expect(r, isA<RemainingDays>().having((d) => d.days, 'days', 6));
  });

  test('under a day counts whole hours', () {
    final r = remainingUntil(
      now.add(const Duration(hours: 23, minutes: 59)),
      now,
    );
    expect(r, isA<RemainingHours>().having((h) => h.hours, 'hours', 23));
  });

  test('under an hour is soon', () {
    expect(
      remainingUntil(now.add(const Duration(minutes: 59)), now),
      isA<RemainingSoon>(),
    );
  });

  test('already expired is soon', () {
    expect(
      remainingUntil(now.subtract(const Duration(minutes: 1)), now),
      isA<RemainingSoon>(),
    );
  });
}
