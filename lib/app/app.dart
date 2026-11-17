import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/app/router/app_router.dart';
import 'package:petbridge/app/theme/app_theme.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/features/onboarding/application/ui_locale.dart';

/// Localization delegates for the app. The material and cupertino ones
/// come from `material_ui` / `cupertino_ui`; gen-l10n's default list uses
/// `flutter_localizations`' versions, which those packages' widgets do not
/// read, so AppBar etc. would fail in every language but English.
const List<LocalizationsDelegate<dynamic>> appLocalizationsDelegates = [
  AppLocalizations.delegate,
  ...GlobalMaterialLocalizations.delegates,
];

/// Root widget: router, theme and the UI language.
class PetBridgeApp extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: ref.watch(routerProvider),
      locale: ref.watch(uiLocaleProvider),
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      localizationsDelegates: appLocalizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => _ClampTextScale(child: child!),
    );
  }
}

/// Keeps system font scaling within 0.8–1.3 so layouts stay usable.
class _ClampTextScale extends StatelessWidget {
  const new({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    return MediaQuery(
      data: media.copyWith(
        textScaler: media.textScaler.clamp(
          minScaleFactor: 0.8,
          maxScaleFactor: 1.3,
        ),
      ),
      child: child,
    );
  }
}
