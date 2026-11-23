import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/features/pet/presentation/pet_view.dart';
import 'package:petbridge/features/room/application/realtime_coordinator.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/application/room_live.dart';
import 'package:petbridge/features/room/application/room_view.dart';
import 'package:petbridge/features/room/presentation/room_scene.dart';

import '../../helpers/pump_app.dart';

const sceneSize = Size(400, 560);

LiveMember live(
  String id,
  int seat, {
  String? nickname,
  String? petType = 'thinker_owl',
  Presence presence = Presence.online,
}) => LiveMember(
  userId: id,
  seatNo: seat,
  role: seat == 1 ? RoomRole.owner : RoomRole.member,
  presence: presence,
  nickname: nickname ?? id,
  petType: petType,
);

RoomView view(List<LiveMember> members, {bool isOwner = true}) => RoomView(
  roomId: 'own',
  isOwner: isOwner,
  memberCount: members.length,
  capacity: 5,
  members: members,
);

Finder pet(String userId) => find.byKey(Key('room-pet-$userId'));

void main() {
  late StreamController<PetAction> actions;
  late List<String> tapped;
  late int invites;

  setUp(() {
    actions = StreamController<PetAction>.broadcast();
    tapped = [];
    invites = 0;
  });

  tearDown(() => actions.close());

  Future<void> pump(
    WidgetTester tester,
    RoomView v, {
    bool withInvite = true,
  }) => pumpLocalized(
    tester,
    Center(
      child: SizedBox.fromSize(
        size: sceneSize,
        child: RoomScene(
          view: v,
          meId: 'u1',
          actions: actions.stream,
          onTapPet: tapped.add,
          onInvite: withInvite ? () => invites++ : null,
        ),
      ),
    ),
  );

  PetView petView(WidgetTester tester, String userId) =>
      tester.widget<PetView>(pet(userId));

  testWidgets('pets sit at their seat anchors', (tester) async {
    await pump(tester, view([live('u1', 1), live('u4', 4)]));

    final origin = tester.getTopLeft(find.byType(RoomScene));
    final box = tester.getRect(pet('u4'));
    expect(box.center.dx - origin.dx, closeTo(sceneSize.width * 0.33, 1));
    expect(box.bottom - origin.dy, closeTo(sceneSize.height * 0.65, 1));
    expect(box.width, closeTo(sceneSize.width * 0.24, 1));

    final owner = tester.getRect(pet('u1'));
    expect(owner.center.dx - origin.dx, closeTo(sceneSize.width * 0.5, 1));
    expect(owner.bottom - origin.dy, closeTo(sceneSize.height * 0.88, 1));
    expect(owner.width, closeTo(sceneSize.width * 0.32, 1));
  });

  testWidgets('offline member sleeps', (tester) async {
    await pump(
      tester,
      view([live('u1', 1), live('u2', 2, presence: Presence.offline)]),
    );

    expect(petView(tester, 'u2').pose, PetPose.sleep);
    expect(petView(tester, 'u1').pose, PetPose.idle);
  });

  testWidgets('unknown presence is idle', (tester) async {
    await pump(tester, view([live('u1', 1, presence: Presence.unknown)]));

    expect(petView(tester, 'u1').pose, PetPose.idle);
  });

  testWidgets('tapping another pet calls tapPet', (tester) async {
    await pump(tester, view([live('u1', 1), live('u2', 2)]));

    await tester.tap(pet('u2'));
    await tester.pump();

    expect(tapped, ['u2']);
  });

  testWidgets('tapping own pet plays locally without tapPet', (tester) async {
    await pump(tester, view([live('u1', 1), live('u2', 2)]));

    await tester.tap(pet('u1'));
    await tester.pump();

    expect(tapped, isEmpty);
    expect(petView(tester, 'u1').cuteTick, 1);
    expect(petView(tester, 'u2').cuteTick, 0);
  });

  testWidgets('incoming action plays cute on target', (tester) async {
    await pump(
      tester,
      view([live('u1', 1), live('u2', 2, presence: Presence.offline)]),
    );

    actions
      ..add(const PetAction(targetUserId: 'u2', fromUserId: 'u1'))
      ..add(const PetAction(targetUserId: 'gone'));
    // Delivered in a microtask: the first pump runs it, the next builds.
    await tester.pumpAndSettle();

    expect(petView(tester, 'u2').cuteTick, 1);
    // Still asleep: cute is a one-shot over the pose.
    expect(petView(tester, 'u2').pose, PetPose.sleep);
    expect(petView(tester, 'u1').cuteTick, 0);
  });

  testWidgets('nameplate shows crown and nickname, falls back to pet name', (
    tester,
  ) async {
    await pump(
      tester,
      view([
        live('u1', 1, nickname: 'Aki'),
        const LiveMember(
          userId: 'u2',
          seatNo: 2,
          role: RoomRole.member,
          presence: Presence.online,
          nickname: '',
          petType: 'thinker_owl',
        ),
      ]),
    );

    final ownerPlate = find.byKey(const Key('room-nameplate-u1'));
    expect(
      find.descendant(of: ownerPlate, matching: find.text('👑')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: ownerPlate, matching: find.text('Aki')),
      findsOneWidget,
    );

    final plate = find.byKey(const Key('room-nameplate-u2'));
    expect(find.descendant(of: plate, matching: find.text('👑')), findsNothing);
    expect(
      find.descendant(of: plate, matching: find.text(en.pet_thinker_owl_name)),
      findsOneWidget,
    );
  });

  testWidgets('long nickname is ellipsized', (tester) async {
    await pump(
      tester,
      view([live('u1', 1), live('u2', 2, nickname: 'H' * 40)]),
    );

    expect(tester.takeException(), isNull);
    final name = find.descendant(
      of: find.byKey(const Key('room-nameplate-u2')),
      matching: find.text('H' * 40),
    );
    expect(tester.widget<Text>(name).overflow, TextOverflow.ellipsis);
    expect(
      tester.getSize(find.byKey(const Key('room-nameplate-u2'))).width,
      lessThanOrEqualTo(tester.getSize(pet('u2')).width * 1.2 + 0.5),
    );
  });

  testWidgets('empty seats are cushions, with invite only when offered', (
    tester,
  ) async {
    await pump(tester, view([live('u1', 1), live('u2', 2)]));

    expect(find.byKey(const Key('room-cushion-3')), findsOneWidget);
    expect(find.byKey(const Key('room-cushion-5')), findsOneWidget);
    expect(find.text(en.room_seat_invite), findsNWidgets(3));

    await tester.tap(find.byKey(const Key('room-seat-invite-4')));
    expect(invites, 1);
  });

  testWidgets('without onInvite empty seats have no invite', (tester) async {
    await pump(tester, view([live('u1', 1)]), withInvite: false);

    expect(find.byKey(const Key('room-cushion-2')), findsOneWidget);
    expect(find.text(en.room_seat_invite), findsNothing);
  });

  testWidgets('a new actions stream replaces the old one', (tester) async {
    final next = StreamController<PetAction>.broadcast();
    addTearDown(next.close);
    final stream = ValueNotifier<Stream<PetAction>>(actions.stream);
    addTearDown(stream.dispose);
    final v = view([live('u1', 1), live('u2', 2)]);

    await pumpLocalized(
      tester,
      Center(
        child: SizedBox.fromSize(
          size: sceneSize,
          child: ValueListenableBuilder(
            valueListenable: stream,
            builder: (_, s, _) => RoomScene(
              view: v,
              meId: 'u1',
              actions: s,
              onTapPet: tapped.add,
            ),
          ),
        ),
      ),
    );

    stream.value = next.stream;
    await tester.pump();
    actions.add(const PetAction(targetUserId: 'u2'));
    next.add(const PetAction(targetUserId: 'u1'));
    await tester.pumpAndSettle();

    expect(petView(tester, 'u2').cuteTick, 0);
    expect(petView(tester, 'u1').cuteTick, 1);
  });
}
