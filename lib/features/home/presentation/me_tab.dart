import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/pet/presentation/pet_catalog.dart';
import 'package:petbridge/features/pet/presentation/pet_view.dart';

/// Profile summary (nickname, MBTI, pet) and logout.
class MeTab extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final me = session is SessionReady ? session.me : null;
    final petType = me?.petType;
    final knownPet = petType != null && kPetTypeByMbti.containsValue(petType);

    return Scaffold(
      appBar: AppBar(title: Text(l.home_tab_me)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (knownPet) Center(child: PetView(petType: petType, size: 140)),
          const SizedBox(height: 16),
          ListTile(
            title: Text(l.me_nickname),
            trailing: Text(me?.nickname ?? '-'),
          ),
          ListTile(title: Text(l.me_mbti), trailing: Text(me?.mbti ?? '-')),
          ListTile(
            title: Text(l.me_pet),
            trailing: Text(knownPet ? petName(l, petType) : '-'),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () =>
                ref.read(sessionControllerProvider.notifier).logout(),
            child: Text(l.common_logout),
          ),
        ],
      ),
    );
  }
}
