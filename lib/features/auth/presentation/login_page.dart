import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/config/env.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/shared/widgets/app_button.dart';
import 'package:petbridge/shared/widgets/error_text.dart';

class LoginPage extends ConsumerStatefulWidget {
  const new({
    super.key,
    this.devLoginEnabled = Env.devLogin,
    this.appleEnabled = Env.appleLoginEnabled,
  });

  /// Shows the developer email login (dev builds only).
  final bool devLoginEnabled;

  /// When false the Apple button only says "coming soon".
  final bool appleEnabled;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  static const defaultDevEmail = 'dev-a@local';

  final _email = TextEditingController(text: defaultDevEmail);
  bool _busy = false;
  AppFailure? _failure;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  SessionController get _session =>
      ref.read(sessionControllerProvider.notifier);

  Future<void> _run(Future<void> Function() login) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _failure = null;
    });
    try {
      await login();
    } on AppFailure catch (f) {
      if (mounted) setState(() => _failure = f);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _apple() {
    if (!widget.appleEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context).login_apple_coming_soon),
        ),
      );
      return;
    }
    unawaited(_run(_session.loginApple));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.pets,
                    size: 44,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 12),
                Text(l.appTitle, style: theme.textTheme.headlineMedium),
                const SizedBox(height: 32),
                AppButton(
                  label: l.login_google,
                  icon: const Icon(Icons.login),
                  onPressed: _busy ? null : () => _run(_session.loginGoogle),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: _busy ? null : _apple,
                    icon: const Icon(Icons.apple),
                    label: Text(l.login_apple),
                  ),
                ),
                if (widget.devLoginEnabled) ...[
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          l.login_dev_title,
                          style: theme.textTheme.labelMedium,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _email,
                          enabled: !_busy,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          decoration: InputDecoration(
                            labelText: l.login_dev_email_label,
                            border: const OutlineInputBorder(),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton.tonal(
                        onPressed: _busy
                            ? null
                            : () => _run(
                                () => _session.loginDev(_email.text.trim()),
                              ),
                        child: Text(l.login_dev_submit),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                ErrorText(_failure),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
