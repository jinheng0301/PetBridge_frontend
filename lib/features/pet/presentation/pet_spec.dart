import 'package:material_ui/material_ui.dart';

/// What the pet is doing. `cute` is a one-shot played over `idle` / `sleep`.
enum PetPose { idle, sleep, cute }

/// Body plan. `mammal` = big head, small body, two feet; `bird` = round body,
/// two wings, beak, no ears; `fish` (dolphin only) = round body, flippers,
/// tail fluke, no feet.
enum PetFamily { mammal, bird, fish }

enum EarShape {
  none,

  /// Shiba: short triangles with a light inside.
  triangle,

  /// Fox, cat: tall pointed ears with a dark inside.
  pointed,

  /// Leopard, lion: round ears.
  round,

  /// Beaver, otter: small round ears.
  smallRound,

  /// Rabbit: long ears with a pink inside.
  long,

  /// Sheepdog: drooping ears over the sides of the head.
  floppy,

  /// Deer: leaf-shaped ears sticking out sideways.
  leaf,

  /// Alpaca: tall upright ovals.
  upright,

  /// Owl: feather tufts.
  tufts,

  /// Dolphin: a dorsal fin on top.
  fin,
}

enum TailShape {
  none,

  /// Shiba: curled up.
  curl,

  /// Leopard: long, curving, dark tip.
  long,

  /// Lion: thin with a tuft at the end.
  tuft,

  /// Fox: big and bushy with a white tip.
  bushy,

  /// Deer: short and upturned.
  short,

  /// Rabbit: white cotton ball.
  puff,

  /// Beaver: flat paddle.
  flat,

  /// Sheepdog: fluffy ball.
  fluffy,

  /// Cat: thin and long.
  thin,

  /// Otter: thick and tapering.
  otter,

  /// Owl, falcon: a short fan of feathers.
  feathers,

  /// Parrot: long colourful feathers.
  longFeathers,

  /// Dolphin: tail fluke.
  fluke,
}

/// Face and fur markings (and, for birds, which beak goes with the face).
enum MarkShape {
  none,

  /// Leopard: dark spots on head and body.
  spots,

  /// Shiba: big light muzzle and light brow dots.
  shibaFace,

  /// Fox: white cheeks.
  whiteCheeks,

  /// Deer: white spots on the back.
  backSpots,

  /// Beaver: buck teeth.
  teeth,

  /// Sheepdog: shaggy body outline.
  shaggy,

  /// Otter: light muzzle and whiskers.
  whiskers,

  /// Cat: green eyes.
  greenEyes,

  /// Owl: big light eye rings; small beak.
  eyeRings,

  /// Penguin: white heart-shaped face; triangle beak.
  heartFace,

  /// Falcon: dark stripe under each eye; hooked beak.
  tearStripe,

  /// Parrot: red chest; curved beak.
  redChest,
}

/// Things on top of the head.
enum TopperShape {
  none,

  /// Lion.
  mane,

  /// Deer.
  antlers,

  /// Sheepdog: fringe over the forehead.
  fringe,

  /// Alpaca: woolly curls.
  curls,

  /// Parrot: colourful crest feathers.
  crest,
}

/// How one pet is drawn. All pets share one body proportion; they differ by
/// colours, ears, tail, marks and topper.
class PetSpec {
  const new({
    required this.family,
    required this.body,
    required this.light,
    required this.dark,
    required this.ears,
    required this.tail,
    this.marks = MarkShape.none,
    this.topper = TopperShape.none,
  });

  final PetFamily family;

  /// Main fur / feather colour.
  final Color body;

  /// Face, muzzle and belly.
  final Color light;

  /// Markings and inner ears.
  final Color dark;
  final EarShape ears;
  final TailShape tail;
  final MarkShape marks;
  final TopperShape topper;
}

