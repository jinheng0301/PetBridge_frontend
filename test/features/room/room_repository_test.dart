import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
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
}
