import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/features/invite/application/codes_provider.dart';
import 'package:petbridge/features/room/application/rooms_provider.dart';
import 'package:petbridge/features/room/data/room_repository.dart';

/// Owner actions (remove a member, dissolve) and a member's leave. Each one
/// reloads the rooms afterwards; failures are rethrown as [AppFailure] except
/// `ROOM_NOT_FOUND`, which means the user is already out.
class RoomAdmin {
  const new(this._ref);

  final Ref _ref;

  Future<void> remove(String roomId, String userId) async {
    await _ref.read(roomRepositoryProvider).removeMember(roomId, userId);
    await _quietly(_ref.read(roomsProvider.notifier).refresh);
  }

  Future<void> dissolve(String roomId) async {
    await _ref.read(roomRepositoryProvider).dissolve(roomId);
    await Future.wait([
      _quietly(_ref.read(roomsProvider.notifier).refresh),
      _quietly(_ref.read(codesProvider.notifier).refresh),
    ]);
  }

  Future<void> leave(String roomId) async {
    try {
      await _ref.read(roomRepositoryProvider).leave(roomId);
    } on AppFailure catch (e) {
      if (e.code != 'ROOM_NOT_FOUND') rethrow;
    }
    await _quietly(_ref.read(roomsProvider.notifier).refresh);
    final rooms = _ref.read(roomsProvider).value ?? const [];
    final own = rooms.where((r) => r.isOwner).firstOrNull;
    if (own != null) _ref.read(selectedRoomIdProvider.notifier).select(own.id);
  }

  /// The action already succeeded; a failed reload is caught up later.
  static Future<void> _quietly(Future<void> Function() reload) async {
    try {
      await reload();
    } on AppFailure {
      // Keep what is shown.
    }
  }
}

final roomAdminProvider = Provider<RoomAdmin>(RoomAdmin.new);
