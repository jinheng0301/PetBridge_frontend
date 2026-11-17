import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:petbridge/config/env.dart';
import 'package:petbridge/core/network/app_failure.dart';

/// Gets a Google ID token for `POST /auth/login/google`.
abstract interface class GoogleAuth {
  /// The ID token, or `null` when the user cancelled or the device has no
  /// Google account. Other problems throw [AppFailure]
  /// (`GOOGLE_SIGN_IN_FAILED`).
  Future<String?> signIn();

  Future<void> signOut();
}

class PlatformGoogleAuth implements GoogleAuth {
  static const failed = 'GOOGLE_SIGN_IN_FAILED';

  Future<void>? _init;

  Future<void> _ensureInit() => _init ??= GoogleSignIn.instance.initialize(
    serverClientId: Env.googleServerClientId,
  );

  @override
  Future<String?> signIn() async {
    try {
      await _ensureInit();
      final account = await GoogleSignIn.instance.authenticate();
      final token = account.authentication.idToken;
      if (token == null) throw const AppFailure(failed);
      return token;
    } on GoogleSignInException catch (e) {
      if (_isCancel(e)) return null;
      throw AppFailure(failed, details: {'google_code': e.code.name});
    }
  }

  /// Cancelled, interrupted, or (on Android) no account on the device.
  static bool _isCancel(GoogleSignInException e) => switch (e.code) {
    GoogleSignInExceptionCode.canceled ||
    GoogleSignInExceptionCode.interrupted => true,
    GoogleSignInExceptionCode.unknownError =>
      e.description?.startsWith('No credential') ?? false,
    _ => false,
  };

  @override
  Future<void> signOut() async {
    await _ensureInit();
    await GoogleSignIn.instance.signOut();
  }
}

final googleAuthProvider = Provider<GoogleAuth>((ref) => PlatformGoogleAuth());
