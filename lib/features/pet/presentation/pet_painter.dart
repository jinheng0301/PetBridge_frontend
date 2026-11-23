import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';
import 'package:petbridge/features/pet/presentation/pet_spec.dart';

const _ink = Color(0xFF2B2233);
const _inkOnDark = Color(0xFFEDEAF5);
const _blush = Color(0x8CFF8FA8);
const _beak = Color(0xFFF4A340);
const _ivory = Color(0xFFF6E7C8);
const _white = Color(0xFFFFFFFF);
const _shadow = Color(0x1F000000);
const _zColor = Color(0xFF8E9AE0);
const _heart = Color(0xFFFF7A9C);
const _catIris = Color(0xFF7BD389);
const _parrotBlue = Color(0xFF3D8BE0);

/// Draws one pet on a 200×200 logical canvas, scaled to the paint size.
///
/// [phase] in `[0, 1)` drives breathing and, when sleeping, the floating z.
/// [cuteProgress] in `[0, 1]` draws the cute one-shot (hop, head tilt,
/// hearts); any other value draws [pose].
class PetPainter extends CustomPainter {
  new({
    required this.spec,
    required this.pose,
    required this.phase,
    this.cuteProgress = -1,
  });

  final PetSpec spec;
  final PetPose pose;
  final double phase;
  final double cuteProgress;

  bool get _cute => cuteProgress >= 0 && cuteProgress <= 1;
  bool get _sleeping => !_cute && pose == PetPose.sleep;

  /// Sleeping pets are drawn a little greyer and darker.
  Color _tone(Color c) {
    if (!_sleeping) return c;
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withSaturation(hsl.saturation * 0.6)
        .withLightness(hsl.lightness * 0.9)
        .toColor();
  }

  Paint _fill(Color c) => Paint()..color = _tone(c);

  Paint _stroke(Color c, double width) => Paint()
    ..color = _tone(c)
    ..style = PaintingStyle.stroke
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  /// Strokes on the face: light on a very dark mammal head (the cat).
  Color get _faceInk =>
      spec.family == PetFamily.mammal && spec.body.computeLuminance() < 0.1
      ? _inkOnDark
      : _ink;

  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..save()
      ..scale(size.width / 200, size.height / 200);

    // Body motion: breathing, or the cute hop.
    var sx = 1.0;
    var sy = 1.0;
    var dy = 0.0;
    var tilt = 0.0;
    if (_cute) {
      (dy, sx, sy) = _hop(cuteProgress);
      tilt = 8 * math.pi / 180 * math.sin(math.pi * cuteProgress);
    } else {
      final s = (1 - math.cos(2 * math.pi * phase)) / 2;
      if (_sleeping) {
        sx = 1 + 0.02 * s;
        sy = 1 - 0.04 * s;
      } else {
        sx = 1 + 0.012 * s;
        sy = 1 - 0.022 * s;
      }
    }

    final lift = (-dy / 16).clamp(0.0, 1.0);
    _oval(canvas, 100, 190, 50 * (1 - 0.3 * lift), 6, Paint()..color = _shadow);

    canvas
      ..save()
      ..translate(100, 185 + dy)
      ..scale(sx, sy)
      ..translate(-100, -185);
    _drawBody(canvas);
    canvas
      ..save()
      ..translate(100, 140)
      ..rotate(tilt)
      ..translate(-100, -140);
    _drawHead(canvas);
    canvas
      ..restore()
      ..restore();

