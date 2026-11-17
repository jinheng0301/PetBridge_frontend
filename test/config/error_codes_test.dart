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
  });

  test('unknown code falls back to err_UNKNOWN', () {
    expect(localizedError(l, const AppFailure('SOMETHING_NEW')), l.err_UNKNOWN);
  });
}
