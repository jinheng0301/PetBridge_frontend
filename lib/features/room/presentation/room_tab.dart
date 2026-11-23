import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/app/router/routes.dart';
import 'package:petbridge/config/error_codes.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/features/room/application/realtime_coordinator.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/application/room_admin.dart';
import 'package:petbridge/features/room/application/room_view.dart';
import 'package:petbridge/features/room/application/rooms_provider.dart';
import 'package:petbridge/features/room/presentation/member_sheet.dart';
import 'package:petbridge/features/room/presentation/room_backdrop.dart';
import 'package:petbridge/features/room/presentation/room_member_name.dart';
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
            onLongPressPet: view.isOwner
                ? (userId) => _openMemberSheet(context, ref, view, userId)
                : null,
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
                    menu: _RoomMenu(roomId: room.id, isOwner: view.isOwner),
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

  /// Long press on another member's pet in the user's own room.
  Future<void> _openMemberSheet(
    BuildContext context,
    WidgetRef ref,
    RoomView view,
    String userId,
  ) async {
    final meId = ref.read(readyUserIdProvider);
    final member = view.members.where((m) => m.userId == userId).firstOrNull;
    if (member == null || userId == meId) return;
    final remove = await showMemberSheet(context, member);
    if (remove != true || !context.mounted) return;
    final l = AppLocalizations.of(context);
    final ok = await confirmAction(
      context,
      title: l.manage_remove_confirm_title,
      body: l.manage_remove_confirm_body(memberDisplayName(l, member)),
      confirmLabel: l.manage_remove,
    );
    if (!ok || !context.mounted) return;
    try {
      await ref.read(roomAdminProvider).remove(view.roomId, userId);
    } on AppFailure catch (e) {
      if (context.mounted) showRoomFailure(context, e);
    }
  }

  /// Moves to the next listed room (the user is in at most two).
  void _switchRoom(WidgetRef ref) {
    final i = rooms.indexWhere((r) => r.id == room.id);
    final next = rooms[(i + 1) % rooms.length];
    ref.read(selectedRoomIdProvider.notifier).select(next.id);
  }
}

enum _MenuAction { manage, leave }

/// The `⋯` button: manage in the user's own room, leave in a friend's.
class _RoomMenu extends ConsumerStatefulWidget {
  const new({required this.roomId, required this.isOwner});

  final String roomId;
  final bool isOwner;

  @override
  ConsumerState<_RoomMenu> createState() => _RoomMenuState();
}

class _RoomMenuState extends ConsumerState<_RoomMenu> {
  bool _busy = false;

  Future<void> _leave() async {
    final l = AppLocalizations.of(context);
    final ok = await confirmAction(
      context,
      title: l.room_leave_confirm_title,
      body: l.room_leave_confirm_body,
      confirmLabel: l.room_leave,
    );
    if (!ok || !mounted) return;
    setState(() => _busy = true);
    try {
      await ref.read(roomAdminProvider).leave(widget.roomId);
    } on AppFailure catch (e) {
      if (mounted) showRoomFailure(context, e);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PopupMenuButton<_MenuAction>(
      key: const Key('room-menu'),
      enabled: !_busy,
      padding: EdgeInsets.zero,
      icon: const DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xE6FFFFFF),
          shape: BoxShape.circle,
        ),
        child: SizedBox.square(
          dimension: 32,
          child: Icon(Icons.more_horiz, size: 20, color: Color(0xFF3A2E2E)),
        ),
      ),
      onSelected: (action) {
        switch (action) {
          case _MenuAction.manage:
            unawaited(context.push(Routes.roomManagePath(widget.roomId)));
          case _MenuAction.leave:
            unawaited(_leave());
        }
      },
      itemBuilder: (_) => [
        if (widget.isOwner)
          PopupMenuItem(value: _MenuAction.manage, child: Text(l.manage_open))
        else
          PopupMenuItem(
            value: _MenuAction.leave,
            child: Text(
              l.room_leave,
              style: const TextStyle(color: roomDanger),
            ),
          ),
      ],
    );
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
