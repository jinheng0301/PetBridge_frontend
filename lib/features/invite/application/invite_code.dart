/// Invite code format rules. These are only a pre-check before the server
/// decides; they never say whether a code can actually be used.
library;

/// The 32 characters a code may use (no 0/O, 1/I).
const kCodeAlphabet = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';

const kCodeLength = 8;

final RegExp _codePattern = RegExp(r'^[2-9A-HJ-NP-Z]{8}$');
final RegExp _linkCode = RegExp('/j/([A-Za-z0-9-]+)');

/// Upper-cases [raw], keeps only alphabet characters and cuts it to 8.
String normalizeCode(String raw) {
  final buf = StringBuffer();
  for (final ch in raw.toUpperCase().split('')) {
    if (buf.length == kCodeLength) break;
    if (kCodeAlphabet.contains(ch)) buf.write(ch);
  }
  return buf.toString();
}

/// Like [normalizeCode], but a pasted share link gives its `/j/<code>` part.
String normalizePaste(String text) =>
    normalizeCode(_linkCode.firstMatch(text)?.group(1) ?? text);

bool isValidCode(String code) => _codePattern.hasMatch(code);

/// `ABCD2345` → `ABCD-2345`; shorter input gets the hyphen once it passes 4.
String formatCode(String code) =>
    code.length > 4 ? '${code.substring(0, 4)}-${code.substring(4)}' : code;

/// [raw] when it is exactly a valid code, otherwise `null`. For route and
/// deep-link parameters, which are checked as they are, not normalized.
String? validCodeParam(String? raw) =>
    raw != null && _codePattern.hasMatch(raw) ? raw : null;

/// `{base}/j/{code}`, with any trailing `/` on [base] removed.
String shareLink(String base, String code) =>
    '${base.replaceFirst(RegExp(r'/+$'), '')}/j/$code';
