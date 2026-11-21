import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:petbridge/app/app.dart';
import 'package:petbridge/app/router/routes.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/invite/application/codes.dart';
import 'package:petbridge/features/invite/data/invite_repository.dart';
import 'package:petbridge/features/invite/data/poster_sink.dart';
import 'package:petbridge/features/invite/presentation/share_page.dart';
import 'package:petbridge/features/invite/presentation/widgets/poster_canvas.dart';
import 'package:petbridge/features/room/data/room_repository.dart';

import '../../helpers/fakes.dart';
import '../../helpers/pump_app.dart';

const me = Me(id: 'u1', onboarded: true, petType: 'happy_shiba');

InviteCode code(String c, CodeStatus status) => InviteCode(
  code: c,
  status: status,
  expiresAt: DateTime.utc(2099),
  roomId: 'own',
  roomMemberCount: 3,
  roomCapacity: 5,
);

void main() {
  late MockInviteRepository invites;
  late MockRoomRepository rooms;
  late MockPosterSink sink;

  setUpAll(() => registerFallbackValue(Uint8List(0)));

  setUp(() {
    invites = MockInviteRepository();
    rooms = MockRoomRepository();
    sink = MockPosterSink();
    when(() => rooms.listMine()).thenAnswer((_) async => []);
    when(() => invites.listCodes()).thenAnswer(
      (_) async => [
        code('ABCD2345', CodeStatus.unused),
        code('USED2345', CodeStatus.used),
      ],
    );
  });

  Future<void> pump(WidgetTester tester, String param) async {
    final router = GoRouter(
      initialLocation: Routes.sharePath(param),
      routes: [
        GoRoute(
          path: '${Routes.share}/:code',
          builder: (_, s) => SharePage(code: s.pathParameters['code']!),
        ),
      ],
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sessionControllerProvider.overrideWith(
            () => FakeSessionController(const SessionReady(me)),
          ),
          roomRepositoryProvider.overrideWithValue(rooms),
          inviteRepositoryProvider.overrideWithValue(invites),
          posterSinkProvider.overrideWithValue(sink),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: appLocalizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    );
  }

  /// Taps [label] and lets the real image capture finish.
  Future<void> tapAndCapture(WidgetTester tester, String label) async {
    await tester.tap(find.text(label));
    // The capture waits for a frame (pump) and encodes in real time
    // (runAsync); alternate the two until it is done.
    for (var i = 0; i < 10; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 30)),
      );
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  testWidgets('share page waits for codes before deciding', (tester) async {
    final gate = Completer<List<InviteCode>>();
    when(() => invites.listCodes()).thenAnswer((_) => gate.future);
    await pump(tester, 'ABCD2345');
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text(en.share_unavailable), findsNothing);

    gate.complete([code('ABCD2345', CodeStatus.unused)]);
    await tester.pumpAndSettle();
    expect(find.byType(PosterCanvas), findsOneWidget);
  });

  testWidgets('unknown or used code shows not shareable', (tester) async {
    for (final c in ['ZZZZ2345', 'USED2345']) {
      await pump(tester, c);
      await tester.pumpAndSettle();
      expect(find.text(en.share_unavailable), findsOneWidget, reason: c);
      expect(find.byType(PosterCanvas), findsNothing, reason: c);
    }
  });

  testWidgets('invalid code param shows not shareable', (tester) async {
    await pump(tester, 'abcd2345');
    await tester.pumpAndSettle();
    expect(find.text(en.share_unavailable), findsOneWidget);
  });

  testWidgets('poster shows code and room size', (tester) async {
    await pump(tester, 'ABCD2345');
    await tester.pumpAndSettle();

    expect(find.text('ABCD-2345'), findsOneWidget);
    expect(find.text(en.share_room_count(3, 5)), findsOneWidget);
    expect(find.text(en.share_headline), findsOneWidget);
  });

  testWidgets('share passes png and text with link', (tester) async {
    when(() => sink.share(any(), any())).thenAnswer((_) async {});
    await pump(tester, 'ABCD2345');
    await tester.pumpAndSettle();

    await tapAndCapture(tester, en.share_system);

    final captured = verify(() => sink.share(captureAny(), captureAny()))
        .captured;
    expect(captured, hasLength(2));
    final png = captured[0] as Uint8List;
    final text = captured[1] as String;
    expect(png.sublist(1, 4), 'PNG'.codeUnits);
    expect(text, contains('ABCD-2345'));
    expect(text, contains('https://petbridge.example.com/j/ABCD2345'));
  });

  testWidgets('save shows saved snackbar', (tester) async {
    when(() => sink.saveToGallery(any()))
        .thenAnswer((_) async => SaveResult.saved);
    await pump(tester, 'ABCD2345');
    await tester.pumpAndSettle();

    await tapAndCapture(tester, en.share_save);

    expect(find.text(en.share_saved), findsOneWidget);
  });

  testWidgets('save denied shows permission text', (tester) async {
    when(() => sink.saveToGallery(any()))
        .thenAnswer((_) async => SaveResult.denied);
    await pump(tester, 'ABCD2345');
    await tester.pumpAndSettle();

    await tapAndCapture(tester, en.share_save);

    expect(find.text(en.share_denied), findsOneWidget);
  });

  testWidgets('save error shows failure text', (tester) async {
    when(() => sink.saveToGallery(any())).thenThrow(Exception('disk'));
    await pump(tester, 'ABCD2345');
    await tester.pumpAndSettle();

    await tapAndCapture(tester, en.share_save);

    expect(find.text(en.share_failed), findsOneWidget);
  });

  testWidgets('load failure shows error and retry, not unavailable', (
    tester,
  ) async {
    var calls = 0;
    when(() => invites.listCodes()).thenAnswer((_) async {
      if (calls++ == 0) throw const AppFailure(AppFailure.network);
      return [code('ABCD2345', CodeStatus.unused)];
    });
    await pump(tester, 'ABCD2345');
    await tester.pumpAndSettle();

    expect(find.text(en.err_NETWORK), findsOneWidget);
    expect(find.text(en.share_unavailable), findsNothing);

    await tester.tap(find.text(en.common_retry));
    await tester.pumpAndSettle();
    expect(find.byType(PosterCanvas), findsOneWidget);
  });
}
