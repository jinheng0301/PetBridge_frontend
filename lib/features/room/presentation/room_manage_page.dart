import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/app/router/routes.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/features/pet/presentation/pet_view.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/application/room_admin.dart';
import 'package:petbridge/features/room/application/room_live.dart';
import 'package:petbridge/features/room/application/room_view.dart';
import 'package:petbridge/features/room/application/rooms_provider.dart';
import 'package:petbridge/features/room/presentation/member_sheet.dart';
import 'package:petbridge/features/room/presentation/room_member_name.dart';

/// The owner's manage page: the members with a remove button each, and
/// dissolve at the bottom. Anyone else, or an unknown room, goes back to
/// the room tab.
class RoomManagePage extends ConsumerStatefulWidget {
  const new({required this.roomId, super.key});

  final String roomId;

  @override
  ConsumerState<RoomManagePage> createState() => _RoomManagePageState();
}

class _RoomManagePageState extends ConsumerState<RoomManagePage> {
  bool _busy = false;
  bool _leaving = false;

  void _backToRoom() {
    if (_leaving) return;
    _leaving = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.go(Routes.home);
    });
  }

  /// Runs [action] with the buttons disabled; a failure is shown and the
  /// buttons come back.
  Future<bool> _run(Future<void> Function() action) async {
    setState(() => _busy = true);
    try {
      await action();
      return true;
    } on AppFailure catch (e) {
      if (mounted) showRoomFailure(context, e);
      return false;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _remove(LiveMember m) async {
    final l = AppLocalizations.of(context);
    final ok = await confirmAction(
      context,
      title: l.manage_remove_confirm_title,
      body: l.manage_remove_confirm_body(memberDisplayName(l, m)),
      confirmLabel: l.manage_remove,
    );
    if (!ok || !mounted) return;
    await _run(
      () => ref.read(roomAdminProvider).remove(widget.roomId, m.userId),
    );
  }

  Future<void> _dissolve() async {
    final l = AppLocalizations.of(context);
    final ok = await confirmAction(
      context,
      title: l.manage_dissolve_confirm_title,
      body: l.manage_dissolve_confirm_body,
      confirmLabel: l.manage_dissolve,
    );
    if (!ok || !mounted) return;
    final done = await _run(
      () => ref.read(roomAdminProvider).dissolve(widget.roomId),
    );
    if (done && mounted) context.go(Routes.home);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final rooms = ref.watch(roomsProvider);
    final view = ref.watch(roomViewProvider(widget.roomId));
    final loaded = rooms.hasValue || rooms.hasError;
    if (loaded && (view == null || !view.isOwner)) _backToRoom();

    return Scaffold(
      appBar: AppBar(title: Text(l.manage_title)),
      body: view == null || !view.isOwner
          ? const Center(child: CircularProgressIndicator())
          : _Body(
              view: view,
              busy: _busy,
              onRemove: _remove,
              onDissolve: _dissolve,
            ),
    );
  }
}

class _Body extends StatelessWidget {
  const new({
    required this.view,
    required this.busy,
    required this.onRemove,
    required this.onDissolve,
  });

  final RoomView view;
  final bool busy;
  final void Function(LiveMember) onRemove;
  final VoidCallback onDissolve;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final alone = view.members.length <= 1;
    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                for (final m in view.members)
                  _MemberRow(
                    member: m,
                    busy: busy,
                    onRemove: () => onRemove(m),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: busy || alone ? null : onDissolve,
                style: FilledButton.styleFrom(backgroundColor: roomDanger),
                child: Text(l.manage_dissolve),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberRow extends StatelessWidget {
  const new({required this.member, required this.busy, required this.onRemove});

  final LiveMember member;
  final bool busy;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final pet = member.petType;
    final isOwner = member.role == RoomRole.owner;
    return ListTile(
      key: Key('manage-member-${member.userId}'),
      leading: SizedBox.square(
        dimension: 40,
        child: pet == null
            ? null
            : PetView(petType: pet, size: 40, animate: false),
      ),
      title: Text(
        memberDisplayName(l, member),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: isOwner
          ? Chip(
              label: Text(l.manage_owner),
              visualDensity: VisualDensity.compact,
            )
          : TextButton(
              onPressed: busy ? null : onRemove,
              style: TextButton.styleFrom(foregroundColor: roomDanger),
              child: Text(l.manage_remove),
            ),
    );
  }
}
