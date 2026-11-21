import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/features/room/application/room.dart';

/// Rooms have no name in the API: the user's own room is "My room",
/// another is named after its owner ("A friend's room" without a nickname).
String roomTitle(AppLocalizations l, Room room) =>
    room.isOwner ? l.room_title_mine : ownerRoomTitle(l, room.owner?.nickname);

/// The title of someone else's room whose owner is called [nickname].
String ownerRoomTitle(AppLocalizations l, String? nickname) =>
    nickname == null || nickname.isEmpty
    ? l.room_title_friend
    : l.room_title_of(nickname);
