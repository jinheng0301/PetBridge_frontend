import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show ProviderFamily;
import 'package:petbridge/features/room/application/realtime_coordinator.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/application/room_live.dart';
import 'package:petbridge/features/room/application/rooms_provider.dart';

/// What the room scene draws: the live state once its snapshot arrived,
/// before that the REST room list with presence unknown (drawn awake, so
/// nobody is shown asleep and then waking up).
class RoomView {
  const new({
    required this.roomId,
    required this.isOwner,
    required this.memberCount,
    required this.capacity,
    required this.members,
  });

  final String roomId;
  final bool isOwner;
  final int memberCount;
  final int capacity;

  /// Sorted by seat.
  final List<LiveMember> members;
}

/// `null` while the room is neither live nor listed.
final ProviderFamily<RoomView?, String> roomViewProvider = Provider.family(
  _roomView,
);

RoomView? _roomView(Ref ref, String roomId) {
  final live = ref.watch(roomLiveProvider(roomId));
  if (live != null) {
    return RoomView(
      roomId: roomId,
      isOwner: live.isOwner,
      memberCount: live.memberCount,
      capacity: live.capacity,
      members: live.members,
    );
  }
  final rooms = ref.watch(roomsProvider).value ?? const <Room>[];
  final room = rooms.where((r) => r.id == roomId).firstOrNull;
  if (room == null) return null;
  return RoomView(
    roomId: roomId,
    isOwner: room.isOwner,
    memberCount: room.memberCount,
    capacity: room.capacity,
    members: [
      for (final m in room.members)
        LiveMember(
          userId: m.userId,
          nickname: m.nickname,
          petType: m.petType,
          seatNo: m.seatNo,
          role: m.role,
          presence: Presence.unknown,
        ),
    ],
  );
}
