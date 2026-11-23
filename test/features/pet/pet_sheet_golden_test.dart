import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/features/pet/presentation/pet_catalog.dart';
import 'package:petbridge/features/pet/presentation/pet_painter.dart';
import 'package:petbridge/features/pet/presentation/pet_spec.dart';

const _cell = 120.0;
const _perRow = 4; // pets per row, each shown idle | sleep | cute

const Map<PetPose, Color> _poseBackground = {
  PetPose.idle: Color(0xFFEAF3E6),
  PetPose.sleep: Color(0xFF2F3654),
  PetPose.cute: Color(0xFFFDE7EF),
};

Widget _cellFor(String petType, PetPose pose) => ColoredBox(
  color: _poseBackground[pose]!,
  child: CustomPaint(
    size: const Size.square(_cell),
    painter: PetPainter(
      spec: specFor(petType),
      pose: pose == PetPose.cute ? PetPose.idle : pose,
      phase: pose == PetPose.sleep ? 0.3 : 0,
      cuteProgress: pose == PetPose.cute ? 0.45 : -1,
    ),
  ),
);

void main() {
  testWidgets('pet sheet golden', (tester) async {
    final pets = kPetTypeByMbti.values.toList();
    const width = _cell * 3 * _perRow;
    final height = _cell * (pets.length / _perRow).ceil();
    tester.view.physicalSize = Size(width, height);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: const ValueKey('sheet'),
            child: Wrap(
              children: [
                for (final pet in pets)
                  for (final pose in PetPose.values) _cellFor(pet, pose),
              ],
            ),
          ),
        ),
      ),
    );

    await expectLater(
      find.byKey(const ValueKey('sheet')),
      matchesGoldenFile('goldens/pet_sheet.png'),
    );
  });
}
