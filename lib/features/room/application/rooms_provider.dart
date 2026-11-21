import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/data/room_repository.dart';

/// The signed-in, onboarded user's id, or `null`. Providers that hold
/// per-user data watch this so they reset when the user changes.
final readyUserIdProvider = Provider<String?>(
  (ref) => ref.watch(
    sessionControllerProvider.select((s) => s is SessionReady ? s.me.id : null),
  ),
);

/// The rooms the user is seated in. Empty unless the session is ready.
/// Until F2 adds the WebSocket it is refreshed at fixed moments: when the
/// session becomes ready, after a join, on app resume and on pull-down.
class RoomsController extends AsyncNotifier<List<Room>> {
  @override
  Future<List<Room>> build() async {
    if (ref.watch(readyUserIdProvider) == null) return const [];
    return await ref.read(roomRepositoryProvider).listMine();
  }

  /// Reloads the list. On failure the rooms already shown stay and the
  /// [AppFailure] is rethrown for the caller to report; with nothing shown
  /// yet the provider moves to the error state.
  Future<void> refresh() async {
    if (ref.read(readyUserIdProvider) == null) return;
    // A first load is already running (e.g. this call built the provider):
    // wait for it instead of fetching twice.
    if (state.isLoading) {
      await future;
      return;
    }
    try {
      state = AsyncData(await ref.read(roomRepositoryProvider).listMine());
    } on AppFailure catch (e, st) {
      if (!state.hasValue) state = AsyncError(e, st);
      rethrow;
    }
  }
}

final roomsProvider = AsyncNotifierProvider<RoomsController, List<Room>>(
  RoomsController.new,
  // No automatic retry: the page shows the error and offers "Try again".
  retry: (_, _) => null,
);

enum RoomMode { solo, inRoom }

/// `inRoom` as soon as any room has someone besides the user.
RoomMode roomModeFor(List<Room> rooms) =>
    rooms.any((r) => r.memberCount > 1) ? RoomMode.inRoom : RoomMode.solo;

/// `solo` while the rooms are not known.
final roomModeProvider = Provider<RoomMode>(
  (ref) => roomModeFor(ref.watch(roomsProvider).value ?? const []),
);

/// The first room with company (own room comes first), else the first.
Room? defaultRoomFor(List<Room> rooms) {
  for (final r in rooms) {
    if (r.memberCount > 1) return r;
  }
  return rooms.isEmpty ? null : rooms.first;
}

/// The room the user picked in the room tab, kept in memory only.
class SelectedRoomId extends Notifier<String?> {
  @override
  String? build() {
    ref.watch(readyUserIdProvider);
    return null;
  }

  // A method, not a setter: callers read it as an action.
  // ignore: use_setters_to_change_properties
  void select(String roomId) => state = roomId;
}

final selectedRoomIdProvider = NotifierProvider<SelectedRoomId, String?>(
  SelectedRoomId.new,
);

/// The picked room while it is still listed, otherwise [defaultRoomFor].
final selectedRoomProvider = Provider<Room?>((ref) {
  final rooms = ref.watch(roomsProvider).value ?? const <Room>[];
  final id = ref.watch(selectedRoomIdProvider);
  for (final r in rooms) {
    if (r.id == id) return r;
  }
  return defaultRoomFor(rooms);
});
