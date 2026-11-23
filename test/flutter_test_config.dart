import 'dart:async';

import 'package:petbridge/features/pet/presentation/pet_view.dart';

/// Runs before every test file. Pets breathe forever, which would make every
/// `pumpAndSettle` on a screen with a pet time out, so they paint a still
/// frame in tests. `test/features/pet/pet_view_test.dart` turns it back on.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  debugPetViewAnimations = false;
  await testMain();
}
