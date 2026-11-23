import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/core/network/interceptors/error_map_interceptor.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/data/room_repository.dart';
import 'package:petbridge/gen/pet_bridge_api.dart';

import '../../core/network/fake_adapter.dart';

ApiRoomRepository _repo(FakeAdapter adapter) => ApiRoomRepository(
  PetBridgeApi(
    Dio(BaseOptions(baseUrl: 'http://test'))
      ..httpClientAdapter = adapter
      ..interceptors.add(ErrorMapInterceptor()),
  ),
);

Map<String, Object?> _member(
  String id,
  int seat, {
  String role = 'member',
  String? nickname = 'n',
  String? petType = 'happy_shiba',
}) => {
  'user_id': id,
  'nickname': nickname,
  'pet_type': petType,
  'seat_no': seat,
  'role': role,
};

void main() {
  test('listMine maps rooms and sorts members by seat', () async {
    final adapter = FakeAdapter(
      (_) async => jsonBody(200, {
        'data': [
          {
            'id': 'r1',
            'is_owner': false,
            'status': 'open',
            'member_count': 3,
            'capacity': 5,
            'regen_remaining_today': null,
            'members': [
              _member('u3', 3),
              _member('u1', 1, role: 'owner', nickname: 'Hikari'),
              _member('u2', 2),
            ],
          },
        ],
      }),
    );

    final rooms = await _repo(adapter).listMine();

    expect(adapter.seen.single.uri.path, '/api/v1/rooms/mine');
    final r = rooms.single;
    expect(r.id, 'r1');
    expect(r.isOwner, isFalse);
    expect(r.status, RoomStatus.open);
    expect(r.memberCount, 3);
    expect(r.capacity, 5);
    expect(r.freeSeats, 2);
    expect(r.members.map((m) => m.seatNo), [1, 2, 3]);
    expect(r.owner?.nickname, 'Hikari');
    expect(r.owner?.role, RoomRole.owner);
    expect(r.regenRemainingToday, isNull);
  });

  test('listMine tolerates null nickname and pet_type', () async {
    final adapter = FakeAdapter(
      (_) async => jsonBody(200, {
        'data': [
          {
            'id': 'r1',
            'is_owner': true,
            'status': 'full',
            'member_count': 1,
            'capacity': 1,
            'regen_remaining_today': 0,
            'members': [
              _member('u1', 1, role: 'owner', nickname: null, petType: null),
            ],
          },
        ],
      }),
    );

    final m = (await _repo(adapter).listMine()).single.members.single;

    expect(m.nickname, isNull);
    expect(m.petType, isNull);
  });

  test('listMine maps regen_remaining_today', () async {
    final adapter = FakeAdapter(
      (_) async => jsonBody(200, {
        'data': [
          {
            'id': 'own',
            'is_owner': true,
            'status': 'open',
            'member_count': 1,
            'capacity': 5,
            'regen_remaining_today': 2,
            'members': [_member('u1', 1, role: 'owner')],
          },
          {
            'id': 'other',
            'is_owner': false,
            'status': 'open',
            'member_count': 2,
            'capacity': 5,
            'regen_remaining_today': null,
            'members': [_member('u9', 1, role: 'owner'), _member('u1', 2)],
          },
        ],
      }),
    );

    final rooms = await _repo(adapter).listMine();

    expect(rooms.map((r) => r.regenRemainingToday), [2, null]);
  });

  group('admin actions', () {
    Map<String, Object?> result() => {
      'data': {
        'room': {
          'id': 'r1',
          'status': 'open',
          'member_count': 1,
          'capacity': 5,
        },
      },
    };

    test('removeMember hits DELETE members/{user}', () async {
      final adapter = FakeAdapter((_) async => jsonBody(200, result()));

      await _repo(adapter).removeMember('r1', 'u2');

      expect(adapter.seen.single.method, 'DELETE');
      expect(adapter.seen.single.uri.path, '/api/v1/rooms/r1/members/u2');
    });

    test('dissolve hits POST dissolve', () async {
      final adapter = FakeAdapter((_) async => jsonBody(200, result()));

      await _repo(adapter).dissolve('r1');

      expect(adapter.seen.single.method, 'POST');
      expect(adapter.seen.single.uri.path, '/api/v1/rooms/r1/dissolve');
    });

    test('leave hits POST leave', () async {
      final adapter = FakeAdapter(
        (_) async => ResponseBody.fromString('', 204),
      );

      await _repo(adapter).leave('r1');

      expect(adapter.seen.single.method, 'POST');
      expect(adapter.seen.single.uri.path, '/api/v1/rooms/r1/leave');
    });

    test('errors become AppFailure', () async {
      final adapter = FakeAdapter(
        (_) async => jsonBody(409, {
          'error': {
            'code': 'OWNER_CANNOT_LEAVE',
            'message': 'x',
            'request_id': 'r',
          },
        }),
      );

      await expectLater(
        _repo(adapter).leave('r1'),
        throwsA(
          isA<AppFailure>()
              .having((f) => f.code, 'code', 'OWNER_CANNOT_LEAVE')
              .having((f) => f.status, 'status', 409),
        ),
      );
    });
  });
}
