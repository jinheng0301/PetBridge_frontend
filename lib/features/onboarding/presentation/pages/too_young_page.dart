import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';

/// Users under 13 cannot use the app. Nothing is submitted; the only way
/// out is logging out.
class TooYoungPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.child_care, size: 64, color: theme.hintColor),
                  const SizedBox(height: 16),
                  Text(
                    l.onb_too_young_title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 12),
                  Text(l.onb_too_young_body, textAlign: TextAlign.center),
                  const SizedBox(height: 32),
                  FilledButton(
                    onPressed: () =>
                        ref.read(sessionControllerProvider.notifier).logout(),
                    child: Text(l.common_logout),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
