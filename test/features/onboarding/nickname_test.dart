import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/features/onboarding/application/nickname.dart';

void main() {
  test("'  Aki  ' ok", () {
    expect(validateNickname('  Aki  '), isNull);
  });

  test("'' and '   ' empty", () {
    expect(validateNickname(''), NicknameError.empty);
    expect(validateNickname('   '), NicknameError.empty);
  });

  test('21 CJK chars tooLong, 20 ok', () {
    expect(validateNickname('猫' * 21), NicknameError.tooLong);
    expect(validateNickname('猫' * 20), isNull);
  });

  test('length is counted after trimming', () {
    expect(validateNickname('  ${'a' * 20}  '), isNull);
  });

  test('emoji counts by rune', () {
    expect(validateNickname('😀' * 20), isNull);
    expect(validateNickname('😀' * 21), NicknameError.tooLong);
  });

  test(r"'\u0007a' invalidChars", () {
    expect(validateNickname('\u0007a'), NicknameError.invalidChars);
  });

  test('DEL and C1 controls are invalidChars', () {
    expect(validateNickname('a\u007Fb'), NicknameError.invalidChars);
    expect(validateNickname('a\u0085b'), NicknameError.invalidChars);
  });
}
