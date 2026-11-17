// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'PetBridge';

  @override
  String get err_UNKNOWN => '문제가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get err_NETWORK => '서버에 연결할 수 없습니다. 네트워크를 확인한 후 다시 시도해 주세요.';

  @override
  String get err_VALIDATION_FAILED => '일부 정보가 올바르지 않습니다. 확인 후 다시 시도해 주세요.';

  @override
  String get err_PROVIDER_NOT_CONFIGURED => '이 로그인 방식은 현재 사용할 수 없습니다.';

  @override
  String get err_ACCOUNT_DISABLED => '비활성화된 계정입니다.';

  @override
  String get err_RATE_LIMITED => '시도 횟수가 너무 많습니다. 잠시 후 다시 시도해 주세요.';
}
