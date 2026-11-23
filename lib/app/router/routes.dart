import 'package:petbridge/features/auth/application/session.dart';

abstract final class Routes {
  static const splash = '/splash';
  static const login = '/login';

  static const onbLang = '/onboarding/lang';
  static const onbMbti = '/onboarding/mbti';
  static const onbQuiz = '/onboarding/quiz';
  static const onbQuizResult = '/onboarding/quiz/result';
  static const onbReveal = '/onboarding/reveal';
  static const onbProfile = '/onboarding/profile';
  static const onbTooYoung = '/onboarding/too-young';

  static const home = '/home';
  static const homeChat = '/home/chat';
  static const homeBag = '/home/bag';
  static const homeMe = '/home/me';

  static const join = '/join';
  static const share = '/share';

  static const roomManage = '/room/:id/manage';

  static String roomManagePath(String id) => '/room/$id/manage';

  static String sharePath(String code) => '$share/$code';
}

/// Where [s] sends a user who is at [location], or `null` to stay.
String? redirectFor(Session s, String location) {
  String? only(bool allowed, String target) => allowed ? null : target;
  return switch (s) {
    SessionUnknown() => only(location == Routes.splash, Routes.splash),
    SessionUnauthenticated() => only(location == Routes.login, Routes.login),
    SessionNeedsOnboarding() => only(
      location.startsWith('/onboarding/'),
      Routes.onbLang,
    ),
    SessionReady() => only(
      location == Routes.home ||
          location.startsWith('${Routes.home}/') ||
          location == Routes.join ||
          location.startsWith('/room/') ||
          location.startsWith('${Routes.share}/'),
      Routes.home,
    ),
  };
}
