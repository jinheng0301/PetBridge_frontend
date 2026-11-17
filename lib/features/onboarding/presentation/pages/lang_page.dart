import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/app/router/routes.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/features/onboarding/application/locale_resolver.dart';
import 'package:petbridge/features/onboarding/application/onboarding_controller.dart';
import 'package:petbridge/features/onboarding/application/ui_locale.dart';
import 'package:petbridge/features/onboarding/presentation/onboarding_scaffold.dart';
import 'package:petbridge/shared/widgets/app_button.dart';

/// Each language in its own script, so it is recognisable whatever the
/// current UI language is.
const Map<String, String> kLanguageNames = {
  'en': 'English',
  'zh-Hans': '简体中文',
  'zh-Hant': '繁體中文',
  'ja': '日本語',
  'ko': '한국어',
};

/// Step 1: native language, which is also the UI language.
class LangPage extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = AppLocalizations.of(context);
    final controller = ref.read(onboardingControllerProvider.notifier);
    final picked = ref.watch(
      onboardingControllerProvider.select((s) => s.draft.nativeLang),
    );
    final selected =
        picked ?? localeTag(resolveAppLocale(ref.watch(systemLocaleProvider)));

    return OnboardingScaffold(
      step: 1,
      title: l.onb_lang_title,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.onb_lang_hint),
          const SizedBox(height: 16),
          for (final tag in kAppLanguageTags)
            ListTile(
              key: ValueKey('lang-$tag'),
              title: Text(kLanguageNames[tag]!),
              selected: tag == selected,
              trailing: tag == selected ? const Icon(Icons.check) : null,
              onTap: () => controller.setLanguage(tag),
            ),
        ],
      ),
      bottom: AppButton(
        label: l.common_continue,
        onPressed: () async {
          if (picked == null) await controller.setLanguage(selected);
          if (context.mounted) await context.push(Routes.onbMbti);
        },
      ),
    );
  }
}
