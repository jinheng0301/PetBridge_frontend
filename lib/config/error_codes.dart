import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/core/network/app_failure.dart';

/// The ARB key for a server error code.
String errorL10nKey(String code) => 'err_$code';

/// The user-facing text for [f]. Unknown codes fall back to `err_UNKNOWN`;
/// the server's `message` is never shown.
String localizedError(AppLocalizations l, AppFailure f) => switch (f.code) {
  'NETWORK' => l.err_NETWORK,
  'VALIDATION_FAILED' => l.err_VALIDATION_FAILED,
  'PROVIDER_NOT_CONFIGURED' => l.err_PROVIDER_NOT_CONFIGURED,
  'ACCOUNT_DISABLED' => l.err_ACCOUNT_DISABLED,
  'RATE_LIMITED' => l.err_RATE_LIMITED,
  'APPLE_LOGIN_UNAVAILABLE' => l.err_APPLE_LOGIN_UNAVAILABLE,
  'GOOGLE_SIGN_IN_FAILED' => l.err_GOOGLE_SIGN_IN_FAILED,
  _ => l.err_UNKNOWN,
};
