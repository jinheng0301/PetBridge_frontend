import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/shared/widgets/error_text.dart';

/// Shown while the session restores. If that fails (e.g. offline) it shows
/// the error and a retry button.
class SplashPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final failure = session is SessionUnknown ? session.failure : null;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l.appTitle,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 24),
              if (failure == null)
                const CircularProgressIndicator()
              else ...[
                ErrorText(failure),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () =>
                      ref.read(sessionControllerProvider.notifier).retry(),
                  child: Text(l.common_retry),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
