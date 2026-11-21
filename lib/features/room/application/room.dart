/// Room domain objects. Built from the generated API models in `data/`;
/// the rest of the app only sees these.
library;

enum RoomStatus { open, full, closed }

enum RoomRole { owner, member }

class RoomMember {
  const new({
    required this.userId,
    required this.seatNo,
    required this.role,
    this.nickname,
    this.petType,
  });

  final String userId;
  final String? nickname;
  final String? petType;
  final int seatNo;
  final RoomRole role;
}

/// The owner among [members], if listed.
RoomMember? ownerOf(List<RoomMember> members) {
  for (final m in members) {
    if (m.role == RoomRole.owner) return m;
  }
  return null;
}

/// A room the user is seated in (`GET /rooms/mine`).
class Room {
  const new({
    required this.id,
    required this.isOwner,
    required this.status,
    required this.memberCount,
    required this.capacity,
    required this.members,
    this.regenRemainingToday,
  });

  final String id;

  /// True for the user's own room.
  final bool isOwner;
  final RoomStatus status;
  final int memberCount;
  final int capacity;

  /// Sorted by seat.
  final List<RoomMember> members;

  /// How many more codes the owner may issue today; `null` for rooms the
  /// user does not own, or while the server does not send it yet.
  final int? regenRemainingToday;

  RoomMember? get owner => ownerOf(members);

  int get freeSeats => capacity - memberCount;
}
