import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/app/router/routes.dart';
import 'package:petbridge/config/env.dart';
import 'package:petbridge/config/error_codes.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/invite/application/codes.dart';
import 'package:petbridge/features/invite/application/codes_provider.dart';
import 'package:petbridge/features/invite/application/invite_code.dart';
import 'package:petbridge/features/invite/data/poster_sink.dart';
import 'package:petbridge/features/invite/presentation/widgets/poster_canvas.dart';

/// `/share/:code`: the poster for one of the user's unused codes, with
/// "Save to gallery" and "Share".
class SharePage extends ConsumerWidget {
  const new({required this.code, super.key});

  /// The route parameter, as given.
  final String code;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final valid = validCodeParam(code);
    final codes = ref.watch(codesProvider);

    final Widget body;
    if (valid != null && !codes.hasValue && codes.isLoading) {
      body = const Center(child: CircularProgressIndicator());
    } else if (valid != null && !codes.hasValue && codes.hasError) {
      body = _LoadFailed(failure: AppFailure.from(codes.error!));
    } else {
      final match = (codes.value ?? const <InviteCode>[])
          .where((c) => c.code == valid && c.status == CodeStatus.unused)
          .firstOrNull;
      body = match == null ? const _Unavailable() : _Poster(code: match);
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.share_title)),
      body: SafeArea(child: body),
    );
  }
}

/// The codes could not be loaded, so whether [SharePage.code] can be
/// shared is unknown.
class _LoadFailed extends ConsumerWidget {
  const new({required this.failure});

  final AppFailure failure;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(localizedError(l, failure), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () async {
                try {
                  await ref.read(codesProvider.notifier).refresh();
                } on AppFailure {
                  // Still failing; the error stays on screen.
                }
              },
              child: Text(l.common_retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _Unavailable extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.share_unavailable, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go(Routes.homeBag),
              child: Text(MaterialLocalizations.of(context).backButtonTooltip),
            ),
          ],
        ),
      ),
    );
  }
}

class _Poster extends ConsumerStatefulWidget {
  const new({required this.code});

  final InviteCode code;

  @override
  ConsumerState<_Poster> createState() => _PosterState();
}

class _PosterState extends ConsumerState<_Poster> {
  final GlobalKey _boundary = GlobalKey();
  var _busy = false;

  String get _link => shareLink(Env.shareBaseUrl, widget.code.code);

  /// Captures the poster and hands it to [use]; any failure is reported.
  Future<void> _withPng(
    Future<String?> Function(Uint8List png, AppLocalizations l) use,
  ) async {
    final l = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _busy = true);
    String? message;
    try {
      message = await use(await capturePng(_boundary), l);
    } on Object {
      message = l.share_failed;
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    if (message != null) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _save() => _withPng((png, l) async {
    final result = await ref.read(posterSinkProvider).saveToGallery(png);
    return switch (result) {
      SaveResult.saved => l.share_saved,
      SaveResult.denied => l.share_denied,
    };
  });

  Future<void> _share() => _withPng((png, l) async {
    final text = l.share_text(formatCode(widget.code.code), _link);
    await ref.read(posterSinkProvider).share(png, text);
    return null;
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final session = ref.watch(sessionControllerProvider);
    final petType = session is SessionReady ? session.me.petType : null;
    final c = widget.code;

    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: FittedBox(
                child: Material(
                  elevation: 2,
                  clipBehavior: Clip.antiAlias,
                  borderRadius: BorderRadius.circular(12),
                  child: RepaintBoundary(
                    key: _boundary,
                    child: PosterCanvas(
                      petType: petType ?? '',
                      code: c.code,
                      memberCount: c.roomMemberCount,
                      capacity: c.roomCapacity,
                      link: _link,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _busy ? null : _save,
                  icon: const Icon(Icons.download),
                  label: Text(l.share_save),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _busy ? null : _share,
                  icon: const Icon(Icons.share),
                  label: Text(l.share_system),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
