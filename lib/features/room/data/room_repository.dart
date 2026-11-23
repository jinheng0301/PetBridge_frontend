import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/core/network/dio_client.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/gen/pet_bridge_api.dart';

abstract interface class RoomRepository {
  /// `GET /rooms/mine`: own room first. Throws [AppFailure].
  Future<List<Room>> listMine();

  /// `DELETE /rooms/{id}/members/{user}`: owner only. Throws [AppFailure].
  Future<void> removeMember(String roomId, String userId);

  /// `POST /rooms/{id}/dissolve`: owner only. Throws [AppFailure].
  Future<void> dissolve(String roomId);

  /// `POST /rooms/{id}/leave`: members only. Throws [AppFailure].
  Future<void> leave(String roomId);
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

  @override
  Future<void> removeMember(String roomId, String userId) async {
    try {
      await _api.rooms.removeMember(id: roomId, userId: userId);
    } on Object catch (e) {
      throw AppFailure.from(e);
    }
  }

  @override
  Future<void> dissolve(String roomId) async {
    try {
      await _api.rooms.dissolveRoom(id: roomId);
    } on Object catch (e) {
      throw AppFailure.from(e);
    }
  }

  @override
  Future<void> leave(String roomId) async {
    try {
      await _api.rooms.leaveRoom(id: roomId);
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
