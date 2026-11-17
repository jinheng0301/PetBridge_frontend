import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/core/network/dio_client.dart';
import 'package:petbridge/gen/pet_bridge_api.dart';

abstract interface class OnboardingRepository {
  /// `POST /me/onboarding`. Idempotent on the server, so a failed call can
  /// be retried as is. Throws [AppFailure].
  Future<void> complete({
    required String nativeLang,
    required String mbti,
    required String nickname,
    required String ageBand,
    required String tz,
  });
}

class ApiOnboardingRepository implements OnboardingRepository {
  new(this._api);

  final PetBridgeApi _api;

  @override
  Future<void> complete({
    required String nativeLang,
    required String mbti,
    required String nickname,
    required String ageBand,
    required String tz,
  }) async {
    final body = OnboardingRequest(
      nativeLang: OnboardingRequestNativeLang.values.firstWhere(
        (v) => v.value == nativeLang,
      ),
      mbti: mbti,
      nickname: nickname,
      ageBand: OnboardingRequestAgeBand.values.firstWhere(
        (v) => v.value == ageBand,
      ),
      tz: tz,
    );
    try {
      await _api.me.completeOnboarding(body: body);
    } on Object catch (e) {
      throw AppFailure.from(e);
    }
  }
}

final onboardingRepositoryProvider = Provider<OnboardingRepository>(
  (ref) => ApiOnboardingRepository(PetBridgeApi(ref.watch(dioProvider))),
);

/// The device's IANA time zone (e.g. `Asia/Tokyo`). Anything that does not
/// look like one, or any plugin failure, becomes `UTC`.
Future<String> deviceTimeZone() async {
  try {
    final id = (await FlutterTimezone.getLocalTimezone()).identifier;
    return id.contains('/') || id == 'UTC' ? id : 'UTC';
  } on Object {
    return 'UTC';
  }
}

final deviceTimeZoneProvider = Provider<Future<String> Function()>(
  (ref) => deviceTimeZone,
);
