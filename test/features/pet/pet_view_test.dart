import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/features/pet/presentation/pet_painter.dart';
import 'package:petbridge/features/pet/presentation/pet_spec.dart';
import 'package:petbridge/features/pet/presentation/pet_view.dart';

Widget _host(Widget child) => MaterialApp(
  home: Scaffold(body: Center(child: child)),
);

PetPainter _painter(WidgetTester tester) {
  final paint = tester.widget<CustomPaint>(
    find.descendant(
      of: find.byType(PetView),
      matching: find.byType(CustomPaint),
    ),
  );
  return paint.painter! as PetPainter;
}

void main() {
  // test/flutter_test_config.dart turns pet animation off for the rest of the
  // suite; these tests are about the animation, so turn it back on.
  late bool saved;
  setUp(() {
    saved = debugPetViewAnimations;
    debugPetViewAnimations = true;
  });
  tearDown(() => debugPetViewAnimations = saved);

  testWidgets('uses the requested size', (tester) async {
    await tester.pumpWidget(
      _host(const PetView(petType: 'clever_fox', size: 96)),
    );
    expect(tester.getSize(find.byType(PetView)), const Size(96, 96));
  });

  testWidgets('paints the spec for its type inside a RepaintBoundary', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const PetView(petType: 'thinker_owl')));
    expect(_painter(tester).spec, same(specFor('thinker_owl')));
    expect(
      find.descendant(
        of: find.byType(PetView),
        matching: find.byType(RepaintBoundary),
      ),
      findsWidgets,
    );
  });

  testWidgets('cuteTick plays cute then returns to pose', (tester) async {
    await tester.pumpWidget(_host(const PetView(petType: 'happy_shiba')));
    expect(_painter(tester).cuteProgress, -1);

    await tester.pumpWidget(
      _host(const PetView(petType: 'happy_shiba', cuteTick: 1)),
    );
    await tester.pump(const Duration(milliseconds: 600));
    final mid = _painter(tester);
    expect(mid.cuteProgress, greaterThan(0));
    expect(mid.cuteProgress, lessThan(1));

    await tester.pump(const Duration(milliseconds: 700));
    final after = _painter(tester);
    expect(after.cuteProgress, -1);
    expect(after.pose, PetPose.idle);
  });

  testWidgets('retriggering cute restarts it', (tester) async {
    await tester.pumpWidget(
      _host(const PetView(petType: 'happy_shiba', cuteTick: 1)),
    );
    await tester.pump(const Duration(milliseconds: 800));
    await tester.pumpWidget(
      _host(const PetView(petType: 'happy_shiba', cuteTick: 2)),
    );
    await tester.pump(const Duration(milliseconds: 600));

    // 1.4 s after the first tick: only still cute because it restarted.
    final p = _painter(tester).cuteProgress;
    expect(p, greaterThan(0.3));
    expect(p, lessThan(0.7));
  });

  testWidgets('animate false paints a still frame', (tester) async {
    await tester.pumpWidget(
      _host(const PetView(petType: 'happy_shiba', animate: false)),
    );
    // Let the host's own first-frame work finish.
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(tester.hasRunningAnimations, isFalse);
    expect(_painter(tester).cuteProgress, -1);

    // A cute trigger does not start anything either.
    await tester.pumpWidget(
      _host(const PetView(petType: 'happy_shiba', animate: false, cuteTick: 1)),
    );
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);
    expect(_painter(tester).cuteProgress, -1);
  });

  testWidgets('sleep pose uses sleep painter', (tester) async {
    await tester.pumpWidget(
      _host(const PetView(petType: 'calm_blackcat', pose: PetPose.sleep)),
    );
    final p = _painter(tester);
    expect(p.pose, PetPose.sleep);
    expect(p.cuteProgress, -1);
  });

  testWidgets('breathes while animating', (tester) async {
    await tester.pumpWidget(_host(const PetView(petType: 'happy_shiba')));
    final first = _painter(tester).phase;
    await tester.pump(const Duration(milliseconds: 600));
    expect(_painter(tester).phase, isNot(first));
    expect(tester.hasRunningAnimations, isTrue);
  });

  testWidgets('stops when TickerMode is off', (tester) async {
    await tester.pumpWidget(
      _host(
        const TickerMode(
          enabled: false,
          child: PetView(petType: 'happy_shiba'),
        ),
      ),
    );
    await tester.pump();
    expect(tester.binding.hasScheduledFrame, isFalse);
  });
}
