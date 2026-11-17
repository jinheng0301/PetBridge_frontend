import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/app/router/routes.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/features/onboarding/application/onboarding_controller.dart';
import 'package:petbridge/features/onboarding/application/quiz.dart';
import 'package:petbridge/features/onboarding/presentation/onboarding_scaffold.dart';
import 'package:petbridge/shared/widgets/app_button.dart';

/// Step 3, result: the quiz's four letters. Tapping a letter flips that
/// dimension; confirming returns to the MBTI page with the type selected.
class QuizResultPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final result = ref.watch(
      onboardingControllerProvider.select((s) => s.quizResult),
    );

    void done() =>
        context.canPop() ? context.pop() : context.go(Routes.onbMbti);

    if (result == null) {
      // Reached without taking the quiz (e.g. a stale route): start over.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.pushReplacement(Routes.onbQuiz);
      });
      return const Scaffold();
    }

    return OnboardingScaffold(
      step: 3,
      title: l.onb_quiz_result_title,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.onb_quiz_result_hint),
          const SizedBox(height: 24),
          Row(
            children: [
              for (final d in Dimension.values)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: FilledButton.tonal(
                      key: ValueKey('flip-${d.name}'),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(72),
                        padding: EdgeInsets.zero,
                        textStyle: theme.textTheme.headlineMedium,
                      ),
                      onPressed: () => controller.flipQuizDimension(d),
                      child: Text(result[d.index]),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      bottom: AppButton(
        label: l.onb_quiz_result_confirm,
        onPressed: () {
          controller.confirmQuizResult();
          done();
        },
      ),
    );
  }
}
