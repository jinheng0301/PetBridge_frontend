import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/app/router/routes.dart';
import 'package:petbridge/config/error_codes.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/pet/presentation/pet_catalog.dart';
import 'package:petbridge/features/pet/presentation/pet_view.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/application/rooms_provider.dart';
import 'package:petbridge/features/room/presentation/room_title.dart';

/// The room tab. In F1 it is a member list; F2 replaces the list with the
/// room scene and adds the manage / leave entries.
class RoomTab extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final rooms = ref.watch(roomsProvider);
    final mode = ref.watch(roomModeProvider);
    final selected = ref.watch(selectedRoomProvider);

    final Widget body;
    if (!rooms.hasValue && rooms.hasError) {
      body = _LoadFailed(failure: AppFailure.from(rooms.error!));
    } else if (!rooms.hasValue) {
      body = const Center(child: CircularProgressIndicator());
    } else if (mode == RoomMode.solo || selected == null) {
      body = const _Solo();
    } else {
      body = _InRoom(rooms: rooms.requireValue, selected: selected);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          mode == RoomMode.inRoom && selected != null
              ? '${roomTitle(l, selected)} '
                    '${l.room_count(selected.memberCount, selected.capacity)}'
              : l.home_tab_room,
          key: const Key('room-title'),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(context, ref),
        child: body,
      ),
    );
  }

  static Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(roomsProvider.notifier).refresh();
    } on AppFailure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(localizedError(l, f))));
    }
  }
}

class _Solo extends ConsumerWidget {
  const new();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final session = ref.watch(sessionControllerProvider);
    final me = session is SessionReady ? session.me : null;
    final petType = me?.petType;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 16),
        if (petType != null && isKnownPet(petType))
          Center(child: PetView(petType: petType)),
        const SizedBox(height: 16),
        Text(
          [?me?.nickname, ?me?.mbti].join(' · '),
          textAlign: TextAlign.center,
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 4),
        Text(
          l.room_solo_hint,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
        const SizedBox(height: 48),
        DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const Icon(Icons.lock_outline),
                const SizedBox(height: 8),
                Text(l.room_locked_title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(l.room_locked_body, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: () => context.push(Routes.join),
          child: Text(l.room_join_button),
        ),
      ],
    );
  }
}

class _InRoom extends ConsumerWidget {
  const new({required this.rooms, required this.selected});

  final List<Room> rooms;
  final Room selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final myId = session is SessionReady ? session.me.id : null;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        if (rooms.length > 1) ...[
          SegmentedButton<String>(
            showSelectedIcon: false,
            segments: [
              for (final r in rooms)
                ButtonSegment(
                  value: r.id,
                  label: Text(
                    '${roomTitle(l, r)} '
                    '${l.room_count(r.memberCount, r.capacity)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            selected: {selected.id},
            onSelectionChanged: (ids) =>
                ref.read(selectedRoomIdProvider.notifier).select(ids.first),
          ),
          const SizedBox(height: 16),
        ],
        Card(
          child: Column(
            children: [
              for (final m in selected.members)
                ListTile(
                  leading: _MemberPet(petType: m.petType),
                  title: Text(
                    m.userId == myId ? l.room_me : (m.nickname ?? ''),
                    key: const Key('member-name'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: m.role == RoomRole.owner
                      ? Chip(label: Text(l.room_owner_tag))
                      : null,
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (selected.freeSeats > 0)
          Text(
            l.room_free_seats(selected.freeSeats),
            textAlign: TextAlign.center,
          ),
        if (selected.isOwner && selected.freeSeats > 0) ...[
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => context.go(Routes.homeBag),
            child: Text(l.room_invite),
          ),
        ],
      ],
    );
  }
}

class _MemberPet extends StatelessWidget {
  const new({required this.petType});

  final String? petType;

  @override
  Widget build(BuildContext context) {
    final p = petType;
    if (p != null && isKnownPet(p)) return PetView(petType: p, size: 40);
    return const CircleAvatar(child: Icon(Icons.pets));
  }
}

class _LoadFailed extends ConsumerWidget {
  const new({required this.failure});

  final AppFailure failure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Text(localizedError(l, failure), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Center(
          child: FilledButton(
            onPressed: () async {
              try {
                await ref.read(roomsProvider.notifier).refresh();
              } on AppFailure {
                // Still failing; the error stays on screen.
              }
            },
            child: Text(l.common_retry),
          ),
        ),
      ],
    );
  }
}
