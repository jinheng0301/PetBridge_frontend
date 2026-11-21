import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/features/invite/application/invite_code.dart';

/// The 8-character code input. Whatever is typed is normalized and shown as
/// `XXXX-XXXX`; [onChanged] gets the shown text (hyphen included).
class CodeField extends StatelessWidget {
  const new({
    required this.controller,
    required this.onChanged,
    this.enabled = true,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      enabled: enabled,
      onChanged: onChanged,
      autocorrect: false,
      enableSuggestions: false,
      textAlign: TextAlign.center,
      textCapitalization: TextCapitalization.characters,
      keyboardType: TextInputType.visiblePassword,
      inputFormatters: const [CodeInputFormatter()],
      style: theme.textTheme.headlineSmall?.copyWith(
        fontFamily: 'monospace',
        letterSpacing: 4,
      ),
      decoration: const InputDecoration(
        hintText: 'XXXX-XXXX',
        border: OutlineInputBorder(),
      ),
    );
  }
}

/// Normalizes the edit and re-inserts the hyphen; the cursor goes to the end.
class CodeInputFormatter extends TextInputFormatter {
  const new();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) => codeValue(normalizeCode(newValue.text));
}

/// The field value showing [code] with the cursor at the end.
TextEditingValue codeValue(String code) {
  final text = formatCode(code);
  return TextEditingValue(
    text: text,
    selection: TextSelection.collapsed(offset: text.length),
  );
}
