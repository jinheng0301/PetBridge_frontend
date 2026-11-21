import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petbridge/core/clock.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/features/invite/application/codes.dart';
import 'package:petbridge/features/invite/application/invite_code.dart';
import 'package:petbridge/features/invite/data/invite_repository.dart';
import 'package:petbridge/features/room/application/rooms_provider.dart';

/// What the join page shows: the typed code, the request in flight, the
/// last error, a cooldown and the result of a successful join.
class JoinState {
  const new({
    this.input = '',
    this.submitting = false,
    this.failure,
    this.blockedUntil,
    this.result,
  });

  /// Normalized, at most 8 characters, no hyphen.
  final String input;
  final bool submitting;
  final AppFailure? failure;

  /// Set from the server's `retry_after_seconds`; kept when the page closes.
  final DateTime? blockedUntil;
  final JoinOutcome? result;

  bool isBlocked(DateTime now) {
    final until = blockedUntil;
    return until != null && now.isBefore(until);
  }

  Duration remaining(DateTime now) =>
      isBlocked(now) ? blockedUntil!.difference(now) : Duration.zero;

  bool canSubmit(DateTime now) =>
      isValidCode(input) && !submitting && !isBlocked(now);
}

/// Drives the join page. Kept for the app's lifetime so a cooldown survives
/// closing the page; reset when the signed-in user changes.
class JoinController extends Notifier<JoinState> {
  @override
  JoinState build() {
    ref.watch(readyUserIdProvider);
    return const JoinState();
  }

  DateTime get _now => ref.read(clockProvider)();

  void _set({
    String? input,
    bool? submitting,
    AppFailure? failure,
    JoinOutcome? result,
    DateTime? blockedUntil,
  }) => state = JoinState(
    input: input ?? state.input,
    submitting: submitting ?? state.submitting,
    failure: failure,
    result: result,
    blockedUntil: blockedUntil ?? state.blockedUntil,
  );

  /// Typing clears the previous error.
  void setInput(String raw) => _set(input: normalizeCode(raw));

  void paste(String text) => _set(input: normalizePaste(text));

  /// From `/join?code=` or a share link; only an exactly valid code is used.
  void prefill(String? param) {
    final code = validCodeParam(param);
    if (code != null) _set(input: code);
  }

  Future<void> submit() async {
    if (!state.canSubmit(_now)) return;
    final user = ref.read(readyUserIdProvider);
    bool stale() => !ref.mounted || ref.read(readyUserIdProvider) != user;
    _set(submitting: true);
    try {
      final outcome = await ref
          .read(inviteRepositoryProvider)
          .join(state.input);
      if (stale()) return;
      ref.read(selectedRoomIdProvider.notifier).select(outcome.roomId);
      // Reload first so the room tab is current when the user goes there.
      await _refreshAfterJoin();
      if (stale()) return;
      _set(submitting: false, result: outcome);
    } on AppFailure catch (f) {
      if (stale()) return;
      _set(submitting: false, failure: f, blockedUntil: _blockedUntil(f));
    }
  }

  /// The join succeeded; a failed reload catches up on the next refresh.
  Future<void> _refreshAfterJoin() async {
    try {
      await ref.read(roomsProvider.notifier).refresh();
    } on AppFailure {
      // Keep what is shown.
    }
  }

  DateTime? _blockedUntil(AppFailure f) {
    if (f.code != 'CODE_COOLDOWN' && f.code != 'RATE_LIMITED') return null;
    final seconds = f.details['retry_after_seconds'];
    if (seconds is! int || seconds <= 0) return null;
    return _now.add(Duration(seconds: seconds));
  }

  /// Leaving the page forgets everything but the cooldown. A no-op once the
  /// controller was reset (the page may call it after a user switch).
  void leave() {
    if (!ref.mounted) return;
    state = JoinState(blockedUntil: state.blockedUntil);
  }

  /// Shows [roomId] in the room tab (the success page's "Go to room").
  void selectRoom(String roomId) =>
      ref.read(selectedRoomIdProvider.notifier).select(roomId);
}

final joinControllerProvider = NotifierProvider<JoinController, JoinState>(
  JoinController.new,
);
