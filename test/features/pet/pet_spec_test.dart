import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/features/pet/presentation/pet_catalog.dart';
import 'package:petbridge/features/pet/presentation/pet_spec.dart';

void main() {
  test('every catalog pet has a spec', () {
    for (final slug in kPetTypeByMbti.values) {
      expect(petSpecs[slug], isNotNull, reason: slug);
      expect(specFor(slug), same(petSpecs[slug]), reason: slug);
    }
    expect(petSpecs.keys.toSet(), kPetTypeByMbti.values.toSet());

    const birds = {
      'thinker_owl',
      'guardian_penguin',
      'daring_falcon',
      'party_parrot',
    };
    for (final MapEntry(:key, :value) in petSpecs.entries) {
      final family = switch (key) {
        'guide_dolphin' => PetFamily.fish,
        _ when birds.contains(key) => PetFamily.bird,
        _ => PetFamily.mammal,
      };
      expect(value.family, family, reason: key);
    }
  });

  test('unknown pet falls back', () {
    final spec = specFor('unicorn');
    expect(spec.family, PetFamily.mammal);
    expect(spec.marks, MarkShape.none);
    expect(spec.topper, TopperShape.none);
    expect(petSpecs.values, isNot(contains(same(spec))));
    // Neutral grey: no hue to speak of.
    final rgb = [spec.body.r, spec.body.g, spec.body.b];
    expect(rgb.reduce(math.max) - rgb.reduce(math.min), lessThan(0.06));
  });
}
