import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/core/realtime/backoff.dart';

void main() {
  test('attempt 0..6 gives 1,2,4,8,16,30,30 s without jitter', () {
    expect(
      [for (var i = 0; i <= 6; i++) backoffDelay(i, 0).inSeconds],
      [1, 2, 4, 8, 16, 30, 30],
    );
    expect(backoffDelay(50, 0), const Duration(seconds: 30));
  });

  test('jitter 0.3 stretches 8s to 10.4s', () {
    expect(backoffDelay(3, 0.3), const Duration(milliseconds: 10400));
  });
}
