const _stepsSeconds = [1, 2, 4, 8, 16, 30];

/// Wait before reconnect attempt [attempt] (0-based): 1, 2, 4, 8, 16, then
/// 30 seconds, stretched by `1 + jitter` (`jitter` in `[0, 0.3]`).
Duration backoffDelay(int attempt, double jitter) {
  final seconds = _stepsSeconds[attempt.clamp(0, _stepsSeconds.length - 1)];
  return Duration(
    microseconds: (seconds * Duration.microsecondsPerSecond * (1 + jitter))
        .round(),
  );
}
