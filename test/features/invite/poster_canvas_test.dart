import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/features/invite/presentation/widgets/poster_canvas.dart';

import '../../helpers/pump_app.dart';

const poster = PosterCanvas(
  petType: 'happy_shiba',
  code: 'ABCD2345',
  memberCount: 3,
  capacity: 5,
  link: 'https://petbridge.example.com/j/ABCD2345',
);

/// Width and height from a PNG's IHDR chunk.
(int, int) pngSize(Uint8List png) {
  final d = ByteData.sublistView(png);
  return (d.getUint32(16), d.getUint32(20));
}

void main() {
  testWidgets('poster golden', (tester) async {
    await pumpLocalized(
      tester,
      const Center(child: RepaintBoundary(child: poster)),
    );

    expect(tester.getSize(find.byType(PosterCanvas)), const Size(360, 480));
    await expectLater(
      find.byType(PosterCanvas),
      matchesGoldenFile('goldens/poster.png'),
    );
  });

  testWidgets('capture produces 1080x1440 png', (tester) async {
    final key = GlobalKey();
    await pumpLocalized(
      tester,
      Center(
        // Shown smaller on screen; the capture is still full size.
        child: SizedBox(
          width: 180,
          height: 240,
          child: FittedBox(
            child: RepaintBoundary(key: key, child: poster),
          ),
        ),
      ),
    );

    final png = await tester.runAsync(() => capturePng(key));

    expect(png!.sublist(1, 4), 'PNG'.codeUnits);
    expect(pngSize(png), (1080, 1440));
  });
}
