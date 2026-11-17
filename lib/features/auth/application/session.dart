import 'package:petbridge/core/network/app_failure.dart';

/// The signed-in user as the app sees it (from `GET /me`).
class Me {
  const new({
    required this.id,
    required this.onboarded,
    this.nickname,
    this.mbti,
    this.petType,
    this.nativeLang,
    this.ageBand,
  });

  final String id;
  final bool onboarded;
  final String? nickname;
  final String? mbti;
  final String? petType;

  /// BCP-47 tag, e.g. `zh-Hant`.
  final String? nativeLang;

  /// `13_17` or `18_plus`.
  final String? ageBand;
}

/// Where the user is in the app's lifecycle. The router only reads this.
sealed class Session {
  const new();
}

/// Starting up: reading tokens and loading `/me`. [failure] is set when
/// that could not finish (e.g. no network) and the user may retry.
final class SessionUnknown extends Session {
  const new({this.failure});

  final AppFailure? failure;
}

final class SessionUnauthenticated extends Session {
  const new();
}

final class SessionNeedsOnboarding extends Session {
  const new(this.me);

  final Me me;
}

final class SessionReady extends Session {
  const new(this.me);

  final Me me;
}
