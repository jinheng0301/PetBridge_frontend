import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/features/pet/presentation/pet_catalog.dart';

const _slugs = {
  'lone_leopard',
  'leader_lion',
  'thinker_owl',
  'clever_fox',
  'guardian_deer',
  'guide_dolphin',
  'healing_rabbit',
  'happy_shiba',
  'steady_beaver',
  'order_sheepdog',
  'guardian_penguin',
  'warm_otter',
  'calm_blackcat',
  'daring_falcon',
  'easygoing_alpaca',
  'party_parrot',
};

void main() {
  test('maps all 16 types', () {
    expect(kPetTypeByMbti.length, 16);
    expect(kPetTypeByMbti.keys.toSet().length, 16);
    expect(kPetTypeByMbti.values.toSet(), _slugs);
  });

  test('ENFP is happy_shiba', () {
    expect(petTypeFor('ENFP'), 'happy_shiba');
  });

  test('INTJ is lone_leopard', () {
    expect(petTypeFor('INTJ'), 'lone_leopard');
  });

  test('rejects lowercase or bogus', () {
    expect(() => petTypeFor('enfp'), throwsArgumentError);
    expect(() => petTypeFor('XXXX'), throwsArgumentError);
    expect(() => petTypeFor(''), throwsArgumentError);
  });

  test('every pet has a name and intro in every language', () {
    for (final tag in ['en', 'zh_Hans', 'zh_Hant', 'ja', 'ko']) {
      final arb = jsonDecode(
        File('assets/l10n/app_$tag.arb').readAsStringSync(),
      ) as Map<String, dynamic>;
      for (final slug in _slugs) {
        expect(arb['pet_${slug}_name'], isA<String>(), reason: '$tag $slug');
        expect(arb['pet_${slug}_intro'], isA<String>(), reason: '$tag $slug');
      }
    }
  });

  test('petName and petIntro read the localized text', () {
    final l = lookupAppLocalizations(const Locale('en'));
    for (final slug in _slugs) {
      expect(petName(l, slug), isNotEmpty);
      expect(petIntro(l, slug), isNotEmpty);
    }
    expect(petName(l, 'happy_shiba'), l.pet_happy_shiba_name);
    expect(() => petName(l, 'unicorn'), throwsArgumentError);
  });
}
