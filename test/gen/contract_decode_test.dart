import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/gen/pet_bridge_api.dart';

void main() {
  test('Profile decodes the onboarded user', () {
    final profile = Profile.fromJson(const {
      'id': '6f1c2a9e-3b7d-4c1e-9a2f-1d2e3f4a5b6c',
      'onboarded': true,
      'nickname': 'Aki',
      'mbti': 'ENFP',
      'pet_type': 'happy_shiba',
      'native_lang': 'ja',
      'age_band': '18_plus',
      'tz': 'Asia/Tokyo',
    });

    expect(profile.onboarded, isTrue);
    expect(profile.petType, 'happy_shiba');
  });

  test('Profile decodes a new user with null fields', () {
    final profile = Profile.fromJson(const {
      'id': '6f1c2a9e-3b7d-4c1e-9a2f-1d2e3f4a5b6c',
      'nickname': null,
      'native_lang': null,
      'mbti': null,
      'pet_type': null,
      'age_band': null,
      'tz': null,
      'onboarded': false,
    });

    expect(profile.onboarded, isFalse);
    expect(profile.nativeLang, isNull);
    expect(profile.ageBand, isNull);
  });

  test('OnboardingRequest encodes snake_case', () {
    final json = OnboardingRequest.fromJson(const {
      'nickname': 'Aki',
      'mbti': 'ENFP',
      'native_lang': 'ja',
      'age_band': '18_plus',
      'tz': 'Asia/Tokyo',
    }).toJson();

    expect(json, containsPair('native_lang', 'ja'));
    expect(json, containsPair('age_band', '18_plus'));
    expect(json, containsPair('tz', 'Asia/Tokyo'));
  });
}
