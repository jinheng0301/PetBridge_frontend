enum NicknameError { empty, tooLong, invalidChars }

const int kNicknameMaxRunes = 20;

/// Client-side format pre-check. The server has the final say (it also
/// rejects zero-width and other invisible characters).
NicknameError? validateNickname(String raw) {
  final n = raw.trim();
  if (n.isEmpty) return NicknameError.empty;
  if (n.runes.length > kNicknameMaxRunes) return NicknameError.tooLong;
  if (n.runes.any(_isControl)) return NicknameError.invalidChars;
  return null;
}

/// C0, DEL and C1 control characters (Unicode category Cc).
bool _isControl(int r) => r < 0x20 || (r >= 0x7F && r <= 0x9F);
