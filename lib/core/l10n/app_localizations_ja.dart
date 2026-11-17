// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'PetBridge';

  @override
  String get err_UNKNOWN => '問題が発生しました。もう一度お試しください。';

  @override
  String get err_NETWORK => 'サーバーに接続できません。通信環境を確認して、もう一度お試しください。';

  @override
  String get err_VALIDATION_FAILED => '入力内容に誤りがあります。確認して、もう一度お試しください。';

  @override
  String get err_PROVIDER_NOT_CONFIGURED => 'このログイン方法は現在ご利用いただけません。';

  @override
  String get err_ACCOUNT_DISABLED => 'このアカウントは無効になっています。';

  @override
  String get err_RATE_LIMITED => '試行回数が多すぎます。しばらくしてから、もう一度お試しください。';
}
