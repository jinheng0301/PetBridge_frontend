import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:petbridge/app/router/routes.dart';
import 'package:petbridge/core/l10n/app_localizations.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/auth/presentation/login_page.dart';
import 'package:petbridge/features/auth/presentation/splash_page.dart';
import 'package:petbridge/features/home/presentation/home_shell.dart';
import 'package:petbridge/features/home/presentation/me_tab.dart';
import 'package:petbridge/features/onboarding/presentation/pages/lang_page.dart';
import 'package:petbridge/features/onboarding/presentation/pages/mbti_page.dart';
import 'package:petbridge/features/onboarding/presentation/pages/profile_page.dart';
import 'package:petbridge/features/onboarding/presentation/pages/quiz_page.dart';
import 'package:petbridge/features/onboarding/presentation/pages/quiz_result_page.dart';
import 'package:petbridge/features/onboarding/presentation/pages/reveal_page.dart';
import 'package:petbridge/features/onboarding/presentation/pages/too_young_page.dart';
import 'package:petbridge/features/room/presentation/room_tab.dart';

/// The app's router. Its redirect reads only the [Session]; every session
/// change re-runs it.
final routerProvider = Provider<GoRouter>((ref) {
  final session = ValueNotifier<Session>(ref.read(sessionControllerProvider));
  ref.listen(sessionControllerProvider, (_, next) => session.value = next);

  GoRoute page(String path, Widget child) =>
      GoRoute(path: path, builder: (_, _) => child);

  StatefulShellBranch tab(String path, Widget child) =>
      StatefulShellBranch(routes: [page(path, child)]);

  Widget comingSoon(String Function(AppLocalizations) title) => Builder(
    builder: (context) =>
        ComingSoonTab(title: title(AppLocalizations.of(context))),
  );

  final router = GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: session,
    redirect: (_, state) => redirectFor(session.value, state.uri.path),
    routes: [
      page(Routes.splash, const SplashPage()),
      page(Routes.login, const LoginPage()),
      page(Routes.onbLang, const LangPage()),
      page(Routes.onbMbti, const MbtiPage()),
      page(Routes.onbQuiz, const QuizPage()),
      page(Routes.onbQuizResult, const QuizResultPage()),
      page(Routes.onbReveal, const RevealPage()),
      page(Routes.onbProfile, const ProfilePage()),
      page(Routes.onbTooYoung, const TooYoungPage()),
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(shell: shell),
        branches: [
          tab(Routes.home, const RoomTab()),
          tab(Routes.homeChat, comingSoon((l) => l.home_tab_chat)),
          tab(Routes.homeBag, comingSoon((l) => l.home_tab_bag)),
          tab(Routes.homeMe, const MeTab()),
        ],
      ),
    ],
  );
  ref.onDispose(() {
    router.dispose();
    session.dispose();
  });
  return router;
});
