import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/app/router/routes.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/features/onboarding/application/onboarding_controller.dart';
import 'package:petbridge/features/onboarding/presentation/onboarding_scaffold.dart';
import 'package:petbridge/shared/widgets/app_button.dart';

/// The usual 4×4 MBTI table, row by row.
const List<String> kMbtiGrid = [
  'ISTJ', 'ISFJ', 'INFJ', 'INTJ', //
  'ISTP', 'ISFP', 'INFP', 'INTP', //
  'ESTP', 'ESFP', 'ENFP', 'ENTP', //
  'ESTJ', 'ESFJ', 'ENFJ', 'ENTJ', //
];

/// Step 2: pick a type, or take the quiz.
class MbtiPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final mbti = ref.watch(
      onboardingControllerProvider.select((s) => s.draft.mbti),
    );

    return OnboardingScaffold(
      step: 2,
      title: l.onb_mbti_title,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 1.6,
            children: [
              for (final t in kMbtiGrid)
                ChoiceChip(
                  key: ValueKey('mbti-$t'),
                  label: SizedBox(
                    width: double.infinity,
                    child: Text(t, textAlign: TextAlign.center),
                  ),
                  showCheckmark: false,
                  selected: t == mbti,
                  onSelected: (_) => controller.setMbti(t),
                ),
            ],
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => context.push(Routes.onbQuiz),
            child: Text(l.onb_mbti_not_sure),
          ),
        ],
      ),
      bottom: AppButton(
        label: l.common_continue,
        onPressed: mbti == null ? null : () => context.push(Routes.onbReveal),
      ),
    );
  }
}
