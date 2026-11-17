import 'package:material_ui/material_ui.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/features/pet/presentation/pet_catalog.dart';

/// Placeholder pet: a colored circle with the localized pet name. Real art
/// replaces this later without changing callers.
class PetView extends StatelessWidget {
  const new({required this.petType, super.key, this.size = 160});

  final String petType;
  final double size;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final color = _colorFor(petType);
    final onColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.dark
        ? Colors.white
        : Colors.black87;
    return SizedBox.square(
      dimension: size,
      child: Container(
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        alignment: Alignment.center,
        padding: EdgeInsets.all(size * 0.12),
        child: Text(
          petName(l, petType),
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: onColor),
        ),
      ),
    );
  }
}

/// A hue derived from a stable (FNV-1a) hash of [petType]. `String.hashCode`
/// is not guaranteed stable across runs, so it is not used here.
Color _colorFor(String petType) {
  var h = 0x811c9dc5;
  for (final unit in petType.codeUnits) {
    h = ((h ^ unit) * 0x01000193) & 0xffffffff;
  }
  final hue = (h % 360).toDouble();
  return HSLColor.fromAHSL(1, hue, 0.55, 0.62).toColor();
}