    if (_cute) _drawHearts(canvas, cuteProgress);
    if (_sleeping) _drawZs(canvas);
    canvas.restore();
  }

  /// One hop over the cute one-shot: (dy, scaleX, scaleY).
  static (double, double, double) _hop(double p) {
    double seg(double a, double b) =>
        Curves.easeInOut.transform(((p - a) / (b - a)).clamp(0.0, 1.0));
    if (p < 0.15) {
      final t = seg(0, 0.15);
      return (0, 1 + 0.06 * t, 1 - 0.08 * t);
    }
    if (p < 0.45) {
      final t = seg(0.15, 0.45);
      return (-16 * t, 1.06 - 0.09 * t, 0.92 + 0.12 * t);
    }
    if (p < 0.75) {
      final t = seg(0.45, 0.75);
      return (-16 * (1 - t), 0.97 + 0.03 * t, 1.04 - 0.04 * t);
    }
    return (0, 1, 1);
  }

  // ---------------------------------------------------------------- body

  void _drawBody(Canvas canvas) {
    _drawTail(canvas);
    switch (spec.family) {
      case PetFamily.mammal:
        _drawMammalBody(canvas);
      case PetFamily.bird:
        _drawBirdBody(canvas);
      case PetFamily.fish:
        _drawFishBody(canvas);
    }
  }

  void _drawMammalBody(Canvas canvas) {
    final body = _fill(spec.body);
    if (spec.marks == MarkShape.shaggy) {
      for (var i = 0; i < 12; i++) {
        final a = i / 12 * 2 * math.pi;
        canvas.drawCircle(
          Offset(100 + 36 * math.cos(a), 150 + 28 * math.sin(a)),
          9,
          body,
        );
      }
    }
    _oval(canvas, 100, 150, 40, 32, body);
    _oval(canvas, 100, 156, 24, 19, _fill(spec.light));
    if (spec.marks == MarkShape.spots) {
      final dark = _fill(spec.dark);
      for (final (x, y, r) in const [
        (70.0, 140.0, 3.6),
        (76.0, 160.0, 3.0),
        (130.0, 140.0, 3.6),
        (124.0, 160.0, 3.0),
        (68.0, 152.0, 2.4),
        (132.0, 152.0, 2.4),
      ]) {
        canvas.drawCircle(Offset(x, y), r, dark);
      }
    }
    if (spec.marks == MarkShape.backSpots) {
      final spot = _fill(_white);
      for (final (x, y, r) in const [
        (70.0, 142.0, 3.4),
        (78.0, 160.0, 2.8),
        (130.0, 142.0, 3.4),
        (122.0, 160.0, 2.8),
        (66.0, 156.0, 2.2),
        (134.0, 156.0, 2.2),
      ]) {
        canvas.drawCircle(Offset(x, y), r, spot);
      }
    }
    _oval(canvas, 82, 178, 12, 8, body);
    _oval(canvas, 118, 178, 12, 8, body);
  }

  void _drawBirdBody(Canvas canvas) {
    final body = _fill(spec.body);
    if (spec.marks == MarkShape.tearStripe) {
      // Pointed wings, dark tips.
      for (final side in const [-1.0, 1.0]) {
        final x = 100 + 54 * side;
        final wing = Path()
          ..moveTo(100 + 36 * side, 118)
          ..quadraticBezierTo(x + 8 * side, 124, 100 + 60 * side, 172)
          ..quadraticBezierTo(x - 10 * side, 160, 100 + 34 * side, 160)
          ..close();
        canvas.drawPath(wing, body);
        final tip = Path()
          ..moveTo(100 + 52 * side, 150)
          ..quadraticBezierTo(x + 6 * side, 158, 100 + 60 * side, 172)
          ..quadraticBezierTo(x - 6 * side, 164, 100 + 46 * side, 158)
          ..close();
        canvas.drawPath(tip, _fill(spec.dark));
      }
    } else {
      _oval(canvas, 46, 132, 11, 26, body, rotDeg: 18);
      _oval(canvas, 154, 132, 11, 26, body, rotDeg: -18);
    }
    _oval(canvas, 100, 146, 46, 38, body);
    final belly = spec.marks == MarkShape.redChest ? spec.dark : spec.light;
    _oval(canvas, 100, 152, 32, 28, _fill(belly));
    if (spec.marks == MarkShape.eyeRings) {
      final v = _stroke(spec.dark, 2.2);
      for (final (x, y) in const [
        (88.0, 144.0),
        (112.0, 144.0),
        (100.0, 156.0),
        (88.0, 166.0),
        (112.0, 166.0),
      ]) {
        canvas.drawPath(
          Path()
            ..moveTo(x - 5, y - 2)
            ..lineTo(x, y + 2)
            ..lineTo(x + 5, y - 2),
          v,
        );
      }
    }
    if (spec.marks == MarkShape.tearStripe) {
      final bar = _stroke(spec.dark, 2.2);
      for (final y in const [146.0, 156.0, 166.0]) {
        final w = y == 156 ? 14.0 : 11.0;
        canvas.drawLine(Offset(100 - w, y), Offset(100 + w, y), bar);
      }
    }
    final feet = _fill(_beak);
    _oval(canvas, 84, 182, 12, 6, feet);
    _oval(canvas, 116, 182, 12, 6, feet);
  }

  void _drawFishBody(Canvas canvas) {
    final fin = _fill(spec.dark);
    _oval(canvas, 54, 156, 10, 20, fin, rotDeg: 50);
    _oval(canvas, 146, 156, 10, 20, fin, rotDeg: -50);
    _oval(canvas, 100, 150, 44, 34, _fill(spec.body));
    _oval(canvas, 100, 158, 28, 21, _fill(spec.light));
  }

  void _drawTail(Canvas canvas) {
    final body = _fill(spec.body);
    switch (spec.tail) {
      case TailShape.none:
        break;
      case TailShape.curl:
        canvas.drawPath(
          Path()
            ..moveTo(134, 150)
            ..cubicTo(160, 150, 164, 122, 146, 120)
            ..cubicTo(134, 119, 132, 134, 144, 134),
          _stroke(spec.body, 12),
        );
      case TailShape.long:
        canvas
          ..drawPath(
            Path()
              ..moveTo(134, 166)
              ..cubicTo(170, 170, 180, 140, 166, 116),
            _stroke(spec.body, 9),
          )
          ..drawCircle(const Offset(166, 116), 5.5, _fill(spec.dark));
      case TailShape.tuft:
        canvas
          ..drawPath(
            Path()
              ..moveTo(136, 158)
              ..cubicTo(156, 160, 158, 140, 162, 132),
            _stroke(spec.body, 6),
          )
          ..drawCircle(const Offset(163, 128), 8, _fill(spec.dark));
      case TailShape.bushy:
        final tail = Path()
          ..moveTo(126, 172)
          ..cubicTo(164, 182, 190, 150, 174, 112)
          ..cubicTo(160, 126, 144, 136, 130, 148)
          ..close();
        canvas
          ..drawPath(tail, body)
          ..save()
          ..clipPath(tail)
          ..drawCircle(const Offset(178, 114), 16, _fill(spec.light))
          ..restore();
      case TailShape.short:
        _oval(canvas, 138, 146, 9, 7, body, rotDeg: -30);
        _oval(canvas, 140, 145, 5, 4, _fill(spec.light), rotDeg: -30);
      case TailShape.puff:
        canvas.drawCircle(const Offset(138, 160), 10, _fill(_white));
      case TailShape.flat:
        _oval(canvas, 152, 172, 24, 10, _fill(spec.dark), rotDeg: -20);
        final hatch = _stroke(spec.body, 1.6);
        for (final dx in const [-10.0, 0.0, 10.0]) {
          canvas.drawLine(
            Offset(152 + dx - 3, 166 - dx * 0.36),
            Offset(152 + dx + 3, 178 - dx * 0.36),
            hatch,
          );
        }
      case TailShape.fluffy:
        canvas.drawCircle(const Offset(138, 154), 12, _fill(spec.light));
      case TailShape.thin:
        canvas.drawPath(
          Path()
            ..moveTo(134, 166)
            ..cubicTo(170, 170, 166, 122, 152, 112),
          _stroke(spec.body, 6),
        );
      case TailShape.otter:
        canvas.drawPath(
          Path()
            ..moveTo(128, 162)
            ..cubicTo(150, 186, 172, 178, 178, 158)
            ..cubicTo(166, 170, 150, 168, 138, 152)
            ..close(),
          body,
        );
      case TailShape.feathers:
        final f = _fill(spec.dark);
        for (final rot in const [20.0, 40.0, 60.0]) {
          _oval(canvas, 140, 172, 18, 6, f, rotDeg: rot - 30);
        }
      case TailShape.longFeathers:
        _oval(canvas, 148, 176, 28, 6, _fill(_parrotBlue), rotDeg: 30);
        _oval(canvas, 146, 172, 26, 6, _fill(spec.dark), rotDeg: 12);
      case TailShape.fluke:
        final tail = Path()
          ..moveTo(126, 170)
          ..quadraticBezierTo(156, 176, 164, 150)
          ..lineTo(150, 136)
          ..quadraticBezierTo(166, 140, 172, 132)
          ..quadraticBezierTo(180, 150, 168, 160)
          ..quadraticBezierTo(178, 166, 184, 162)
          ..quadraticBezierTo(178, 182, 160, 176)
          ..quadraticBezierTo(146, 186, 126, 178)
          ..close();
        canvas.drawPath(tail, _fill(spec.body));
    }
  }

  // ---------------------------------------------------------------- head

  void _drawHead(Canvas canvas) {
    _drawTopperBehind(canvas);
    _drawEarsBehind(canvas);
    canvas.drawCircle(const Offset(100, 92), 50, _fill(spec.body));
    _drawFace(canvas);
    _drawEarsFront(canvas);
    _drawTopperFront(canvas);
    _drawEyes(canvas);
    _oval(canvas, 70, 107, 8, 5, _fill(_blush));
    _oval(canvas, 130, 107, 8, 5, _fill(_blush));
    _drawNoseAndMouth(canvas);
  }

  void _drawTopperBehind(Canvas canvas) {
    switch (spec.topper) {
      case TopperShape.mane:
        final mane = _fill(spec.dark);
        for (var i = 0; i < 14; i++) {
          final a = i / 14 * 2 * math.pi;
          canvas.drawCircle(
            Offset(100 + 60 * math.cos(a), 92 + 58 * math.sin(a)),
            17,
            mane,
          );
        }
        canvas.drawCircle(const Offset(100, 92), 58, mane);
      case TopperShape.antlers:
        final antler = _stroke(spec.dark, 6);
        for (final side in const [-1.0, 1.0]) {
          canvas
            ..drawPath(
              Path()
                ..moveTo(100 + 20 * side, 50)
                ..quadraticBezierTo(100 + 30 * side, 30, 100 + 26 * side, 14),
              antler,
            )
            ..drawLine(
              Offset(100 + 28 * side, 30),
              Offset(100 + 40 * side, 22),
              antler,
            );
        }
      case TopperShape.crest:
        for (final (rot, color) in const [
          (-24.0, Color(0xFFE5483C)),
          (0.0, Color(0xFFFFC93C)),
          (24.0, _parrotBlue),
        ]) {
          canvas
            ..save()
            ..translate(100, 48)
            ..rotate(rot * math.pi / 180);
          _oval(canvas, 0, -16, 7, 18, _fill(color));
          canvas.restore();
        }
      case TopperShape.none:
      case TopperShape.fringe:
      case TopperShape.curls:
        break;
    }
  }

  void _drawTopperFront(Canvas canvas) {
    switch (spec.topper) {
      case TopperShape.fringe:
        final fringe = _fill(spec.light);
        for (final (x, y, r) in const [
          (74.0, 62.0, 15.0),
          (100.0, 54.0, 19.0),
          (126.0, 62.0, 15.0),
          (88.0, 66.0, 13.0),
          (112.0, 66.0, 13.0),
        ]) {
          canvas.drawCircle(Offset(x, y), r, fringe);
        }
      case TopperShape.curls:
        final wool = _fill(spec.light);
        for (final (x, y, r) in const [
          (82.0, 50.0, 11.0),
          (100.0, 42.0, 13.0),
          (118.0, 50.0, 11.0),
          (91.0, 56.0, 9.0),
          (109.0, 56.0, 9.0),
        ]) {
          canvas.drawCircle(Offset(x, y), r, wool);
        }
      case TopperShape.none:
      case TopperShape.mane:
      case TopperShape.antlers:
      case TopperShape.crest:
        break;
    }
  }

  void _drawEarsBehind(Canvas canvas) {
    final body = _fill(spec.body);
    final dark = _fill(spec.dark);
    switch (spec.ears) {
      case EarShape.triangle:
        final light = _fill(spec.light);
        canvas
          ..drawPath(_poly([56, 66, 64, 22, 94, 46]), body)
          ..drawPath(_poly([64, 56, 67, 34, 84, 47]), light)
          ..drawPath(_poly([144, 66, 136, 22, 106, 46]), body)
          ..drawPath(_poly([136, 56, 133, 34, 116, 47]), light);
      case EarShape.pointed:
        canvas
          ..drawPath(_poly([54, 72, 58, 16, 96, 48]), body)
          ..drawPath(_poly([63, 60, 64, 30, 86, 50]), dark)
          ..drawPath(_poly([146, 72, 142, 16, 104, 48]), body)
          ..drawPath(_poly([137, 60, 136, 30, 114, 50]), dark);
      case EarShape.round:
        canvas
          ..drawCircle(const Offset(66, 52), 13, body)
          ..drawCircle(const Offset(66, 52), 6.5, dark)
          ..drawCircle(const Offset(134, 52), 13, body)
          ..drawCircle(const Offset(134, 52), 6.5, dark);
      case EarShape.smallRound:
        canvas
          ..drawCircle(const Offset(64, 58), 10, body)
          ..drawCircle(const Offset(64, 58), 5, dark)
          ..drawCircle(const Offset(136, 58), 10, body)
          ..drawCircle(const Offset(136, 58), 5, dark);
      case EarShape.long:
        _rotated(canvas, 80, 60, -12, () {
          _oval(canvas, 80, 34, 12, 32, body);
          _oval(canvas, 80, 36, 6, 22, dark);
        });
        _rotated(canvas, 120, 60, 12, () {
          _oval(canvas, 120, 34, 12, 32, body);
          _oval(canvas, 120, 36, 6, 22, dark);
        });
      case EarShape.leaf:
        _oval(canvas, 46, 68, 20, 9, body, rotDeg: -28);
        _oval(canvas, 47, 68, 12, 4.5, _fill(spec.light), rotDeg: -28);
        _oval(canvas, 154, 68, 20, 9, body, rotDeg: 28);
        _oval(canvas, 153, 68, 12, 4.5, _fill(spec.light), rotDeg: 28);
      case EarShape.upright:
        _oval(canvas, 70, 44, 10, 22, body, rotDeg: -14);
        _oval(canvas, 70, 46, 5, 14, dark, rotDeg: -14);
        _oval(canvas, 130, 44, 10, 22, body, rotDeg: 14);
        _oval(canvas, 130, 46, 5, 14, dark, rotDeg: 14);
      case EarShape.tufts:
        canvas
          ..drawPath(_poly([58, 64, 60, 28, 88, 48]), body)
          ..drawPath(_poly([142, 64, 140, 28, 112, 48]), body);
      case EarShape.fin:
        canvas.drawPath(
          Path()
            ..moveTo(88, 46)
            ..quadraticBezierTo(100, 18, 126, 18)
            ..quadraticBezierTo(112, 28, 114, 46)
            ..close(),
          body,
        );
      case EarShape.none:
      case EarShape.floppy:
        break;
    }
  }

  void _drawEarsFront(Canvas canvas) {
    if (spec.ears != EarShape.floppy) return;
    final dark = _fill(spec.dark);
    _oval(canvas, 54, 92, 13, 27, dark, rotDeg: 14);
    _oval(canvas, 146, 92, 13, 27, dark, rotDeg: -14);
  }

  void _drawFace(Canvas canvas) {
    final light = _fill(spec.light);
    switch (spec.family) {
      case PetFamily.fish:
        _oval(canvas, 100, 112, 24, 14, light);
        return;
      case PetFamily.bird:
        switch (spec.marks) {
          case MarkShape.heartFace:
            canvas.drawPath(
              Path()
                ..moveTo(100, 62)
                ..cubicTo(72, 50, 50, 78, 58, 104)
                ..cubicTo(64, 124, 84, 128, 100, 122)
                ..cubicTo(116, 128, 136, 124, 142, 104)
                ..cubicTo(150, 78, 128, 50, 100, 62)
                ..close(),
              light,
            );
          case MarkShape.eyeRings:
            _oval(canvas, 100, 108, 22, 16, light);
            canvas
              ..drawCircle(const Offset(82, 92), 17, _fill(spec.dark))
              ..drawCircle(const Offset(118, 92), 17, _fill(spec.dark))
              ..drawCircle(const Offset(82, 92), 14, light)
              ..drawCircle(const Offset(118, 92), 14, light);
          case MarkShape.tearStripe:
            _oval(canvas, 100, 112, 32, 22, light);
            final stripe = _fill(spec.dark);
            for (final side in const [-1.0, 1.0]) {
              canvas.drawPath(
                Path()
                  ..moveTo(100 + 25 * side, 100)
                  ..quadraticBezierTo(
                    100 + 25 * side,
                    114,
                    100 + 21 * side,
                    124,
                  )
                  ..quadraticBezierTo(
                    100 + 16 * side,
                    112,
                    100 + 15 * side,
                    101,
                  )
                  ..close(),
                stripe,
              );
            }
            // Dark cap.
            canvas
              ..save()
              ..clipPath(
                Path()..addOval(
                  Rect.fromCircle(center: const Offset(100, 92), radius: 50),
                ),
              );
            _oval(canvas, 100, 46, 54, 26, stripe);
            canvas.restore();
          case MarkShape.redChest:
            canvas
              ..drawCircle(const Offset(82, 92), 13, light)
              ..drawCircle(const Offset(118, 92), 13, light);
          case MarkShape.none:
          case MarkShape.spots:
          case MarkShape.shibaFace:
          case MarkShape.whiteCheeks:
          case MarkShape.backSpots:
          case MarkShape.teeth:
          case MarkShape.shaggy:
          case MarkShape.whiskers:
          case MarkShape.greenEyes:
            break;
        }
        return;
      case PetFamily.mammal:
        switch (spec.marks) {
          case MarkShape.shibaFace:
            _oval(canvas, 100, 108, 34, 24, light);
            _oval(canvas, 82, 78, 7, 4, light);
            _oval(canvas, 118, 78, 7, 4, light);
          case MarkShape.whiteCheeks:
            _oval(canvas, 78, 112, 24, 18, light, rotDeg: -18);
            _oval(canvas, 122, 112, 24, 18, light, rotDeg: 18);
            _oval(canvas, 100, 112, 16, 14, light);
          case MarkShape.spots:
            _oval(canvas, 100, 108, 26, 18, light);
            final dark = _fill(spec.dark);
            for (final (x, y, r) in const [
              (88.0, 58.0, 3.4),
              (100.0, 52.0, 2.8),
              (112.0, 58.0, 3.4),
              (62.0, 86.0, 3.0),
              (138.0, 86.0, 3.0),
              (66.0, 72.0, 2.4),
              (134.0, 72.0, 2.4),
            ]) {
              canvas.drawCircle(Offset(x, y), r, dark);
            }
          case MarkShape.none:
          case MarkShape.backSpots:
          case MarkShape.teeth:
          case MarkShape.shaggy:
          case MarkShape.whiskers:
          case MarkShape.greenEyes:
          case MarkShape.eyeRings:
          case MarkShape.heartFace:
          case MarkShape.tearStripe:
          case MarkShape.redChest:
            _oval(canvas, 100, 108, 26, 18, light);
        }
    }
  }

  void _drawEyes(Canvas canvas) {
    if (_sleeping) {
      canvas.drawPath(
        Path()
          ..moveTo(73, 94)
          ..quadraticBezierTo(82, 100, 91, 94)
          ..moveTo(109, 94)
          ..quadraticBezierTo(118, 100, 127, 94),
        _stroke(_faceInk, 3.5),
      );
      return;
    }
    final big = _cute;
    final rx = big ? 8.5 : 6.0;
    final ry = big ? 10.5 : 8.0;
    final white = _fill(_white);
    for (final x in const [82.0, 118.0]) {
      if (spec.marks == MarkShape.greenEyes) {
        _oval(canvas, x, 92, rx + 1, ry + 1, _fill(_catIris));
        _oval(canvas, x, 92, big ? 5 : 2.6, ry - 1, _fill(_ink));
      } else {
        _oval(canvas, x, 92, rx, ry, _fill(_ink));
      }
      canvas.drawCircle(
        Offset(x + (big ? 3 : 2), big ? 87 : 89),
        big ? 3.2 : 2.2,
        white,
      );
      if (big) canvas.drawCircle(Offset(x - 3, 96), 1.6, white);
    }
  }

  void _drawNoseAndMouth(Canvas canvas) {
    final ink = _stroke(_faceInk, 2.5);
    switch (spec.family) {
      case PetFamily.fish:
        canvas.drawPath(
          _sleeping
              ? (Path()
                  ..moveTo(94, 113)
                  ..quadraticBezierTo(100, 116, 106, 113))
              : (Path()
                  ..moveTo(88, 110)
                  ..quadraticBezierTo(100, 121, 112, 110)),
          ink,
        );
      case PetFamily.bird:
        _drawBeak(canvas, ink);
      case PetFamily.mammal:
        final noseColor = spec.marks == MarkShape.greenEyes ? spec.dark : _ink;
        _oval(canvas, 100, 103, 4.5, 3.2, _fill(noseColor));
        if (_sleeping) {
          canvas.drawPath(
            Path()
              ..moveTo(95, 112)
              ..quadraticBezierTo(100, 114, 105, 112),
            ink,
          );
        } else {
          canvas.drawPath(_smile(108), ink);
        }
        if (spec.marks == MarkShape.teeth) {
          final tooth = _fill(_white);
          canvas
            ..drawRRect(
              RRect.fromLTRBR(95, 109, 99.4, 117, const Radius.circular(1.2)),
              tooth,
            )
            ..drawRRect(
              RRect.fromLTRBR(100.6, 109, 105, 117, const Radius.circular(1.2)),
              tooth,
            );
        }
        if (spec.marks == MarkShape.whiskers) {
          final whisker = _stroke(_ink.withValues(alpha: 0.55), 1.6);
          for (final side in const [-1.0, 1.0]) {
            canvas
              ..drawLine(
                Offset(100 + 18 * side, 104),
                Offset(100 + 38 * side, 99),
                whisker,
              )
              ..drawLine(
                Offset(100 + 18 * side, 109),
                Offset(100 + 38 * side, 111),
                whisker,
              );
          }
        }
    }
  }

  void _drawBeak(Canvas canvas, Paint ink) {
    switch (spec.marks) {
      case MarkShape.tearStripe:
        // Hooked.
        canvas.drawPath(
          Path()
            ..moveTo(92, 101)
            ..quadraticBezierTo(100, 95, 108, 101)
            ..quadraticBezierTo(108, 110, 101, 116)
            ..quadraticBezierTo(101, 108, 92, 101)
            ..close(),
          _fill(_beak),
        );
      case MarkShape.redChest:
        // Big curved beak.
        canvas.drawPath(
          Path()
            ..moveTo(90, 100)
            ..quadraticBezierTo(100, 92, 110, 100)
            ..quadraticBezierTo(111, 112, 100, 120)
            ..quadraticBezierTo(102, 109, 90, 104)
            ..close(),
          _fill(_ivory),
        );
      case MarkShape.eyeRings:
        canvas.drawPath(_poly([95, 101, 105, 101, 100, 110]), _fill(_beak));
      case MarkShape.heartFace:
      case MarkShape.none:
      case MarkShape.spots:
      case MarkShape.shibaFace:
      case MarkShape.whiteCheeks:
      case MarkShape.backSpots:
      case MarkShape.teeth:
      case MarkShape.shaggy:
      case MarkShape.whiskers:
      case MarkShape.greenEyes:
        canvas.drawPath(_poly([92, 102, 108, 102, 100, 112]), _fill(_beak));
        if (_sleeping) {
          canvas.drawPath(
            Path()
              ..moveTo(95, 117)
              ..quadraticBezierTo(100, 119, 105, 117),
            ink,
          );
        } else {
          canvas.drawPath(_smile(115), ink);
        }
    }
  }

  // ---------------------------------------------------------------- props

  void _drawHearts(Canvas canvas, double p) {
    for (final (x, y, scale, delay) in const [
      (40.0, 70.0, 1.2, 0.0),
      (160.0, 60.0, 1.0, 0.12),
      (166.0, 130.0, 0.85, 0.24),
    ]) {
      final t = (p - delay) / 0.7;
      if (t <= 0 || t >= 1) continue;
      final alpha = t < 0.15
          ? t / 0.15
          : 1 - math.pow((t - 0.15) / 0.85, 2).toDouble();
      canvas
        ..save()
        ..translate(x, y - 40 * t)
        ..scale(scale)
        ..drawPath(
          Path()
            ..moveTo(0, 0)
            ..relativeCubicTo(-4, -7, -14, -5, -12, 3)
            ..relativeCubicTo(1, 5, 7, 9, 12, 13)
            ..relativeCubicTo(5, -4, 11, -8, 12, -13)
            ..relativeCubicTo(2, -8, -8, -10, -12, -3)
            ..close(),
          Paint()..color = _heart.withValues(alpha: alpha.clamp(0.0, 1.0)),
        )
        ..restore();
    }
  }

  void _drawZs(Canvas canvas) {
    for (var i = 0; i < 3; i++) {
      final t = (phase + i / 3) % 1;
      final alpha = t < 0.2 ? t / 0.2 : 1 - (t - 0.2) / 0.8;
      final s = 8.0 + 2.5 * i;
      final x = 138 + 16 * t;
      final y = 50 - 40 * t;
      canvas.drawPath(
        Path()
          ..moveTo(x, y)
          ..lineTo(x + s, y)
          ..lineTo(x, y + s)
          ..lineTo(x + s, y + s),
        Paint()
          ..color = _zColor.withValues(alpha: alpha.clamp(0.0, 1.0))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.6
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  // ---------------------------------------------------------------- helpers

  static Path _smile(double y) => Path()
    ..moveTo(91, y)
    ..quadraticBezierTo(95.5, y + 6, 100, y)
    ..quadraticBezierTo(104.5, y + 6, 109, y);

  static Path _poly(List<double> xy) {
    final path = Path()..moveTo(xy[0], xy[1]);
    for (var i = 2; i < xy.length; i += 2) {
      path.lineTo(xy[i], xy[i + 1]);
    }
    return path..close();
  }

  static void _oval(
    Canvas canvas,
    double cx,
    double cy,
    double rx,
    double ry,
    Paint paint, {
    double rotDeg = 0,
  }) {
    final rect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: rx * 2,
      height: ry * 2,
    );
    if (rotDeg == 0) {
      canvas.drawOval(rect, paint);
      return;
    }
    _rotated(canvas, cx, cy, rotDeg, () => canvas.drawOval(rect, paint));
  }

  static void _rotated(
    Canvas canvas,
    double cx,
    double cy,
    double deg,
    void Function() draw,
  ) {
    canvas
      ..save()
      ..translate(cx, cy)
      ..rotate(deg * math.pi / 180)
      ..translate(-cx, -cy);
    draw();
    canvas.restore();
  }

  @override
  bool shouldRepaint(PetPainter old) =>
      old.spec != spec ||
      old.pose != pose ||
      old.phase != phase ||
      old.cuteProgress != cuteProgress;
}
