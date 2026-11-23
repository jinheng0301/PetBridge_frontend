import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/config/error_codes.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/core/network/app_failure.dart';

void main() {
  final l = lookupAppLocalizations(const Locale('en'));

  test('error key is err_<CODE>', () {
    expect(errorL10nKey('ROOM_LIMIT'), 'err_ROOM_LIMIT');
  });

  test('known code uses its own text', () {
    expect(localizedError(l, const AppFailure('NETWORK')), l.err_NETWORK);
    expect(
      localizedError(l, const AppFailure('NOT_READY', status: 503)),
      l.err_NOT_READY,
    );
  });

  test('unknown code falls back to err_UNKNOWN', () {
    expect(localizedError(l, const AppFailure('SOMETHING_NEW')), l.err_UNKNOWN);
  });

  test('join and code errors have their own text', () {
    for (final code in const [
      'CODE_INVALID',
      'ROOM_FULL',
      'ALREADY_MEMBER',
      'AGE_RESTRICTED',
      'ROOM_LIMIT',
      'CODE_COOLDOWN',
      'ONBOARDING_REQUIRED',
      'CODE_ISSUE_LIMIT',
    ]) {
      expect(
        localizedError(l, AppFailure(code)),
        isNot(l.err_UNKNOWN),
        reason: code,
      );
    }
  });

  test('room admin errors have their own text', () {
    for (final code in const [
      'NOT_ROOM_OWNER',
      'OWNER_CANNOT_LEAVE',
      'ROOM_NOT_FOUND',
    ]) {
      expect(
        localizedError(l, AppFailure(code)),
        isNot(l.err_UNKNOWN),
        reason: code,
      );
    }
  });
}
