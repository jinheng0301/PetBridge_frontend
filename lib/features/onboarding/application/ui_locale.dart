import 'dart:async';
import 'dart:ui';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petbridge/core/storage/prefs_store.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/onboarding/application/locale_resolver.dart';

/// The system locale; overridable in tests.
final systemLocaleProvider = Provider<Locale>(
  (ref) => PlatformDispatcher.instance.locale,
);

/// The UI language: the one the user picked (kept in prefs), else the
/// system language mapped onto the five app languages. Logging out goes
/// back to the system language.
class UiLocale extends Notifier<Locale> {
  @override
  Locale build() {
    ref.listen(sessionControllerProvider, (prev, next) {
      if (next is SessionUnauthenticated && prev is! SessionUnauthenticated) {
        state = _system;
      }
    });
    unawaited(_load());
    return _system;
  }

  Locale get _system => resolveAppLocale(ref.read(systemLocaleProvider));

  Future<void> _load() async {
    final tag = await ref.read(prefsStoreProvider).uiLocale();
    if (tag != null) state = localeFromTag(tag);
  }

  /// Switches the UI to [tag] (one of `kAppLanguageTags`) and remembers it.
  Future<void> set(String tag) async {
    state = localeFromTag(tag);
    await ref.read(prefsStoreProvider).setUiLocale(tag);
  }
}

final uiLocaleProvider = NotifierProvider<UiLocale, Locale>(UiLocale.new);
