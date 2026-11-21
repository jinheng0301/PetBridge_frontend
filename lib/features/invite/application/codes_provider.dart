import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petbridge/config/error_codes.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/features/invite/application/codes.dart';
import 'package:petbridge/features/invite/data/invite_repository.dart';
import 'package:petbridge/features/room/application/rooms_provider.dart';

/// The user's codes for the backpack. Same session and refresh rules as
/// [RoomsController]: empty unless ready, a failed refresh keeps the list.
class CodesController extends AsyncNotifier<List<InviteCode>> {
  @override
  Future<List<InviteCode>> build() async {
    if (ref.watch(readyUserIdProvider) == null) return const [];
    return await ref.read(inviteRepositoryProvider).listCodes();
  }

  Future<void> refresh() async {
    if (ref.read(readyUserIdProvider) == null) return;
    if (state.isLoading) {
      await future;
      return;
    }
    try {
      state = AsyncData(await ref.read(inviteRepositoryProvider).listCodes());
    } on AppFailure catch (e, st) {
      if (!state.hasValue) state = AsyncError(e, st);
      rethrow;
    }
  }

  /// Issues a code for the user's own room, then reloads the backpack and
  /// the rooms (the daily count changes). Throws [AppFailure].
  Future<IssuedCode> regen() async {
    final rooms = await ref.read(roomsProvider.future);
    final own = rooms.where((r) => r.isOwner).firstOrNull;
    if (own == null) throw const AppFailure(AppFailure.unknown);
    final issued = await ref.read(inviteRepositoryProvider).regen(own.id);
    await Future.wait([_quietly(refresh), _quietly(_refreshRooms)]);
    return issued;
  }

  Future<void> _refreshRooms() => ref.read(roomsProvider.notifier).refresh();

  /// The code was issued; a failed reload is caught up later.
  static Future<void> _quietly(Future<void> Function() reload) async {
    try {
      await reload();
    } on AppFailure {
      // Keep what is shown.
    }
  }
}

final codesProvider = AsyncNotifierProvider<CodesController, List<InviteCode>>(
  CodesController.new,
  // No automatic retry: the tab shows the error and offers "Try again".
  retry: (_, _) => null,
);

/// The message for a failed regeneration: `CODE_ISSUE_LIMIT` by its
/// `details.reason`, anything else by its code.
String regenFailureText(AppLocalizations l, AppFailure f) {
  if (f.code == 'CODE_ISSUE_LIMIT') {
    switch (f.details['reason']) {
      case 'room_full':
        return l.bag_regen_room_full;
      case 'enough_unused':
        return l.bag_regen_enough_unused;
      case 'daily_limit':
        return l.bag_regen_daily_limit;
      case 'lifetime_limit':
        return l.bag_regen_lifetime_limit;
    }
  }
  return localizedError(l, f);
}
