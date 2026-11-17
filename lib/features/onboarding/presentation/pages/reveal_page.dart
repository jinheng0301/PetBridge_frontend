import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/app/router/routes.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/features/onboarding/application/onboarding_controller.dart';
import 'package:petbridge/features/onboarding/presentation/onboarding_scaffold.dart';
import 'package:petbridge/features/pet/presentation/pet_catalog.dart';
import 'package:petbridge/features/pet/presentation/pet_view.dart';
import 'package:petbridge/shared/widgets/app_button.dart';

/// Step 4: the pet for the chosen MBTI, looked up locally (the server binds
/// the same one on submit).
class RevealPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final mbti = ref.watch(
      onboardingControllerProvider.select((s) => s.draft.mbti),
    );
    if (mbti == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go(Routes.onbMbti);
      });
      return const Scaffold();
    }
    final petType = petTypeFor(mbti);

    return OnboardingScaffold(
      step: 4,
      title: l.onb_reveal_title,
      body: Column(
        children: [
          const SizedBox(height: 8),
          PetView(petType: petType, size: 180),
          const SizedBox(height: 16),
          Text(mbti, style: theme.textTheme.titleLarge),
          const SizedBox(height: 12),
          Text(
            petIntro(l, petType),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
      bottom: AppButton(
        label: l.common_continue,
        onPressed: () => context.push(Routes.onbProfile),
      ),
    );
  }
}
