import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/app/router/routes.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/features/invite/application/codes.dart';
import 'package:petbridge/features/invite/application/invite_code.dart';
import 'package:petbridge/features/invite/application/remaining.dart';

/// One backpack entry: the code, its status, its room's size and, while
/// unused, how long it stays valid plus a share button.
class CodeTile extends StatelessWidget {
  const new({required this.code, required this.now, super.key});

  final InviteCode code;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final unused = code.status == CodeStatus.unused;

    return ListTile(
      title: Row(
        children: [
          Text(
            formatCode(code.code),
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: 'monospace',
              letterSpacing: 2,
              color: unused ? null : theme.disabledColor,
            ),
          ),
          const SizedBox(width: 8),
          _StatusChip(status: code.status),
        ],
      ),
      subtitle: Wrap(
        spacing: 12,
        children: [
          Text(l.bag_room_count(code.roomMemberCount, code.roomCapacity)),
          if (unused)
            Text(remainingText(l, remainingUntil(code.expiresAt, now))),
        ],
      ),
      trailing: unused
          ? TextButton(
              onPressed: () => context.push(Routes.sharePath(code.code)),
              child: Text(l.bag_share),
            )
          : null,
    );
  }
}

String remainingText(AppLocalizations l, Remaining r) => switch (r) {
  RemainingDays(:final days) => l.bag_days_left(days),
  RemainingHours(:final hours) => l.bag_hours_left(hours),
  RemainingSoon() => l.bag_expiring,
};

class _StatusChip extends StatelessWidget {
  const new({required this.status});

  final CodeStatus status;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final (label, color) = switch (status) {
      CodeStatus.unused => (l.bag_status_unused, scheme.primaryContainer),
      CodeStatus.used => (l.bag_status_used, scheme.surfaceContainerHighest),
      CodeStatus.expired => (
        l.bag_status_expired,
        scheme.surfaceContainerHighest,
      ),
      CodeStatus.voided => (l.bag_status_void, scheme.surfaceContainerHighest),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: Theme.of(context).textTheme.labelSmall),
    );
  }
}
