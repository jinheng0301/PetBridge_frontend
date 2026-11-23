import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/app/app.dart';
import 'package:petbridge/core/storage/prefs_store.dart';
import 'package:petbridge/core/storage/secure_store.dart';
import 'package:petbridge/features/auth/presentation/login_page.dart';
import 'package:petbridge/features/room/application/realtime_coordinator.dart';

import '../helpers/fakes.dart';

void main() {
  testWidgets('app boots with en locale and lands on login without tokens', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          secureStoreProvider.overrideWithValue(MemorySecureStore()),
          prefsStoreProvider.overrideWithValue(stubPrefs()),
          // No real socket in widget tests.
          wsClientProvider.overrideWithValue(null),
        ],
        child: const PetBridgeApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginPage), findsOneWidget);
    expect(find.text('PetBridge'), findsWidgets);
  });
}
