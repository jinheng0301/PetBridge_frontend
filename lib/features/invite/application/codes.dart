/// Invite code domain objects, built from the generated models in `data/`.
library;

import 'package:petbridge/features/room/application/room.dart';

/// Effective status; the server already reports an unused code past its
/// expiry as expired. `voided` is the server's `void` (room filled or
/// dissolved).
enum CodeStatus { unused, used, expired, voided }

/// A code in the backpack (`GET /codes`). Every code belongs to the user's
/// own room; [roomMemberCount] is that room's current size.
class InviteCode {
  const new({
    required this.code,
    required this.status,
    required this.expiresAt,
    required this.roomId,
    required this.roomMemberCount,
    required this.roomCapacity,
  });

  /// 8 characters, no hyphen.
  final String code;
  final CodeStatus status;
  final DateTime expiresAt;
  final String roomId;
  final int roomMemberCount;
  final int roomCapacity;
}

/// A freshly issued code (join reward or owner regeneration).
class IssuedCode {
  const new({required this.code, required this.expiresAt});

  final String code;
  final DateTime expiresAt;
}

/// The result of `POST /rooms/join`.
class JoinOutcome {
  const new({
    required this.roomId,
    required this.memberCount,
    required this.capacity,
    required this.members,
    required this.rewards,
  });

  final String roomId;
  final int memberCount;
  final int capacity;

  /// Sorted by seat.
  final List<RoomMember> members;

  /// Reward codes for the user's own room; empty when none.
  final List<IssuedCode> rewards;

  RoomMember? get owner => ownerOf(members);
}
