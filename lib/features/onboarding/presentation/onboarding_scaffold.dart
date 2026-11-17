import 'package:material_ui/material_ui.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';

/// Steps in the progress bar (frontend TRD 11.0): language, MBTI, quiz,
/// pet reveal, nickname and age. Picking an MBTI directly skips step 3.
const int kOnboardingSteps = 5;

/// Shared layout for the onboarding steps: back button, progress bar,
/// title, scrollable body and a bottom action area.
class OnboardingScaffold extends StatelessWidget {
  const new({
    required this.step,
    required this.title,
    required this.body,
    super.key,
    this.bottom,
  });

  /// 1-based step for the progress bar.
  final int step;
  final String title;
  final Widget body;
  final Widget? bottom;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l.onb_progress(step, kOnboardingSteps)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(value: step / kOnboardingSteps),
        ),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(title, style: theme.textTheme.headlineSmall),
                    const SizedBox(height: 16),
                    body,
                  ],
                ),
              ),
            ),
            if (bottom != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                child: bottom,
              ),
          ],
        ),
      ),
    );
  }
}
