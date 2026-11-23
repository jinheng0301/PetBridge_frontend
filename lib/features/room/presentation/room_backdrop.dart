import 'package:material_ui/material_ui.dart';

/// The room behind the pets: a warm striped wall with a window and a plant
/// shelf, a wood floor and a pink rug. Drawn on a 270×470 design canvas
/// stretched to the scene, so the floor and rug stay under the seat
/// anchors (which are relative to the scene) whatever the aspect ratio;
/// round things keep their shape.
class RoomBackdrop extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) => const RepaintBoundary(
    child: CustomPaint(painter: RoomBackdropPainter(), size: Size.infinite),
  );
}

class RoomBackdropPainter extends CustomPainter {
  const new();

  /// The design canvas the coordinates below are written in.
  static const designWidth = 270.0;
  static const designHeight = 470.0;

  static const _wall = Color(0xFFF6E4CC);
  static const _wallStripe = Color(0x99F0D8BA);
  static const _windowFrame = Color(0xFFFFFFFF);
  static const _sky = Color(0xFFBFE3F5);
  static const _sun = Color(0xFFFFF3B0);
  static const _cloud = Color(0xE6FFFFFF);
  static const _wood = Color(0xFFC98A5A);
  static const _shelf = Color(0xFFB97C4E);
  static const _pot = Color(0xFF9CCB8E);
  static const _leaves = Color(0xFF7DB86E);
  static const _floor = Color(0xFFE2B582);
  static const _plank = Color(0xFFD4A06C);
  static const _rug = Color(0xFFF3D9D2);
  static const _rugBorder = Color(0xFFEBC3B8);

  @override
  void paint(Canvas canvas, Size size) {
    final sx = size.width / designWidth;
    final sy = size.height / designHeight;
    // Uniform scale for things that must stay round.
    final s = sx < sy ? sx : sy;
    Rect r(double x, double y, double w, double h) =>
        Rect.fromLTWH(x * sx, y * sy, w * sx, h * sy);
    void rect(
      double x,
      double y,
      double w,
      double h,
      Color c, [
      double rr = 0,
    ]) => canvas.drawRRect(
      RRect.fromRectAndRadius(r(x, y, w, h), Radius.circular(rr * s)),
      Paint()..color = c,
    );
    void circle(double cx, double cy, double radius, Color c) => canvas
        .drawCircle(Offset(cx * sx, cy * sy), radius * s, Paint()..color = c);
    // Ellipses stretch with the scene; the rug has to stay under the seats.
    void oval(double cx, double cy, double rx, double ry, Paint p) =>
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset(cx * sx, cy * sy),
            width: 2 * rx * sx,
            height: 2 * ry * sy,
          ),
          p,
        );

    // Wall with vertical stripes, one every 20 design units.
    rect(0, 0, designWidth, 250, _wall);
    for (var x = 8.0; x < designWidth; x += 20) {
      rect(x, 0, 6, 250, _wallStripe);
    }

    // Window: frame, sky, sun, cloud, muntins, curtain rod.
    rect(80, 62, 110, 88, _windowFrame, 10);
    rect(86, 68, 98, 76, _sky, 6);
    circle(160, 92, 11, _sun);
    final cloud = Paint()..color = _cloud;
    oval(112, 122, 22, 8, cloud);
    oval(128, 118, 14, 7, cloud);
    rect(133, 68, 4, 76, _windowFrame);
    rect(86, 104, 98, 4, _windowFrame);
    rect(72, 58, 126, 8, _wood, 4);

    // Shelf with a potted plant.
    rect(22, 150, 34, 8, _shelf, 3);
    rect(30, 128, 16, 22, _pot, 4);
    circle(38, 122, 12, _leaves);

    // Skirting board, floor and planks.
    rect(0, 240, designWidth, 14, _wood);
    rect(0, 252, designWidth, designHeight - 252, _floor);
    final plank = Paint()
      ..color = _plank
      ..strokeWidth = 2 * s;
    for (var y = 270.0; y < designHeight; y += 30) {
      canvas.drawLine(Offset(0, y * sy), Offset(size.width, y * sy), plank);
    }

    // Rug: centred under the back seats and around the side seats.
    oval(135, 345, 118, 62, Paint()..color = _rug);
    oval(
      135,
      345,
      100,
      50,
      Paint()
        ..color = _rugBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4 * s,
    );
  }

  @override
  bool shouldRepaint(RoomBackdropPainter oldDelegate) => false;
}
