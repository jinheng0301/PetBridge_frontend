import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/core/network/interceptors/error_map_interceptor.dart';
import 'package:petbridge/features/invite/application/codes.dart';
import 'package:petbridge/features/invite/data/invite_repository.dart';
import 'package:petbridge/gen/pet_bridge_api.dart';

import '../../core/network/fake_adapter.dart';

ApiInviteRepository _repo(FakeAdapter adapter) => ApiInviteRepository(
  PetBridgeApi(
    Dio(BaseOptions(baseUrl: 'http://test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(ErrorMapInterceptor()),
  ),
);

Map<String, Object?> _join(List<Map<String, Object?>> rewards) => {
  'data': {
    'room': {'id': 'r9', 'status': 'open', 'member_count': 2, 'capacity': 5},
    'seat_no': 2,
    'members': [
      {
        'user_id': 'u2',
        'nickname': 'Me',
        'pet_type': 'thinker_owl',
        'seat_no': 2,
        'role': 'member',
      },
      {
        'user_id': 'u1',
        'nickname': 'Hikari',
        'pet_type': 'happy_shiba',
        'seat_no': 1,
        'role': 'owner',
      },
    ],
    'rewards': rewards,
  },
};

Map<String, Object?> _bodyOf(RequestOptions o) {
  final d = o.data;
  final json = d is String ? jsonDecode(d) : jsonDecode(jsonEncode(d));
  return (json as Map).cast<String, Object?>();
}

void main() {
  test('join maps rewards and members', () async {
    final adapter = FakeAdapter(
      (_) async => jsonBody(
        200,
        _join([
          {'code': 'P9WD2HKR', 'expires_at': '2026-11-28T12:00:00Z'},
        ]),
      ),
    );

    final out = await _repo(adapter).join('ABCD2345');

    expect(out.roomId, 'r9');
    expect(out.memberCount, 2);
    expect(out.capacity, 5);
    expect(out.members.map((m) => m.seatNo), [1, 2]);
    expect(out.owner?.nickname, 'Hikari');
    expect(out.rewards.single.code, 'P9WD2HKR');
    expect(out.rewards.single.expiresAt, DateTime.utc(2026, 11, 28, 12));
  });

  test('join with empty rewards gives empty list', () async {
    final adapter = FakeAdapter((_) async => jsonBody(200, _join([])));

    expect((await _repo(adapter).join('ABCD2345')).rewards, isEmpty);
  });

  test('join sends the code as typed', () async {
    final adapter = FakeAdapter((_) async => jsonBody(200, _join([])));

    await _repo(adapter).join('abcd-2345');

    final sent = adapter.seen.single;
    expect(sent.uri.path, '/api/v1/rooms/join');
    expect(_bodyOf(sent)['code'], 'abcd-2345');
  });

  test('listCodes maps void to voided', () async {
    final adapter = FakeAdapter(
      (_) async => jsonBody(200, {
        'data': [
          for (final s in ['unused', 'used', 'expired', 'void'])
            {
              'code': 'ABCD2345',
              'source': 'signup',
              'status': s,
              'expires_at': '2026-11-28T12:00:00Z',
              'room': {'id': 'r1', 'member_count': 3, 'capacity': 5},
            },
        ],
      }),
    );

    final codes = await _repo(adapter).listCodes();

    expect(adapter.seen.single.uri.path, '/api/v1/codes');
    expect(codes.map((c) => c.status), [
      CodeStatus.unused,
      CodeStatus.used,
      CodeStatus.expired,
      CodeStatus.voided,
    ]);
    expect(codes.first.roomId, 'r1');
    expect(codes.first.roomMemberCount, 3);
    expect(codes.first.roomCapacity, 5);
  });

  test('regen returns the issued code', () async {
    final adapter = FakeAdapter(
      (_) async => jsonBody(201, {
        'data': {'code': 'NEWC2345', 'expires_at': '2026-11-28T12:00:00Z'},
      }),
    );

    final c = await _repo(adapter).regen('r1');

    expect(adapter.seen.single.uri.path, '/api/v1/rooms/r1/codes');
    expect(c.code, 'NEWC2345');
  });

  test('409 ROOM_FULL surfaces as AppFailure', () async {
    final adapter = FakeAdapter(
      (_) async => jsonBody(409, {
        'error': {'code': 'ROOM_FULL', 'message': 'x', 'request_id': 'r'},
      }),
    );

    await expectLater(
      _repo(adapter).join('ABCD2345'),
      throwsA(
        isA<AppFailure>()
            .having((f) => f.code, 'code', 'ROOM_FULL')
            .having((f) => f.status, 'status', 409),
      ),
    );
  });
}
