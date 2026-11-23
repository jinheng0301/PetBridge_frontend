import 'dart:async';

import 'package:flutter/rendering.dart' show BoxHitTestResult, RenderProxyBox;
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/features/pet/presentation/pet_view.dart';
import 'package:petbridge/features/room/application/realtime_coordinator.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/application/room_live.dart';
import 'package:petbridge/features/room/application/room_view.dart';
import 'package:petbridge/features/room/presentation/room_backdrop.dart';
import 'package:petbridge/features/room/presentation/room_member_name.dart';

/// Where a seat's pet stands, relative to the scene: [x], [y] are the
/// centre of its feet, [width] its size, all as fractions (of the scene
/// width for [x] and [width], of its height for [y]).
class SeatAnchor {
  const new(this.x, this.y, this.width);

  final double x;
  final double y;
  final double width;
}

/// The five seats: the owner front and centre, then the sides, then back.
const Map<int, SeatAnchor> seatAnchors = {
  1: SeatAnchor(0.50, 0.88, 0.32),
  2: SeatAnchor(0.21, 0.79, 0.28),
  3: SeatAnchor(0.79, 0.79, 0.28),
  4: SeatAnchor(0.33, 0.65, 0.24),
  5: SeatAnchor(0.67, 0.65, 0.24),
};

/// Seats from the back row to the front, the order they are painted in.
const _paintOrder = [4, 5, 2, 3, 1];

/// The room drawn with its pets: each member on their seat, asleep while
/// offline, with a name plate; empty seats are cushions, with an invite
/// label when [onInvite] is given.
///
/// Tapping the user's own pet ([meId]) plays cute here only; tapping
/// another pet calls [onTapPet] and plays once the tap comes back on
/// [actions], like every [PetAction] whose target is in the room.
class RoomScene extends StatefulWidget {
  const new({
    required this.view,
    required this.meId,
    required this.actions,
    required this.onTapPet,
    super.key,
    this.onLongPressPet,
    this.onInvite,
  });

  final RoomView view;
  final String meId;
  final Stream<PetAction> actions;
  final void Function(String userId) onTapPet;
  final void Function(String userId)? onLongPressPet;
  final VoidCallback? onInvite;

  @override
  State<RoomScene> createState() => _RoomSceneState();
}

class _RoomSceneState extends State<RoomScene> {
  StreamSubscription<PetAction>? _sub;

  /// Cute plays per member; a pet plays each time its count grows.
  final _cuteTicks = <String, int>{};

  @override
  void initState() {
    super.initState();
    _listen();
  }

  @override
  void didUpdateWidget(RoomScene old) {
    super.didUpdateWidget(old);
    // Equal for the same controller, so this only fires on a new source.
    if (old.actions != widget.actions) {
      unawaited(_sub?.cancel());
      _listen();
    }
    final present = {for (final m in widget.view.members) m.userId};
    _cuteTicks.removeWhere((id, _) => !present.contains(id));
  }

  void _listen() => _sub = widget.actions.listen(_onAction);

  void _onAction(PetAction action) {
    final target = action.targetUserId;
    if (!widget.view.members.any((m) => m.userId == target)) return;
    _playCute(target);
  }

  void _playCute(String userId) =>
      setState(() => _cuteTicks[userId] = (_cuteTicks[userId] ?? 0) + 1);

  void _onTap(String userId) {
    if (userId == widget.meId) {
      _playCute(userId);
    } else {
      widget.onTapPet(userId);
    }
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final view = widget.view;
    final bySeat = {for (final m in view.members) m.seatNo: m};
    final onLongPress = widget.onLongPressPet;
    final onInvite = widget.onInvite;

    return LayoutBuilder(
      builder: (context, box) {
        final size = box.biggest;
        final cushions = <Widget>[];
        final pets = <Widget>[];
        final plates = <Widget>[];
        for (final seat in _paintOrder) {
          if (seat > view.capacity) continue;
          final anchor = seatAnchors[seat]!;
          final foot = Offset(anchor.x * size.width, anchor.y * size.height);
          final width = anchor.width * size.width;
          final m = bySeat[seat];
          if (m == null) {
            cushions.add(
              _EmptySeat(
                key: ValueKey('seat-$seat'),
                seat: seat,
                foot: foot,
                width: width,
                onInvite: onInvite,
              ),
            );
            continue;
          }
          pets.add(
            Positioned(
              key: ValueKey('pet-${m.userId}'),
              left: foot.dx - width / 2,
              top: foot.dy - width,
              width: width,
              height: width,
              child: GestureDetector(
                onTap: () => _onTap(m.userId),
                onLongPress: onLongPress == null
                    ? null
                    : () => onLongPress(m.userId),
                child: _BodyHitArea(
                  child: PetView(
                    key: Key('room-pet-${m.userId}'),
                    petType: m.petType ?? '',
                    size: width,
                    pose: m.presence == Presence.offline
                        ? PetPose.sleep
                        : PetPose.idle,
                    cuteTick: _cuteTicks[m.userId] ?? 0,
                  ),
                ),
              ),
            ),
          );
          plates.add(
            _NamePlate(
              key: ValueKey('plate-${m.userId}'),
              member: m,
              name: memberDisplayName(l, m),
              foot: foot,
              maxWidth: width * 1.2,
            ),
          );
        }
        // Not clipped: cute hops up to ~16 px above a pet's box. Plates go
        // over every pet so a back-row name is never hidden.
        return Stack(
          clipBehavior: Clip.none,
          children: [
            const Positioned.fill(child: RoomBackdrop()),
            ...cushions,
            ...pets,
            ...plates,
          ],
        );
      },
    );
  }
}

