import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/core/network/token_refresher.dart';
import 'package:petbridge/core/storage/secure_store.dart';

import 'auth_interceptor_test.dart' show FakeSecureStore;

String _jwt(Map<String, Object?> payload) {
  String enc(Object o) =>
      base64Url.encode(utf8.encode(jsonEncode(o))).replaceAll('=', '');
  return '${enc({'alg': 'none'})}.${enc(payload)}.sig';
}

void main() {
  group('jwtExpiry', () {
    test('jwtExpiry reads exp', () {
      expect(
        jwtExpiry(_jwt({'exp': 1800000000})),
        DateTime.fromMillisecondsSinceEpoch(1800000000 * 1000, isUtc: true),
      );
    });

    test('jwtExpiry returns null for garbage', () {
      expect(jwtExpiry('not-a-jwt'), isNull);
      expect(jwtExpiry('a.b.c'), isNull);
      expect(jwtExpiry(_jwt({'sub': 'x'})), isNull);
    });
  });

  group('TokenRefresher', () {
    final now = DateTime.utc(2026, 11, 23, 12);
    late FakeSecureStore store;
    late int refreshCalls;

    TokenRefresher build() => TokenRefresher(
      store: store,
      refresh: (_) async {
        refreshCalls++;
        await Future<void>.delayed(const Duration(milliseconds: 10));
        return const TokenPair(access: 'new', refresh: 'r-new');
      },
      onSessionExpired: () {},
    );

    TokenPair pairExpiringIn(int seconds) => TokenPair(
      access: _jwt({
        'exp':
            now.add(Duration(seconds: seconds)).millisecondsSinceEpoch ~/ 1000,
      }),
      refresh: 'r-old',
    );

    setUp(() => refreshCalls = 0);

    test('validAccess refreshes when under 60s left', () async {
      store = FakeSecureStore(pairExpiringIn(59));

      expect(await build().validAccess(now), 'new');
      expect(refreshCalls, 1);
    });

    test('validAccess keeps token with 61s left', () async {
      final pair = pairExpiringIn(61);
      store = FakeSecureStore(pair);

      expect(await build().validAccess(now), pair.access);
      expect(refreshCalls, 0);
    });

    test('validAccess returns null without tokens', () async {
      store = FakeSecureStore(null);

      expect(await build().validAccess(now), isNull);
    });

    test('concurrent fresh calls share one refresh', () async {
      store = FakeSecureStore(const TokenPair(access: 'old', refresh: 'r-old'));
      final r = build();

      final results = await Future.wait([r.fresh(), r.fresh()]);

      expect(refreshCalls, 1);
      expect(results.map((t) => t.access), ['new', 'new']);
    });
  });
}
