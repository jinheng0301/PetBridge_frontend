import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/app/router/routes.dart';
import 'package:petbridge/config/error_codes.dart';
import 'package:petbridge/core/clock.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/features/invite/application/codes.dart';
import 'package:petbridge/features/invite/application/codes_provider.dart';
import 'package:petbridge/features/invite/presentation/widgets/code_tile.dart';
import 'package:petbridge/features/room/application/room.dart';
import 'package:petbridge/features/room/application/rooms_provider.dart';

/// The backpack tab: the user's codes, newest first, and "Generate code".
class BagTab extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final codes = ref.watch(codesProvider);
    final now = ref.watch(clockProvider)();

    final Widget list;
    if (!codes.hasValue && codes.hasError) {
      list = _LoadFailed(failure: AppFailure.from(codes.error!));
    } else if (!codes.hasValue) {
      list = const Center(child: CircularProgressIndicator());
    } else {
      list = _CodeList(codes: codes.requireValue, now: now);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l.bag_title),
        actions: [
          TextButton(
            onPressed: () => context.push(Routes.join),
            child: Text(l.bag_join),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _refresh(context, ref),
              child: list,
            ),
          ),
          const _RegenBar(),
        ],
      ),
    );
  }

  /// Reloads codes and rooms (room sizes and the daily count live there).
  static Future<void> _refresh(BuildContext context, WidgetRef ref) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final results = await Future.wait([
      _attempt(ref.read(codesProvider.notifier).refresh),
      _attempt(ref.read(roomsProvider.notifier).refresh),
    ]);
    final failure = results.nonNulls.firstOrNull;
    if (failure != null) {
      messenger.showSnackBar(
        SnackBar(content: Text(localizedError(l, failure))),
      );
    }
  }

  static Future<AppFailure?> _attempt(Future<void> Function() reload) async {
    try {
      await reload();
      return null;
    } on AppFailure catch (f) {
      return f;
    }
  }
}

class _CodeList extends StatelessWidget {
  const new({required this.codes, required this.now});

  final List<InviteCode> codes;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    if (codes.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          const SizedBox(height: 120),
          Text(
            AppLocalizations.of(context).bag_empty,
            textAlign: TextAlign.center,
          ),
        ],
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: codes.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (_, i) => CodeTile(code: codes[i], now: now),
    );
  }
}

/// "Generate code" with the reason it is unavailable, or today's count.
class _RegenBar extends ConsumerStatefulWidget {
  const new();

  @override
  ConsumerState<_RegenBar> createState() => _RegenBarState();
}

class _RegenBarState extends ConsumerState<_RegenBar> {
  var _busy = false;

  Future<void> _regen() async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    try {
      await ref.read(codesProvider.notifier).regen();
      messenger.showSnackBar(SnackBar(content: Text(l.bag_regen_done)));
    } on AppFailure catch (f) {
      messenger.showSnackBar(SnackBar(content: Text(regenFailureText(l, f))));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final rooms = ref.watch(roomsProvider).value ?? const <Room>[];
    final own = rooms.where((r) => r.isOwner).firstOrNull;
    final left = own?.regenRemainingToday;
    final full =
        own != null &&
        (own.status == RoomStatus.full || own.memberCount >= own.capacity);

    // Full room wins over the daily count.
    final String? hint;
    if (full) {
      hint = l.bag_regen_full;
    } else if (left == 0) {
      hint = l.bag_regen_none_left;
    } else if (left != null) {
      hint = l.bag_regen_remaining(left);
    } else {
      hint = null;
    }
    final enabled = own != null && !full && left != 0 && !_busy;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FilledButton.tonalIcon(
              onPressed: enabled ? _regen : null,
              icon: const Icon(Icons.add),
              label: Text(l.bag_regen),
            ),
            if (hint != null) ...[
              const SizedBox(height: 6),
              Text(
                hint,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _LoadFailed extends ConsumerWidget {
  const new({required this.failure});

  final AppFailure failure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 80),
        Text(localizedError(l, failure), textAlign: TextAlign.center),
        const SizedBox(height: 16),
        Center(
          child: FilledButton(
            onPressed: () async {
              try {
                await ref.read(codesProvider.notifier).refresh();
              } on AppFailure {
                // Still failing; the error stays on screen.
              }
            },
            child: Text(l.common_retry),
          ),
        ),
      ],
    );
  }
}
