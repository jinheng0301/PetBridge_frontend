import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Non-secret local preferences.
class PrefsStore {
  new([SharedPreferencesAsync? prefs])
    : _prefs = prefs ?? SharedPreferencesAsync();

  static const _uiLocaleKey = 'ui_locale';

  final SharedPreferencesAsync _prefs;

  /// The UI language the user picked, as a BCP-47 tag (e.g. `zh-Hant`).
  Future<String?> uiLocale() => _prefs.getString(_uiLocaleKey);

  Future<void> setUiLocale(String tag) => _prefs.setString(_uiLocaleKey, tag);

  Future<void> clear() => _prefs.remove(_uiLocaleKey);
}

final prefsStoreProvider = Provider<PrefsStore>((ref) => PrefsStore());
