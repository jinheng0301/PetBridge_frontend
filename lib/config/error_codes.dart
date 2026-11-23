import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/core/network/app_failure.dart';

/// The ARB key for a server error code.
String errorL10nKey(String code) => 'err_$code';

/// The user-facing text for [f]. Unknown codes fall back to `err_UNKNOWN`;
/// the server's `message` is never shown.
String localizedError(AppLocalizations l, AppFailure f) => switch (f.code) {
  'NETWORK' => l.err_NETWORK,
  'NOT_READY' => l.err_NOT_READY,
  'VALIDATION_FAILED' => l.err_VALIDATION_FAILED,
  'PROVIDER_NOT_CONFIGURED' => l.err_PROVIDER_NOT_CONFIGURED,
  'ACCOUNT_DISABLED' => l.err_ACCOUNT_DISABLED,
  'RATE_LIMITED' => l.err_RATE_LIMITED,
  'APPLE_LOGIN_UNAVAILABLE' => l.err_APPLE_LOGIN_UNAVAILABLE,
  'GOOGLE_SIGN_IN_FAILED' => l.err_GOOGLE_SIGN_IN_FAILED,
  'CODE_INVALID' => l.err_CODE_INVALID,
  'ROOM_FULL' => l.err_ROOM_FULL,
  'ALREADY_MEMBER' => l.err_ALREADY_MEMBER,
  'AGE_RESTRICTED' => l.err_AGE_RESTRICTED,
  'ROOM_LIMIT' => l.err_ROOM_LIMIT,
  'CODE_COOLDOWN' => l.err_CODE_COOLDOWN,
  'ONBOARDING_REQUIRED' => l.err_ONBOARDING_REQUIRED,
  'CODE_ISSUE_LIMIT' => l.err_CODE_ISSUE_LIMIT,
  'NOT_ROOM_OWNER' => l.err_NOT_ROOM_OWNER,
  'OWNER_CANNOT_LEAVE' => l.err_OWNER_CANNOT_LEAVE,
  'ROOM_NOT_FOUND' => l.err_ROOM_NOT_FOUND,
  _ => l.err_UNKNOWN,
};
