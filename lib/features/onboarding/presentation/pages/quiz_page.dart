import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/app/router/routes.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/features/onboarding/application/onboarding_controller.dart';
import 'package:petbridge/features/onboarding/application/quiz.dart';
import 'package:petbridge/features/onboarding/presentation/onboarding_scaffold.dart';
import 'package:petbridge/features/onboarding/presentation/quiz_texts.dart';

/// Step 3: four two-choice questions, one at a time. After the
/// last answer it is replaced by the result page.
class QuizPage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends ConsumerState<QuizPage> {
  final _answers = <QuizChoice>[];

  void _answer(QuizChoice c) {
    _answers.add(c);
    if (_answers.length < kQuizQuestions.length) {
      setState(() {});
      return;
    }
    ref.read(onboardingControllerProvider.notifier).setQuizAnswers(_answers);
    context.pushReplacement(Routes.onbQuizResult);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final q = kQuizQuestions[_answers.length];
    return PopScope(
      // Back steps through the questions before leaving the quiz.
      canPop: _answers.isEmpty,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) setState(_answers.removeLast);
      },
      child: OnboardingScaffold(
        step: 3,
        title: l.onb_quiz_progress(_answers.length + 1, kQuizQuestions.length),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              quizText(l, q.promptKey),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            for (final (choice, key) in [
              (QuizChoice.a, q.aKey),
              (QuizChoice.b, q.bKey),
            ]) ...[
              OutlinedButton(
                key: ValueKey('quiz-${choice.name}'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                onPressed: () => _answer(choice),
                child: Text(quizText(l, key), textAlign: TextAlign.center),
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }
}
