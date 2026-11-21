import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/core/network/dio_client.dart';
import 'package:petbridge/features/invite/application/codes.dart';
import 'package:petbridge/features/room/data/room_repository.dart';
import 'package:petbridge/gen/pet_bridge_api.dart';

/// Joining with a code, the backpack list and owner regeneration. Every
/// method throws [AppFailure] only.
abstract interface class InviteRepository {
  /// `POST /rooms/join`. [code] is sent as typed; the server normalizes it.
  Future<JoinOutcome> join(String code);

  /// `GET /codes`, newest first.
  Future<List<InviteCode>> listCodes();

  /// `POST /rooms/{roomId}/codes` (owner only).
  Future<IssuedCode> regen(String roomId);
}

class ApiInviteRepository implements InviteRepository {
  new(this._api);

  final PetBridgeApi _api;

  @override
  Future<JoinOutcome> join(String code) => _guard(() async {
    final r = (await _api.rooms.joinRoom(body: JoinRequest(code: code))).data;
    return JoinOutcome(
      roomId: r.room.id,
      memberCount: r.room.memberCount,
      capacity: r.room.capacity,
      members: membersFrom(r.members),
      rewards: [for (final c in r.rewards) _issued(c)],
    );
  });

  @override
  Future<List<InviteCode>> listCodes() => _guard(() async {
    final res = await _api.codes.listCodes();
    return [
      for (final c in res.data)
        InviteCode(
          code: c.code,
          status: switch (c.status) {
            CodeListItemStatus.unused => CodeStatus.unused,
            CodeListItemStatus.used => CodeStatus.used,
            CodeListItemStatus.expired => CodeStatus.expired,
            CodeListItemStatus.void2 => CodeStatus.voided,
          },
          expiresAt: c.expiresAt,
          roomId: c.room.id,
          roomMemberCount: c.room.memberCount,
          roomCapacity: c.room.capacity,
        ),
    ];
  });

  @override
  Future<IssuedCode> regen(String roomId) => _guard(
    () async => _issued((await _api.rooms.regenCode(id: roomId)).data),
  );

  static IssuedCode _issued(CodeInfo c) =>
      IssuedCode(code: c.code, expiresAt: c.expiresAt);
}

Future<T> _guard<T>(Future<T> Function() call) async {
  try {
    return await call();
  } on Object catch (e) {
    throw AppFailure.from(e);
  }
}

final inviteRepositoryProvider = Provider<InviteRepository>(
  (ref) => ApiInviteRepository(PetBridgeApi(ref.watch(dioProvider))),
);
