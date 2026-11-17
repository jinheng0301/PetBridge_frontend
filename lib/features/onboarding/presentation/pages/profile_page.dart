import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/app/router/routes.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/features/onboarding/application/nickname.dart';
import 'package:petbridge/features/onboarding/application/onboarding_controller.dart';
import 'package:petbridge/features/onboarding/presentation/onboarding_scaffold.dart';
import 'package:petbridge/shared/widgets/app_button.dart';
import 'package:petbridge/shared/widgets/error_text.dart';

/// Step 5: nickname and age, then submit. "Under 13" goes to the
/// too-young page instead of submitting.
class ProfilePage extends ConsumerStatefulWidget {
  const new({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  late final TextEditingController _nickname;

  /// Format errors show only once the user has typed something.
  late bool _touched;

  @override
  void initState() {
    super.initState();
    final saved = ref.read(onboardingControllerProvider).draft.nickname;
    _nickname = TextEditingController(text: saved);
    _touched = saved.isNotEmpty;
  }

  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  String? _nicknameError(AppLocalizations l, OnboardingState s) {
    if (s.badFields.contains('nickname')) return l.onb_nickname_err_server;
    if (!_touched) return null;
    return switch (validateNickname(s.draft.nickname)) {
      NicknameError.empty => l.onb_nickname_err_empty,
      NicknameError.tooLong => l.onb_nickname_err_too_long,
      NicknameError.invalidChars => l.onb_nickname_err_invalid,
      null => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final s = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final age = s.draft.age;
    final nicknameOk = validateNickname(s.draft.nickname) == null;

    VoidCallback? onSubmit;
    if (nicknameOk && age != null) {
      onSubmit = age == AgeChoice.under13
          ? () => context.push(Routes.onbTooYoung)
          : controller.submit;
    }

    return OnboardingScaffold(
      step: 5,
      title: l.onb_profile_title,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            key: const ValueKey('nickname'),
            controller: _nickname,
            enabled: !s.submitting,
            textInputAction: TextInputAction.done,
            decoration: InputDecoration(
              labelText: l.onb_nickname_label,
              helperText: l.onb_nickname_hint,
              errorText: _nicknameError(l, s),
              border: const OutlineInputBorder(),
            ),
            onChanged: (v) {
              _touched = true;
              controller.setNickname(v);
            },
          ),
          const SizedBox(height: 24),
          Text(l.onb_age_label, style: Theme.of(context).textTheme.titleMedium),
          if (s.badFields.contains('age_band'))
            Text(
              l.onb_field_invalid,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          for (final (choice, label) in [
            (AgeChoice.under13, l.onb_age_under13),
            (AgeChoice.teen, l.onb_age_teen),
            (AgeChoice.adult, l.onb_age_adult),
          ])
            ListTile(
              key: ValueKey('age-${choice.name}'),
              contentPadding: EdgeInsets.zero,
              enabled: !s.submitting,
              leading: Icon(
                choice == age
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
              ),
              title: Text(label),
              selected: choice == age,
              onTap: () => controller.setAge(choice),
            ),
        ],
      ),
      bottom: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ErrorText(s.failure),
          if (s.failure != null) const SizedBox(height: 8),
          AppButton(
            key: const ValueKey('submit'),
            label: l.onb_submit,
            loading: s.submitting,
            onPressed: onSubmit,
          ),
        ],
      ),
    );
  }
}