/// The 16 pets, keyed like `pet_catalog.dart`.
const Map<String, PetSpec> petSpecs = {
  'lone_leopard': PetSpec(
    family: PetFamily.mammal,
    body: Color(0xFFF0C878),
    light: Color(0xFFFFF3D9),
    dark: Color(0xFF8A5A2B),
    ears: EarShape.round,
    tail: TailShape.long,
    marks: MarkShape.spots,
  ),
  'leader_lion': PetSpec(
    family: PetFamily.mammal,
    body: Color(0xFFF2C36B),
    light: Color(0xFFFFF0CF),
    dark: Color(0xFFC9772B),
    ears: EarShape.round,
    tail: TailShape.tuft,
    topper: TopperShape.mane,
  ),
  'thinker_owl': PetSpec(
    family: PetFamily.bird,
    body: Color(0xFF9B6B47),
    light: Color(0xFFF3E2C7),
    dark: Color(0xFF6E4A30),
    ears: EarShape.tufts,
    tail: TailShape.feathers,
    marks: MarkShape.eyeRings,
  ),
  'clever_fox': PetSpec(
    family: PetFamily.mammal,
    body: Color(0xFFE8673A),
    light: Color(0xFFFFF6EC),
    dark: Color(0xFF4A2A22),
    ears: EarShape.pointed,
    tail: TailShape.bushy,
    marks: MarkShape.whiteCheeks,
  ),
  'guardian_deer': PetSpec(
    family: PetFamily.mammal,
    body: Color(0xFFD2A275),
    light: Color(0xFFFFF1DE),
    dark: Color(0xFF8A5D3B),
    ears: EarShape.leaf,
    tail: TailShape.short,
    marks: MarkShape.backSpots,
    topper: TopperShape.antlers,
  ),
  'guide_dolphin': PetSpec(
    family: PetFamily.fish,
    body: Color(0xFF6FB7E8),
    light: Color(0xFFE6F5FF),
    dark: Color(0xFF4C93C7),
    ears: EarShape.fin,
    tail: TailShape.fluke,
  ),
  'healing_rabbit': PetSpec(
    family: PetFamily.mammal,
    body: Color(0xFFF7F0F2),
    light: Color(0xFFFFFFFF),
    dark: Color(0xFFF2B7C6),
    ears: EarShape.long,
    tail: TailShape.puff,
  ),
  'happy_shiba': PetSpec(
    family: PetFamily.mammal,
    body: Color(0xFFE99A52),
    light: Color(0xFFFFF3E2),
    dark: Color(0xFFC9773A),
    ears: EarShape.triangle,
    tail: TailShape.curl,
    marks: MarkShape.shibaFace,
  ),
  'steady_beaver': PetSpec(
    family: PetFamily.mammal,
    body: Color(0xFF8B5A3C),
    light: Color(0xFFD9B48F),
    dark: Color(0xFF5E3B26),
    ears: EarShape.smallRound,
    tail: TailShape.flat,
    marks: MarkShape.teeth,
  ),
  'order_sheepdog': PetSpec(
    family: PetFamily.mammal,
    body: Color(0xFFD9D9DE),
    light: Color(0xFFFFFFFF),
    dark: Color(0xFF7D7F8C),
    ears: EarShape.floppy,
    tail: TailShape.fluffy,
    marks: MarkShape.shaggy,
    topper: TopperShape.fringe,
  ),
  'guardian_penguin': PetSpec(
    family: PetFamily.bird,
    body: Color(0xFF3E4A66),
    light: Color(0xFFFFFFFF),
    dark: Color(0xFFF4A340),
    ears: EarShape.none,
    tail: TailShape.none,
    marks: MarkShape.heartFace,
  ),
  'warm_otter': PetSpec(
    family: PetFamily.mammal,
    body: Color(0xFF9A5B3A),
    light: Color(0xFFEBCDB0),
    dark: Color(0xFF6A3D27),
    ears: EarShape.smallRound,
    tail: TailShape.otter,
    marks: MarkShape.whiskers,
  ),
  'calm_blackcat': PetSpec(
    family: PetFamily.mammal,
    body: Color(0xFF3B3A48),
    light: Color(0xFF5E5C70),
    dark: Color(0xFFE89BB0),
    ears: EarShape.pointed,
    tail: TailShape.thin,
    marks: MarkShape.greenEyes,
  ),
  'daring_falcon': PetSpec(
    family: PetFamily.bird,
    body: Color(0xFF7D93AD),
    light: Color(0xFFEEF2F6),
    dark: Color(0xFF34445A),
    ears: EarShape.none,
    tail: TailShape.feathers,
    marks: MarkShape.tearStripe,
  ),
  'easygoing_alpaca': PetSpec(
    family: PetFamily.mammal,
    body: Color(0xFFF3E6CF),
    light: Color(0xFFFFFDF7),
    dark: Color(0xFFC8A982),
    ears: EarShape.upright,
    tail: TailShape.puff,
    topper: TopperShape.curls,
  ),
  'party_parrot': PetSpec(
    family: PetFamily.bird,
    body: Color(0xFF3CC26A),
    light: Color(0xFFFFE066),
    dark: Color(0xFFE5483C),
    ears: EarShape.none,
    tail: TailShape.longFeathers,
    marks: MarkShape.redChest,
    topper: TopperShape.crest,
  ),
};

const _fallback = PetSpec(
  family: PetFamily.mammal,
  body: Color(0xFFB8B8BC),
  light: Color(0xFFEDEDF0),
  dark: Color(0xFF8C8C92),
  ears: EarShape.round,
  tail: TailShape.none,
);

/// The spec for [petType]; a neutral grey mammal for an unknown type.
PetSpec specFor(String petType) => petSpecs[petType] ?? _fallback;
