// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'PetBridge';

  @override
  String get err_UNKNOWN => '出了点问题，请重试。';

  @override
  String get err_NETWORK => '无法连接服务器，请检查网络后重试。';

  @override
  String get err_VALIDATION_FAILED => '部分信息无效，请检查后重试。';

  @override
  String get err_PROVIDER_NOT_CONFIGURED => '该登录方式暂不可用。';

  @override
  String get err_ACCOUNT_DISABLED => '该账号已被停用。';

  @override
  String get err_RATE_LIMITED => '尝试次数过多，请稍后再试。';
}

/// The translations for Chinese, using the Han script (`zh_Hans`).
class AppLocalizationsZhHans extends AppLocalizationsZh {
  AppLocalizationsZhHans() : super('zh_Hans');

  @override
  String get appTitle => 'PetBridge';

  @override
  String get err_UNKNOWN => '出了点问题，请重试。';

  @override
  String get err_NETWORK => '无法连接服务器，请检查网络后重试。';

  @override
  String get err_VALIDATION_FAILED => '部分信息无效，请检查后重试。';

  @override
  String get err_PROVIDER_NOT_CONFIGURED => '该登录方式暂不可用。';

  @override
  String get err_ACCOUNT_DISABLED => '该账号已被停用。';

  @override
  String get err_RATE_LIMITED => '尝试次数过多，请稍后再试。';
}

/// The translations for Chinese, using the Han script (`zh_Hant`).
class AppLocalizationsZhHant extends AppLocalizationsZh {
  AppLocalizationsZhHant() : super('zh_Hant');

  @override
  String get appTitle => 'PetBridge';

  @override
  String get err_UNKNOWN => '發生錯誤，請重試。';

  @override
  String get err_NETWORK => '無法連線到伺服器，請檢查網路後重試。';

  @override
  String get err_VALIDATION_FAILED => '部分資訊無效，請檢查後重試。';

  @override
  String get err_PROVIDER_NOT_CONFIGURED => '此登入方式暫時無法使用。';

  @override
  String get err_ACCOUNT_DISABLED => '此帳號已被停用。';

  @override
  String get err_RATE_LIMITED => '嘗試次數過多，請稍後再試。';
}