/// Takes taps only where the pet is drawn (the middle of its square, from
/// the ears down), so a front pet's corners do not cover the seat behind.
class _BodyHitArea extends SingleChildRenderObjectWidget {
  const new({required super.child});

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderBodyHitArea();
}

class _RenderBodyHitArea extends RenderProxyBox {
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    final body = Rect.fromLTRB(
      size.width * .18,
      size.height * .12,
      size.width * .82,
      size.height,
    );
    return body.contains(position) && super.hitTest(result, position: position);
  }
}

/// White pill under a pet: 👑 for the owner, then the name.
class _NamePlate extends StatelessWidget {
  const new({
    required this.member,
    required this.name,
    required this.foot,
    required this.maxWidth,
    super.key,
  });

  final LiveMember member;
  final String name;
  final Offset foot;
  final double maxWidth;

  /// How far the plate tucks up under the pet's feet.
  static const _overlap = 6.0;
  static const _ink = Color(0xFF3A2E2E);

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall
        ?.copyWith(color: _ink, fontSize: 11, height: 1.3);
    return Positioned(
      left: foot.dx - maxWidth / 2,
      top: foot.dy - _overlap,
      width: maxWidth,
      child: Align(
        alignment: Alignment.topCenter,
        child: Opacity(
          opacity: member.presence == Presence.offline ? .75 : 1,
          child: DecoratedBox(
            key: Key('room-nameplate-${member.userId}'),
            decoration: const ShapeDecoration(
              color: Color(0xEBFFFFFF),
              shape: StadiumBorder(),
              shadows: [
                BoxShadow(
                  color: Color(0x1F000000),
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (member.role == RoomRole.owner) ...[
                    Text('👑', style: style),
                    const SizedBox(width: 3),
                  ],
                  Flexible(
                    child: Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: style,
                    ),
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

/// A dashed cushion on a free seat; "+ Invite" on it when [onInvite] is set.
class _EmptySeat extends StatelessWidget {
  const new({
    required this.seat,
    required this.foot,
    required this.width,
    required this.onInvite,
    super.key,
  });

  final int seat;
  final Offset foot;
  final double width;
  final VoidCallback? onInvite;

  /// Extra touch area around the cushion.
  static const _touch = 8.0;

  @override
  Widget build(BuildContext context) {
    final cushionWidth = width * 0.8;
    final cushionHeight = cushionWidth * 0.38;
    final invite = onInvite;
    Widget cushion = CustomPaint(
      key: Key('room-cushion-$seat'),
      painter: const _CushionPainter(),
      child: SizedBox(
        width: cushionWidth,
        height: cushionHeight,
        child: invite == null
            ? null
            : Center(
                child: Text(
                  AppLocalizations.of(context).room_seat_invite,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall
                      ?.copyWith(color: const Color(0xFF8A5A3A), fontSize: 10),
                ),
              ),
      ),
    );
    if (invite != null) {
      cushion = Semantics(
        button: true,
        child: GestureDetector(
          key: Key('room-seat-invite-$seat'),
          behavior: HitTestBehavior.opaque,
          onTap: invite,
          child: Padding(padding: const EdgeInsets.all(_touch), child: cushion),
        ),
      );
    } else {
      cushion = Padding(padding: const EdgeInsets.all(_touch), child: cushion);
    }
    return Positioned(
      left: foot.dx - cushionWidth / 2 - _touch,
      top: foot.dy - cushionHeight - _touch,
      child: cushion,
    );
  }
}

class _CushionPainter extends CustomPainter {
  const new();

  static const _fill = Color(0x40FFFFFF);
  static const _dash = Color(0x73785032);

  @override
  void paint(Canvas canvas, Size size) {
    final oval = Offset.zero & size;
    canvas.drawOval(oval, Paint()..color = _fill);
    final stroke = Paint()
      ..color = _dash
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final path = Path()..addOval(oval.deflate(1));
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += 8) {
        canvas.drawPath(metric.extractPath(d, d + 4), stroke);
      }
    }
  }

  @override
  bool shouldRepaint(_CushionPainter oldDelegate) => false;
}
