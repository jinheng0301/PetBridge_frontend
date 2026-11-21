import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/app/router/routes.dart';
import 'package:petbridge/config/error_codes.dart';
import 'package:petbridge/core/clock.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/features/invite/application/codes.dart';
import 'package:petbridge/features/invite/application/invite_code.dart';
import 'package:petbridge/features/invite/application/join_controller.dart';
import 'package:petbridge/features/invite/presentation/widgets/code_field.dart';
import 'package:petbridge/features/room/presentation/room_title.dart';

/// `/join`: enter a code, then the success state on the same page.
class JoinPage extends ConsumerStatefulWidget {
  const new({this.initialCode, super.key});

  /// The `?code=` parameter; used only when it is exactly a valid code.
  final String? initialCode;

  @override
  ConsumerState<JoinPage> createState() => _JoinPageState();
}

class _JoinPageState extends ConsumerState<JoinPage> {
  final _text = TextEditingController();
  late final JoinController _ctl;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ctl = ref.read(joinControllerProvider.notifier);
    // Providers may not change while the tree builds.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _ctl.prefill(widget.initialCode);
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _text.dispose();
    // Leaving the page forgets the input but keeps a cooldown.
    unawaited(Future.microtask(_ctl.leave));
    super.dispose();
  }

  /// Rebuilds every second while a cooldown runs, and stops after it.
  void _syncTicker(bool blocked) {
    if (blocked && _ticker == null) {
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (!mounted) return;
        final now = ref.read(clockProvider)();
        if (!ref.read(joinControllerProvider).isBlocked(now)) {
          _ticker?.cancel();
          _ticker = null;
        }
        setState(() {});
      });
    } else if (!blocked && _ticker != null) {
      _ticker!.cancel();
      _ticker = null;
    }
  }

  Future<void> _paste() async {
    final data = await Clipboard.getData(Clipboard.kTextPlain);
    if (data?.text case final text?) _ctl.paste(text);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final state = ref.watch(joinControllerProvider);
    final now = ref.watch(clockProvider)();
    final blocked = state.isBlocked(now);
    _syncTicker(blocked);

    // Keep the field in step with paste / prefill / leave.
    if (normalizeCode(_text.text) != state.input) {
      _text.value = codeValue(state.input);
    }

    final result = state.result;
    return Scaffold(
      appBar: AppBar(title: Text(result == null ? l.join_title : '')),
      body: SafeArea(
        child: result == null
            ? _Form(
                state: state,
                now: now,
                text: _text,
                onChanged: _ctl.setInput,
                onPaste: _paste,
                onSubmit: _ctl.submit,
                onGoToRoom: _goToRoom,
              )
            : _Success(
                outcome: result,
                onGoToRoom: () => _goToRoom(result.roomId),
              ),
      ),
    );
  }

  void _goToRoom(String roomId) {
    _ctl.selectRoom(roomId);
    context.go(Routes.home);
  }
}

class _Form extends StatelessWidget {
  const new({
    required this.state,
    required this.now,
    required this.text,
    required this.onChanged,
    required this.onPaste,
    required this.onSubmit,
    required this.onGoToRoom,
  });

  final JoinState state;
  final DateTime now;
  final TextEditingController text;
  final ValueChanged<String> onChanged;
  final VoidCallback onPaste;
  final VoidCallback onSubmit;
  final ValueChanged<String> onGoToRoom;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final blocked = state.isBlocked(now);
    final editable = !blocked && !state.submitting;
    final message = _message(l, blocked);
    final alreadyIn = state.failure?.code == 'ALREADY_MEMBER'
        ? state.failure!.details['room_id']
        : null;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Text(l.join_hint, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 24),
        CodeField(controller: text, enabled: editable, onChanged: onChanged),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: editable ? onPaste : null,
            icon: const Icon(Icons.content_paste),
            label: Text(l.join_paste),
          ),
        ),
        if (message != null)
          Text(
            message,
            key: const Key('join-error'),
            style: TextStyle(color: theme.colorScheme.error),
          ),
        if (alreadyIn is String)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () => onGoToRoom(alreadyIn),
              child: Text(l.join_go_room),
            ),
          ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: state.canSubmit(now) ? onSubmit : null,
          child: state.submitting
              ? const SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(l.join_submit),
        ),
      ],
    );
  }

  /// The cooldown countdown, else the last error. An error that carried a
  /// countdown is dropped once it has run out.
  String? _message(AppLocalizations l, bool blocked) {
    if (blocked) return l.join_retry_in(_mmss(state.remaining(now)));
    final f = state.failure;
    if (f == null || f.details.containsKey('retry_after_seconds')) return null;
    return localizedError(l, f);
  }

  static String _mmss(Duration d) {
    // Round up so the countdown never shows 00:00 while still blocked.
    final secs = (d.inMilliseconds / 1000).ceil();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(secs ~/ 60)}:${two(secs % 60)}';
  }
}

class _Success extends StatelessWidget {
  const new({required this.outcome, required this.onGoToRoom});

  final JoinOutcome outcome;
  final VoidCallback onGoToRoom;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final rewards = outcome.rewards;

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        Icon(Icons.home_rounded, size: 64, color: theme.colorScheme.primary),
        const SizedBox(height: 16),
        Text(
          l.join_success_title,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          l.join_success_body(ownerRoomTitle(l, outcome.owner?.nickname)),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        if (rewards.isNotEmpty) ...[
          _GiftCard(rewards: rewards),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: () =>
                context.pushReplacement(Routes.sharePath(rewards.first.code)),
            child: Text(l.join_share),
          ),
          const SizedBox(height: 8),
          OutlinedButton(onPressed: onGoToRoom, child: Text(l.join_go_room)),
        ] else
          FilledButton(onPressed: onGoToRoom, child: Text(l.join_go_room)),
      ],
    );
  }
}

/// Scales and fades in; the final animation waits for the art.
class _GiftCard extends StatelessWidget {
  const new({required this.rewards});

  final List<IssuedCode> rewards;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.6, end: 1),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutBack,
      builder: (_, v, child) => Opacity(
        opacity: ((v - 0.6) / 0.4).clamp(0, 1),
        child: Transform.scale(scale: v, child: child),
      ),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(
                Icons.card_giftcard,
                size: 40,
                color: theme.colorScheme.tertiary,
              ),
              const SizedBox(height: 8),
              Text(l.join_reward_title, style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final r in rewards)
                Text(
                  formatCode(r.code),
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: 'monospace',
                    letterSpacing: 2,
                  ),
                ),
              const SizedBox(height: 8),
              Text(l.join_reward_body, textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }
}
