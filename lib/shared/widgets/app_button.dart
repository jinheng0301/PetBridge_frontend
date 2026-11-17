import 'package:material_ui/material_ui.dart';

/// Full-width primary button. While [loading] it shows a spinner and
/// ignores taps; `onPressed == null` disables it.
class AppButton extends StatelessWidget {
  const new({
    required this.label,
    required this.onPressed,
    super.key,
    this.loading = false,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : Text(label);
    final onTap = loading ? null : onPressed;
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: icon == null || loading
          ? FilledButton(onPressed: onTap, child: child)
          : FilledButton.icon(onPressed: onTap, icon: icon, label: child),
    );
  }
}
