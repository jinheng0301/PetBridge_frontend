// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'PetBridge';

  @override
  String get err_UNKNOWN => 'Something went wrong. Please try again.';

  @override
  String get err_NETWORK =>
      'Can\'t reach the server. Check your connection and try again.';

  @override
  String get err_VALIDATION_FAILED =>
      'Some of the information isn\'t valid. Please check and try again.';

  @override
  String get err_PROVIDER_NOT_CONFIGURED =>
      'This sign-in method isn\'t available right now.';

  @override
  String get err_ACCOUNT_DISABLED => 'This account has been disabled.';

  @override
  String get err_RATE_LIMITED =>
      'Too many attempts. Please wait a moment and try again.';
}
