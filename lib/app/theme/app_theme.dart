import 'package:material_ui/material_ui.dart';

/// Material 3 with a single seed colour until the visual design lands.
abstract final class AppTheme {
  static const Color seed = Color(0xFFFF8A65);

  static ThemeData light() => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seed),
  );

  static ThemeData dark() => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seed,
      brightness: Brightness.dark,
    ),
  );
}
