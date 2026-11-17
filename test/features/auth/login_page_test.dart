import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/auth/presentation/login_page.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

void main() {
  late FakeSessionController session;

  setUp(() => session = FakeSessionController(const SessionUnauthenticated()));

  Future<void> pump(
    WidgetTester tester, {
    bool devLoginEnabled = true,
    bool appleEnabled = false,
  }) => pumpLocalized(
    tester,
    LoginPage(devLoginEnabled: devLoginEnabled, appleEnabled: appleEnabled),
    overrides: [sessionControllerProvider.overrideWith(() => session)],
  );

  testWidgets('dev login hidden when DEV_LOGIN false', (tester) async {
    await pump(tester, devLoginEnabled: false);
    expect(find.text(en.login_dev_title), findsNothing);
    expect(find.text(en.login_google), findsOneWidget);
  });

  testWidgets('dev login sends the default email', (tester) async {
    await pump(tester);
    expect(find.text('dev-a@local'), findsOneWidget);
    await tester.tap(find.text(en.login_dev_submit));
    await tester.pumpAndSettle();
    expect(session.calls, ['dev:dev-a@local']);
  });

  testWidgets('apple button shows coming-soon snackbar when disabled', (
    tester,
  ) async {
    await pump(tester);
    await tester.tap(find.text(en.login_apple));
    await tester.pump();
    expect(find.text(en.login_apple_coming_soon), findsOneWidget);
    expect(session.calls, isEmpty);
  });

  testWidgets('PROVIDER_NOT_CONFIGURED shows localized text, not server '
      'message', (tester) async {
    session.loginError = const AppFailure(
      'PROVIDER_NOT_CONFIGURED',
      status: 501,
      details: {'message': 'google verifier not configured'},
    );
    await pump(tester);

    await tester.tap(find.text(en.login_google));
    await tester.pumpAndSettle();

    expect(find.text(en.err_PROVIDER_NOT_CONFIGURED), findsOneWidget);
    expect(find.textContaining('verifier'), findsNothing);
  });
}
