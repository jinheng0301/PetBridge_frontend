import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/core/network/dio_client.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/gen/pet_bridge_api.dart';

abstract interface class RoomRepository {
  /// `GET /rooms/mine`: own room first. Throws [AppFailure].
  Future<List<Room>> listMine();
}

class ApiRoomRepository implements RoomRepository {
  new(this._api);

  final PetBridgeApi _api;

  @override
  Future<List<Room>> listMine() async {
    try {
      final res = await _api.rooms.listMyRooms();
      return [for (final r in res.data) _room(r)];
    } on Object catch (e) {
      throw AppFailure.from(e);
    }
  }

  static Room _room(RoomDetail r) => Room(
    id: r.id,
    isOwner: r.isOwner,
    status: RoomStatus.values.byName(r.status.value as String),
    memberCount: r.memberCount,
    capacity: r.capacity,
    members: membersFrom(r.members),
    regenRemainingToday: r.regenRemainingToday,
  );
}

/// Domain members sorted by seat. Shared with the invite feature's join.
List<RoomMember> membersFrom(List<MemberInfo> members) => [
  for (final m in members)
    RoomMember(
      userId: m.userId,
      nickname: m.nickname,
      petType: m.petType,
      seatNo: m.seatNo,
      role: m.role == MemberInfoRole.owner ? RoomRole.owner : RoomRole.member,
    ),
]..sort((a, b) => a.seatNo.compareTo(b.seatNo));

final roomRepositoryProvider = Provider<RoomRepository>(
  (ref) => ApiRoomRepository(PetBridgeApi(ref.watch(dioProvider))),
);
