import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/core/network/token_refresher.dart';
import 'package:petbridge/core/realtime/ws_client.dart';
import 'package:petbridge/core/realtime/ws_frame.dart';
import 'package:petbridge/core/realtime/ws_transport.dart';
import 'package:petbridge/core/storage/secure_store.dart';

import '../network/auth_interceptor_test.dart' show FakeSecureStore;
import 'fake_transport.dart';

void main() {
  final now = DateTime.utc(2026, 11, 23, 12);
  final url = Uri.parse('ws://api.test/api/v1/ws');
  String accessExpiringIn(Duration d) =>
      fakeJwt({'exp': now.add(d).millisecondsSinceEpoch ~/ 1000});
  final longAccess = accessExpiringIn(const Duration(hours: 1));

  late FakeTransport transport;
  late int refreshCalls;
  late FakeSecureStore store;
  late int expiredCalls;

  setUp(() {
    transport = FakeTransport();
    refreshCalls = 0;
    expiredCalls = 0;
  });

  WsClient build({
    double random = 0,
    String appVersion = '1.0.0',
    String? access,
  }) => WsClient(
    transport: transport,
    url: url,
    tokens: TokenRefresher(
      store: store = FakeSecureStore(
        TokenPair(access: access ?? longAccess, refresh: 'r-old'),
      ),
      refresh: (_) async {
        refreshCalls++;
        return const TokenPair(access: 'new', refresh: 'r-new');
      },
      onSessionExpired: () => expiredCalls++,
    ),
    clock: () => now,
    appVersion: appVersion,
    random: FixedRandom(random),
  );

  /// Starts [c] and lets the first connection reach `ready`.
  void startReady(FakeAsync async, WsClient c) {
    c.start();
    async.flushMicrotasks();
    transport.last.hello();
    async.flushMicrotasks();
  }

  void finish(FakeAsync async, WsClient c) {
    unawaited(c.stop());
    async.flushMicrotasks();
  }

  test('hello moves connected to ready', () {
    fakeAsync((async) {
      final c = build();
      final states = <WsConnState>[];
      final frames = <WsFrame>[];
      c.states.listen(states.add);
      c.frames.listen(frames.add);

      c.start();
      async.flushMicrotasks();
      expect(c.state, WsConnState.connected);

      transport.last.hello();
      async.flushMicrotasks();

      expect(c.state, WsConnState.ready);
      expect(states, [
        WsConnState.connecting,
        WsConnState.connected,
        WsConnState.ready,
      ]);
      expect(frames, isEmpty);

      transport.last
        ..pushRaw('garbage')
        ..push(const WsFrame('resync'));
      async.flushMicrotasks();
      expect(frames.map((f) => f.t), ['resync']);
      finish(async, c);
    });
  });

  test('sends bearer header', () {
    fakeAsync((async) {
      final c = build()..start();
      async.flushMicrotasks();

      final call = transport.calls.single;
      expect(call.url, url);
      expect(call.headers['Authorization'], 'Bearer $longAccess');
      finish(async, c);
    });
  });

  test('expiring token is refreshed before connect', () {
    fakeAsync((async) {
      final c = build(access: accessExpiringIn(const Duration(seconds: 30)))
        ..start();
      async.flushMicrotasks();

      expect(refreshCalls, 1);
      expect(transport.calls.single.headers['Authorization'], 'Bearer new');
      finish(async, c);
    });
  });

  test('reconnects with backoff after drop', () {
    fakeAsync((async) {
      final c = build();
      startReady(async, c);
      transport.script.add(Exception('no network'));

      transport.last.drop(1006);
      async.flushMicrotasks();
      expect(c.state, WsConnState.disconnected);

      async.elapse(const Duration(milliseconds: 999));
      expect(transport.calls, hasLength(1));
      async.elapse(const Duration(milliseconds: 1));
      expect(transport.calls, hasLength(2));

      async.elapse(const Duration(milliseconds: 1999));
      expect(transport.calls, hasLength(2));
      async.elapse(const Duration(milliseconds: 1));
      expect(transport.calls, hasLength(3));
      expect(c.state, WsConnState.connected);
      finish(async, c);
    });
  });

  test('backoff resets after 60s ready', () {
    fakeAsync((async) {
      final c = build();
      transport.script.addAll([Exception('a'), Exception('b')]);
      c.start();
      async.elapse(const Duration(seconds: 3)); // fail, 1s, fail, 2s, ok
      expect(transport.calls, hasLength(3));
      transport.last.hello();

      async.elapse(const Duration(seconds: 60));
      transport.last.drop();

      async.elapse(const Duration(milliseconds: 999));
      expect(transport.calls, hasLength(3));
      async.elapse(const Duration(milliseconds: 1));
      expect(transport.calls, hasLength(4));
      finish(async, c);
    });
  });

  test('connect that never completes times out and backs off', () {
    fakeAsync((async) {
      final hung = Completer<FakeConnection>();
      transport.script.add(hung);
      final c = build()..start();

      async.elapse(const Duration(milliseconds: 9999));
      expect(c.state, WsConnState.connecting);
      async.elapse(const Duration(milliseconds: 1));
      expect(c.state, WsConnState.disconnected);

      async.elapse(const Duration(seconds: 1)); // backoff attempt 0
      expect(transport.calls, hasLength(2));
      expect(c.state, WsConnState.connected);

      // The late connection is closed unused.
      final late = FakeConnection();
      hung.complete(late);
      async.flushMicrotasks();
      expect(late.closedWith, 1000);
      expect(c.state, WsConnState.connected);
      finish(async, c);
    });
  });

  test('4401 refreshes then reconnects without delay', () {
    fakeAsync((async) {
      final c = build();
      startReady(async, c);

      transport.last.drop(4401);
      async.flushMicrotasks();

      expect(refreshCalls, 1);
      expect(transport.calls, hasLength(2));
      expect(transport.calls.last.headers['Authorization'], 'Bearer new');
      finish(async, c);
    });
  });

  test('4001 halts', () {
    fakeAsync((async) {
      final c = build();
      startReady(async, c);

      transport.last.drop(4001);
      async
        ..flushMicrotasks()
        ..elapse(const Duration(minutes: 5));

      expect(c.halted, isTrue);
      expect(c.state, WsConnState.disconnected);
      expect(transport.calls, hasLength(1));
      finish(async, c);
    });
  });

  test('4001 halt is cleared by resume', () {
    fakeAsync((async) {
      final c = build();
      startReady(async, c);
      transport.last.drop(4001);
      async.flushMicrotasks();
      expect(c.halted, isTrue);

      // Background then foreground: this device wants its socket back.
      c
        ..pause()
        ..resume();
      async.flushMicrotasks();

      expect(c.halted, isFalse);
      expect(transport.calls, hasLength(2));
      expect(c.state, WsConnState.connected);
      transport.last.hello();
      async.flushMicrotasks();
      expect(c.state, WsConnState.ready);
      finish(async, c);
    });
  });

  test('protocol halt is not cleared by resume', () {
    fakeAsync((async) {
      final c = build()..start();
      async.flushMicrotasks();
      transport.last.hello(proto: 2);
      async.flushMicrotasks();
      expect(c.halted, isTrue);

      c
        ..pause()
        ..resume();
      async
        ..flushMicrotasks()
        ..elapse(const Duration(minutes: 5));

      expect(c.halted, isTrue);
      expect(transport.calls, hasLength(1));
      finish(async, c);
    });
  });

  test('4403 halts without reconnect', () {
    fakeAsync((async) {
      final c = build();
      startReady(async, c);

      transport.last.drop(4403);
      async
        ..flushMicrotasks()
        ..elapse(const Duration(minutes: 5));
      c.resume();
      async
        ..flushMicrotasks()
        ..elapse(const Duration(minutes: 5));

      expect(c.halted, isTrue);
      expect(c.state, WsConnState.disconnected);
      expect(transport.calls, hasLength(1));
      finish(async, c);
    });
  });

  test('4403 ends the session like a disabled account', () {
    fakeAsync((async) {
      final c = build();
      startReady(async, c);

      transport.last.drop(4403);
      async.flushMicrotasks();

      expect(store.tokens, isNull);
      expect(store.clears, 1);
      expect(expiredCalls, 1);
      expect(refreshCalls, 0);
      finish(async, c);
    });
  });

  test('upgrade 403 halts', () {
    fakeAsync((async) {
      final c = build();
      transport.script.add(
        const WsUpgradeException(403, code: 'ONBOARDING_REQUIRED'),
      );
      c.start();
      async.elapse(const Duration(minutes: 5));

      expect(c.halted, isTrue);
      expect(transport.calls, hasLength(1));

      // Only stop() then start() connects again.
      c.resume();
      async.flushMicrotasks();
      expect(transport.calls, hasLength(1));
      unawaited(c.stop());
      async.flushMicrotasks();
      expect(c.halted, isFalse);
      c.start();
      async.flushMicrotasks();
      expect(transport.calls, hasLength(2));
      finish(async, c);
    });
  });

  test('upgrade 401 refreshes once then retries', () {
    fakeAsync((async) {
      final c = build();
      transport.script.addAll([
        const WsUpgradeException(401, code: 'UNAUTHORIZED'),
        const WsUpgradeException(401, code: 'UNAUTHORIZED'),
      ]);
      c.start();
      async.flushMicrotasks();

      // First 401: one refresh, then an immediate retry with the new token.
      expect(refreshCalls, 1);
      expect(transport.calls, hasLength(2));
      expect(transport.calls[1].headers['Authorization'], 'Bearer new');

      // Second 401 in a row: plain backoff, no second refresh.
      async.elapse(const Duration(milliseconds: 999));
      expect(transport.calls, hasLength(2));
      async.elapse(const Duration(milliseconds: 1));
      expect(transport.calls, hasLength(3));
      expect(refreshCalls, 1);
      expect(c.state, WsConnState.connected);
      finish(async, c);
    });
  });

  test('server.restart waits 1 to 10 s', () {
    fakeAsync((async) {
      final c = build(random: 0.5); // 1s + 0.5 * 9s = 5.5s
      final frames = <WsFrame>[];
      c.frames.listen(frames.add);
      startReady(async, c);

      transport.last
        ..push(const WsFrame('server.restart'))
        ..drop(1001);
      async.flushMicrotasks();
      expect(frames.map((f) => f.t), ['server.restart']);

      async.elapse(const Duration(milliseconds: 5499));
      expect(transport.calls, hasLength(1));
      async.elapse(const Duration(milliseconds: 1));
      expect(transport.calls, hasLength(2));
      finish(async, c);
    });
  });

  test('upgrade 503 waits 1 to 10 s', () {
    fakeAsync((async) {
      final c = build(random: 0.5);
      transport.script.add(const WsUpgradeException(503, code: 'NOT_READY'));
      c.start();

      async.elapse(const Duration(milliseconds: 5499));
      expect(transport.calls, hasLength(1));
      async.elapse(const Duration(milliseconds: 1));
      expect(transport.calls, hasLength(2));
      finish(async, c);
    });
  });

  test('upgrade 429 waits Retry-After', () {
    fakeAsync((async) {
      final c = build(random: 0.5);
      transport.script.add(
        const WsUpgradeException(
          429,
          retryAfter: Duration(seconds: 7),
          code: 'RATE_LIMITED',
        ),
      );
      c.start();

      async.elapse(const Duration(milliseconds: 6999));
      expect(transport.calls, hasLength(1));
      async.elapse(const Duration(milliseconds: 1));
      expect(transport.calls, hasLength(2));
      finish(async, c);
    });
  });

  test('pause closes and stays closed', () {
    fakeAsync((async) {
      final c = build();
      startReady(async, c);
      final conn = transport.last;

      c.pause();
      async
        ..flushMicrotasks()
        ..elapse(const Duration(minutes: 5));

      expect(conn.closedWith, 1000);
      expect(c.state, WsConnState.disconnected);
      expect(c.halted, isFalse);
      expect(transport.calls, hasLength(1));
      finish(async, c);
    });
  });

  test('resume reconnects at once', () {
    fakeAsync((async) {
      final c = build();
      transport.script.addAll([Exception('a'), Exception('b')]);
      c.start();
      async.elapse(const Duration(seconds: 1)); // fail, 1s, fail: next is 2s
      expect(transport.calls, hasLength(2));

      c
        ..pause()
        ..resume();
      async.flushMicrotasks();
      expect(transport.calls, hasLength(3));
      expect(c.state, WsConnState.connected);

      // Backoff was cleared: the next failure waits 1s again.
      transport.script.add(Exception('c'));
      transport.last.drop();
      async.elapse(const Duration(milliseconds: 999));
      expect(transport.calls, hasLength(3));
      async.elapse(const Duration(milliseconds: 1));
      expect(transport.calls, hasLength(4));
      finish(async, c);
    });
  });

  test('proto 2 halts', () {
    fakeAsync((async) {
      final c = build()..start();
      async.flushMicrotasks();
      final conn = transport.last..hello(proto: 2);
      async
        ..flushMicrotasks()
        ..elapse(const Duration(minutes: 5));

      expect(c.halted, isTrue);
      expect(c.state, WsConnState.disconnected);
      expect(conn.closedWith, 1000);
      expect(transport.calls, hasLength(1));
      finish(async, c);
    });
  });

  test('min_app_version above current halts', () {
    fakeAsync((async) {
      final c = build(appVersion: '1.9.0')..start();
      async.flushMicrotasks();
      transport.last.hello(minAppVersion: '1.10.0');
      async
        ..flushMicrotasks()
        ..elapse(const Duration(minutes: 5));

      expect(c.halted, isTrue);
      expect(transport.calls, hasLength(1));
      finish(async, c);
    });
  });

  test('send returns null unless ready', () {
    fakeAsync((async) {
      final c = build();
      expect(c.send('room.sub', {'room_id': 'r1'}), isNull);

      c.start();
      async.flushMicrotasks();
      expect(c.state, WsConnState.connected);
      expect(c.send('room.sub', {'room_id': 'r1'}), isNull);

      transport.last.hello();
      async.flushMicrotasks();
      expect(c.send('room.sub', {'room_id': 'r1'}), 'c1');
      expect(c.send('room.unsub', {'room_id': 'r1'}), 'c2');

      final sent = transport.last.sent.map(WsFrame.decode).toList();
      expect(sent.map((f) => f.t), ['room.sub', 'room.unsub']);
      expect(sent.map((f) => f.id), ['c1', 'c2']);
      expect(sent.first.d, {'room_id': 'r1'});
      finish(async, c);
    });
  });

  test('dispose closes the socket and ends the streams', () {
    fakeAsync((async) {
      final c = build();
      var statesDone = false;
      var framesDone = false;
      c.states.listen(null, onDone: () => statesDone = true);
      c.frames.listen(null, onDone: () => framesDone = true);
      startReady(async, c);

      unawaited(c.dispose());
      async.flushMicrotasks();

      expect(transport.last.closedWith, 1000);
      expect(c.state, WsConnState.disconnected);
      expect(statesDone, isTrue);
      expect(framesDone, isTrue);

      c.start();
      async.flushMicrotasks();
      expect(transport.calls, hasLength(1));
    });
  });

  test('dispose closes the transport', () {
    fakeAsync((async) {
      final c = build();
      startReady(async, c);
      expect(transport.closed, 0);

      unawaited(c.dispose());
      async.flushMicrotasks();

      expect(transport.closed, 1);
    });
  });
}
