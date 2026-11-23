import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/features/pet/presentation/pet_catalog.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/application/room_live.dart';
import 'package:petbridge/features/room/presentation/member_sheet.dart';

import '../../helpers/pump_app.dart';

void main() {
  const bo = LiveMember(
    userId: 'u2',
    nickname: 'Bo',
    petType: 'thinker_owl',
    seatNo: 2,
    role: RoomRole.member,
    presence: Presence.unknown,
  );

  const bare = LiveMember(
    userId: 'u3',
    seatNo: 3,
    role: RoomRole.member,
    presence: Presence.unknown,
  );

  testWidgets('title is never blank without nickname or pet', (tester) async {
    await pumpLocalized(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () => showMemberSheet(context, bare),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text(en.room_member_unknown), findsOneWidget);
  });

  Future<void> open(WidgetTester tester, void Function(bool?) onResult) async {
    await pumpLocalized(
      tester,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async => onResult(await showMemberSheet(context, bo)),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  testWidgets('title is nickname and pet name', (tester) async {
    await open(tester, (_) {});
    expect(find.text('Bo · ${petName(en, 'thinker_owl')}'), findsOneWidget);
    expect(find.text(en.manage_remove), findsOneWidget);
  });

  testWidgets('remove row closes the sheet with true', (tester) async {
    bool? result;
    await open(tester, (r) => result = r);
    await tester.tap(find.text(en.manage_remove));
    await tester.pumpAndSettle();

    expect(result, isTrue);
    expect(find.text(en.manage_remove), findsNothing);
  });
}
