import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/features/pet/presentation/pet_view.dart';

Widget _host(Widget child) => MaterialApp(
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: Center(child: child)),
);

Color _circleColor(WidgetTester tester) {
  final box = tester.widget<Container>(
    find.descendant(of: find.byType(PetView), matching: find.byType(Container)),
  );
  return (box.decoration! as BoxDecoration).color!;
}

void main() {
  testWidgets('shows the localized pet name', (tester) async {
    await tester.pumpWidget(_host(const PetView(petType: 'happy_shiba')));
    expect(find.text('Happy Shiba'), findsOneWidget);
  });

  testWidgets('color is stable per type and differs between types', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const PetView(petType: 'happy_shiba')));
    final shiba1 = _circleColor(tester);
    await tester.pumpWidget(_host(const PetView(petType: 'thinker_owl')));
    final owl = _circleColor(tester);
    await tester.pumpWidget(_host(const PetView(petType: 'happy_shiba')));
    final shiba2 = _circleColor(tester);

    expect(shiba1, shiba2);
    expect(shiba1, isNot(owl));
  });

  testWidgets('uses the requested size', (tester) async {
    await tester.pumpWidget(
      _host(const PetView(petType: 'clever_fox', size: 96)),
    );
    expect(tester.getSize(find.byType(PetView)), const Size(96, 96));
  });
}
