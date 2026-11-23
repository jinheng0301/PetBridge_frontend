import 'package:material_ui/material_ui.dart';
import 'package:petbridge/config/error_codes.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/features/pet/presentation/pet_catalog.dart';
import 'package:petbridge/features/room/application/room_live.dart';
import 'package:petbridge/features/room/presentation/room_member_name.dart';

/// The danger colour of destructive rows and buttons.
const roomDanger = Color(0xFFD64545);

/// The sheet of a member the owner long-pressed: "nickname · pet name" and
/// one red row to remove them. Completes with `true` when remove was
/// chosen, `null` when the sheet was dismissed.
Future<bool?> showMemberSheet(BuildContext context, LiveMember member) {
  return showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      final l = AppLocalizations.of(context);
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Text(
                _title(l, member),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
            ListTile(
              key: const Key('member-sheet-remove'),
              leading: const Icon(Icons.person_remove, color: roomDanger),
              title: Text(
                l.manage_remove,
                style: const TextStyle(color: roomDanger),
              ),
              onTap: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      );
    },
  );
}

String _title(AppLocalizations l, LiveMember m) {
  final name = memberDisplayName(l, m);
  final pet = m.petType;
  final hasNick = m.nickname != null && m.nickname!.isNotEmpty;
  return hasNick && pet != null && isKnownPet(pet)
      ? '$name · ${petName(l, pet)}'
      : name;
}

/// A confirm dialog; `true` only when [confirmLabel] was pressed.
Future<bool> confirmAction(
  BuildContext context, {
  required String title,
  required String body,
  required String confirmLabel,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (context) {
      final l = AppLocalizations.of(context);
      return AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l.common_cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: roomDanger),
            child: Text(confirmLabel),
          ),
        ],
      );
    },
  );
  return ok ?? false;
}

/// Shows [failure] in a SnackBar.
void showRoomFailure(BuildContext context, AppFailure failure) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(localizedError(AppLocalizations.of(context), failure)),
      ),
    );
}
