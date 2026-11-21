import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/features/invite/application/invite_code.dart';

void main() {
  test('normalizes case, spaces and hyphens', () {
    expect(normalizeCode(' abcd-2345 '), 'ABCD2345');
  });

  test('drops characters outside the alphabet', () {
    expect(normalizeCode('O0I1ab23'), 'AB23');
  });

  test('truncates to 8', () {
    expect(normalizeCode('ABCD2345XY'), 'ABCD2345');
  });

  test('paste extracts code from share link', () {
    expect(
      normalizePaste('来玩 https://petbridge.example.com/j/P9WD2HKR 吧'),
      'P9WD2HKR',
    );
  });

  test('paste of plain text normalizes it', () {
    expect(normalizePaste('p9wd-2hkr'), 'P9WD2HKR');
  });

  test('isValidCode needs exactly 8 alphabet chars', () {
    expect(isValidCode('ABCD2345'), isTrue);
    expect(isValidCode('ABCD234'), isFalse);
    expect(isValidCode('ABCD234O'), isFalse);
  });

  test('formatCode inserts a hyphen after 4', () {
    expect(formatCode('ABCD2345'), 'ABCD-2345');
    expect(formatCode('ABC'), 'ABC');
    expect(formatCode('ABCD'), 'ABCD');
    expect(formatCode('ABCD2'), 'ABCD-2');
  });

  test('validCodeParam rejects lowercase and hyphen', () {
    expect(validCodeParam('abcd2345'), isNull);
    expect(validCodeParam('ABCD-2345'), isNull);
    expect(validCodeParam(null), isNull);
    expect(validCodeParam('ABCD2345'), 'ABCD2345');
  });

  test('shareLink trims trailing slash', () {
    expect(shareLink('https://x.com/', 'ABCD2345'), 'https://x.com/j/ABCD2345');
    expect(shareLink('https://x.com', 'ABCD2345'), 'https://x.com/j/ABCD2345');
  });
}
