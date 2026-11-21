import 'package:petbridge/core/l10n/app_localizations.dart';

/// MBTI → pet slug. Must stay identical to the backend's
/// `internal/service/pet.go`; the server's value is authoritative, this copy
/// only lets onboarding reveal the pet before submitting.
const Map<String, String> kPetTypeByMbti = {
  'INTJ': 'lone_leopard',
  'ENTJ': 'leader_lion',
  'INTP': 'thinker_owl',
  'ENTP': 'clever_fox',
  'INFJ': 'guardian_deer',
  'ENFJ': 'guide_dolphin',
  'INFP': 'healing_rabbit',
  'ENFP': 'happy_shiba',
  'ISTJ': 'steady_beaver',
  'ESTJ': 'order_sheepdog',
  'ISFJ': 'guardian_penguin',
  'ESFJ': 'warm_otter',
  'ISTP': 'calm_blackcat',
  'ESTP': 'daring_falcon',
  'ISFP': 'easygoing_alpaca',
  'ESFP': 'party_parrot',
};

/// The pet slug for an upper-case MBTI type. Throws [ArgumentError] otherwise.
String petTypeFor(String mbti) =>
    kPetTypeByMbti[mbti] ??
    (throw ArgumentError.value(mbti, 'mbti', 'not an MBTI type'));

/// Localized display name for [petType] (`pet_<slug>_name`).
String petName(AppLocalizations l, String petType) => switch (petType) {
  'lone_leopard' => l.pet_lone_leopard_name,
  'leader_lion' => l.pet_leader_lion_name,
  'thinker_owl' => l.pet_thinker_owl_name,
  'clever_fox' => l.pet_clever_fox_name,
  'guardian_deer' => l.pet_guardian_deer_name,
  'guide_dolphin' => l.pet_guide_dolphin_name,
  'healing_rabbit' => l.pet_healing_rabbit_name,
  'happy_shiba' => l.pet_happy_shiba_name,
  'steady_beaver' => l.pet_steady_beaver_name,
  'order_sheepdog' => l.pet_order_sheepdog_name,
  'guardian_penguin' => l.pet_guardian_penguin_name,
  'warm_otter' => l.pet_warm_otter_name,
  'calm_blackcat' => l.pet_calm_blackcat_name,
  'daring_falcon' => l.pet_daring_falcon_name,
  'easygoing_alpaca' => l.pet_easygoing_alpaca_name,
  'party_parrot' => l.pet_party_parrot_name,
  _ => throw ArgumentError.value(petType, 'petType', 'unknown pet'),
};

/// Localized personality blurb for [petType] (`pet_<slug>_intro`).
String petIntro(AppLocalizations l, String petType) => switch (petType) {
  'lone_leopard' => l.pet_lone_leopard_intro,
  'leader_lion' => l.pet_leader_lion_intro,
  'thinker_owl' => l.pet_thinker_owl_intro,
  'clever_fox' => l.pet_clever_fox_intro,
  'guardian_deer' => l.pet_guardian_deer_intro,
  'guide_dolphin' => l.pet_guide_dolphin_intro,
  'healing_rabbit' => l.pet_healing_rabbit_intro,
  'happy_shiba' => l.pet_happy_shiba_intro,
  'steady_beaver' => l.pet_steady_beaver_intro,
  'order_sheepdog' => l.pet_order_sheepdog_intro,
  'guardian_penguin' => l.pet_guardian_penguin_intro,
  'warm_otter' => l.pet_warm_otter_intro,
  'calm_blackcat' => l.pet_calm_blackcat_intro,
  'daring_falcon' => l.pet_daring_falcon_intro,
  'easygoing_alpaca' => l.pet_easygoing_alpaca_intro,
  'party_parrot' => l.pet_party_parrot_intro,
  _ => throw ArgumentError.value(petType, 'petType', 'unknown pet'),
};

/// Whether [petType] is one of the 16 pets this build knows.
bool isKnownPet(String petType) => kPetTypeByMbti.containsValue(petType);
