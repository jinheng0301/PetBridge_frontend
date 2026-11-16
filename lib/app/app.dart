import 'package:material_ui/material_ui.dart';
import 'package:petbridge/app/theme/app_theme.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';

/// Root widget. Routing arrives in Task 6; until then a placeholder home.
class PetBridgeApp extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => _ClampTextScale(child: child!),
      home: const _PlaceholderHome(),
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

class _PlaceholderHome extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          AppLocalizations.of(context).appTitle,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
