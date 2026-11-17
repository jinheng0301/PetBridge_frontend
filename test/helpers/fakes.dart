import 'package:mocktail/mocktail.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/core/storage/prefs_store.dart';
import 'package:petbridge/core/storage/secure_store.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/auth/data/auth_repository.dart';
import 'package:petbridge/features/auth/data/google_auth.dart';

class MockAuthRepository extends Mock implements AuthRepository;

class MockGoogleAuth extends Mock implements GoogleAuth;

class MockPrefsStore extends Mock implements PrefsStore;

/// A [SessionController] that starts in [initial] and never touches the
/// network. Login calls throw [loginError] when set.
class FakeSessionController extends SessionController {
  new(this.initial);

  final Session initial;
  AppFailure? loginError;
  final List<String> calls = [];

  @override
  Session build() => initial;

  @override
  Future<void> get restored => Future.value();

  @override
  Future<void> loginDev(String email) => _login('dev:$email');

  @override
  Future<void> loginGoogle() => _login('google');

  @override
  Future<void> loginApple() => _login('apple');

  Future<void> _login(String call) async {
    calls.add(call);
    final e = loginError;
    if (e != null) throw e;
  }

  @override
  Future<void> refreshMe() async {
    calls.add('refreshMe');
  }

  @override
  Future<void> logout() async {
    calls.add('logout');
    state = const SessionUnauthenticated();
  }

  /// Lets tests move the session like the real controller would.
  Session get current => state;
  set current(Session s) => state = s;
}

/// In-memory [SecureStore].
class MemorySecureStore implements SecureStore {
  new([this.tokens]);

  TokenPair? tokens;
  int clearCount = 0;

  @override
  Future<TokenPair?> read() async => tokens;

  @override
  Future<void> write(TokenPair t) async => tokens = t;

  @override
  Future<void> clear() async {
    clearCount++;
    tokens = null;
  }
}

/// A [MockPrefsStore] that remembers the UI locale and succeeds otherwise.
MockPrefsStore stubPrefs([String? uiLocale]) {
  final prefs = MockPrefsStore();
  var stored = uiLocale;
  when(prefs.uiLocale).thenAnswer((_) async => stored);
  when(() => prefs.setUiLocale(any())).thenAnswer((inv) async {
    stored = inv.positionalArguments.first as String;
  });
  when(prefs.clear).thenAnswer((_) async => stored = null);
  return prefs;
}
