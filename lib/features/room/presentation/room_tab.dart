import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/app/router/routes.dart';
import 'package:petbridge/config/error_codes.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/features/room/application/realtime_coordinator.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/application/room_view.dart';
import 'package:petbridge/features/room/application/rooms_provider.dart';
import 'package:petbridge/features/room/presentation/room_backdrop.dart';
import 'package:petbridge/features/room/presentation/room_scene.dart';
import 'package:petbridge/features/room/presentation/room_title.dart';
import 'package:petbridge/features/room/presentation/room_top_bar.dart';

/// The room tab: the selected room drawn live with its pets, a top bar to
/// switch rooms, and while the user is alone a card pointing to the join
/// page and the backpack. Not a list, so no pull-down refresh; the rooms
/// reload on app resume and on member changes (realtime coordinator).
class RoomTab extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rooms = ref.watch(roomsProvider);
    final selected = ref.watch(selectedRoomProvider);

    final Widget body;
    if (!rooms.hasValue && rooms.hasError) {
      body = _LoadFailed(failure: AppFailure.from(rooms.error!));
    } else if (!rooms.hasValue) {
      body = const Center(child: CircularProgressIndicator());
    } else if (selected == null) {
      // Every onboarded user has a room; this only shows if the list is
      // somehow empty.
      body = const Column(
        children: [
          Expanded(child: RoomBackdrop()),
          _SoloCard(),
        ],
      );
    } else {
      body = _Room(rooms: rooms.requireValue, room: selected);
    }
    return Scaffold(body: body);
  }
}

class _Room extends ConsumerWidget {
  const new({required this.rooms, required this.room});

  final List<Room> rooms;
  final Room room;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final view = ref.watch(roomViewProvider(room.id));
    // Watched, never kept: the coordinator is rebuilt per session.
    final coordinator = ref.watch(realtimeCoordinatorProvider);
    final reconnecting = ref.watch(wsReconnectingProvider);
    final solo = ref.watch(roomModeProvider) == RoomMode.solo;
    final meId = ref.watch(readyUserIdProvider) ?? '';
    if (view == null) return const Center(child: CircularProgressIndicator());

    void goToBag() => context.go(Routes.homeBag);

    final scene = Stack(
      children: [
        Positioned.fill(
          child: RoomScene(
            // A fresh scene per room: no cute counts carried across.
            key: ValueKey(room.id),
            view: view,
            meId: meId,
            actions: coordinator.petActions(room.id),
            onTapPet: (userId) =>
                ref.read(realtimeCoordinatorProvider).tapPet(room.id, userId),
            // The card already offers the invite while the user is alone.
            onInvite: view.isOwner && !solo ? goToBag : null,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 9, 12, 0),
                  child: RoomTopBar(
                    title: roomTitle(l, room),
                    memberCount: view.memberCount,
                    capacity: view.capacity,
                    canSwitch: rooms.length > 1,
                    onSwitch: () => _switchRoom(ref),
                  ),
                ),
                if (reconnecting) ...[
                  const SizedBox(height: 6),
                  const _ReconnectingPill(),
                ],
              ],
            ),
          ),
        ),
      ],
    );

    if (!solo) return scene;
    return Column(
      children: [
        Expanded(child: scene),
        const _SoloCard(),
      ],
    );
  }

  /// Moves to the next listed room (the user is in at most two).
  void _switchRoom(WidgetRef ref) {
    final i = rooms.indexWhere((r) => r.id == room.id);
    final next = rooms[(i + 1) % rooms.length];
    ref.read(selectedRoomIdProvider.notifier).select(next.id);
  }
}

class _ReconnectingPill extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      key: const Key('room-reconnecting'),
      decoration: const ShapeDecoration(
        color: Color(0xFFFFF4C2),
        shape: StadiumBorder(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        child: Text(
          AppLocalizations.of(context).room_reconnecting,
          style: Theme.of(context).textTheme.labelSmall
              ?.copyWith(color: const Color(0xFF7A5B00)),
        ),
      ),
    );
  }
}

/// Under the scene while the user is alone: enter a friend's code, or
/// invite friends from the backpack.
class _SoloCard extends StatelessWidget {
  const new();

  /// The floor colour, so the card sits on the room's floor.
  static const _floor = Color(0xFFE2B582);

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return ColoredBox(
      color: _floor,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          child: Card(
            key: const Key('room-solo-card'),
            margin: EdgeInsets.zero,
            color: const Color(0xF2FFFFFF),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(l.room_solo_card),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.tonal(
                          onPressed: () => context.push(Routes.join),
                          child: Text(
                            l.room_join_button,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => context.go(Routes.homeBag),
                          child: Text(
                            l.room_invite,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LoadFailed extends ConsumerWidget {
  const new({required this.failure});

  final AppFailure failure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localizedError(l, failure), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                try {
                  await ref.read(roomsProvider.notifier).refresh();
                } on AppFailure {
                  // Still failing; the error stays on screen.
                }
              },
              child: Text(l.common_retry),
            ),
          ],
        ),
      ),
    );
  }
}
