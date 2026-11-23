import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/features/pet/presentation/pet_catalog.dart';
import 'package:petbridge/features/room/application/room_live.dart';

/// What a member is called on screen: the nickname, else the pet's name,
/// else a generic word. Never blank.
String memberDisplayName(AppLocalizations l, LiveMember m) {
  final nickname = m.nickname;
  if (nickname != null && nickname.isNotEmpty) return nickname;
  final pet = m.petType;
  if (pet != null && isKnownPet(pet)) return petName(l, pet);
  return l.room_member_unknown;
}
