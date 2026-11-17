import 'package:material_ui/material_ui.dart';
import 'package:petbridge/config/error_codes.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/core/network/app_failure.dart';

/// The localized text for [failure] (never the server's message), or
/// nothing when [failure] is null.
class ErrorText extends StatelessWidget {
  const new(this.failure, {super.key});

  final AppFailure? failure;

  @override
  Widget build(BuildContext context) {
    final f = failure;
    if (f == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    return Text(
      localizedError(AppLocalizations.of(context), f),
      textAlign: TextAlign.center,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.error,
      ),
    );
  }
}
