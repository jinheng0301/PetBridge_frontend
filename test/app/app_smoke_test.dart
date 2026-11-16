import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/app/app.dart';

void main() {
  testWidgets('app boots with en locale', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PetBridgeApp()));
    await tester.pumpAndSettle();

    expect(find.text('PetBridge'), findsWidgets);
  });
}
