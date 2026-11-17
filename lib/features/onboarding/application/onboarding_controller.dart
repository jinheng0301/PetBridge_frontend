import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:petbridge/core/network/app_failure.dart';
import 'package:petbridge/features/auth/application/session.dart';
import 'package:petbridge/features/auth/application/session_controller.dart';
import 'package:petbridge/features/onboarding/application/nickname.dart';
import 'package:petbridge/features/onboarding/application/quiz.dart';
import 'package:petbridge/features/onboarding/application/ui_locale.dart';
import 'package:petbridge/features/onboarding/data/onboarding_repository.dart';

enum AgeChoice {
  under13(null),
  teen('13_17'),
  adult('18_plus');

  new(this.band);

  /// The backend `age_band`; `null` for under-13, which is never submitted.
  final String? band;
}

/// What the user has entered so far. Lives in memory only: if the app is
/// killed, onboarding starts again from the first step.
class OnboardingDraft {
  const new({this.nativeLang, this.mbti, this.nickname = '', this.age});

  final String? nativeLang;
  final String? mbti;
  final String nickname;
  final AgeChoice? age;

  OnboardingDraft copyWith({
    String? nativeLang,
    String? mbti,
    String? nickname,
    AgeChoice? age,
  }) => OnboardingDraft(
    nativeLang: nativeLang ?? this.nativeLang,
    mbti: mbti ?? this.mbti,
    nickname: nickname ?? this.nickname,
    age: age ?? this.age,
  );

  /// Everything needed for `POST /me/onboarding` is filled in and valid.
  bool get canSubmit =>
      nativeLang != null &&
      mbti != null &&
      validateNickname(nickname) == null &&
      age?.band != null;
}

class OnboardingState {
  const new({
    this.draft = const OnboardingDraft(),
    this.quizResult,
    this.submitting = false,
    this.failure,
    this.badFields = const {},
  });

  final OnboardingDraft draft;

  /// The quiz's type while the user reviews it on the result page.
  final String? quizResult;
  final bool submitting;

  /// The last submit failure, cleared on the next submit.
  final AppFailure? failure;

  /// Fields the server rejected (`VALIDATION_FAILED` `details.fields`).
  final Set<String> badFields;

  OnboardingState copyWith({
    OnboardingDraft? draft,
    String? quizResult,
    bool? submitting,
    AppFailure? Function()? failure,
    Set<String>? badFields,
  }) => OnboardingState(
    draft: draft ?? this.draft,
    quizResult: quizResult ?? this.quizResult,
    submitting: submitting ?? this.submitting,
    failure: failure == null ? this.failure : failure(),
    badFields: badFields ?? this.badFields,
  );
}

/// Holds the onboarding draft across the steps. Not auto-disposed, so
/// going back and forth between pages keeps what was entered; it resets
/// when the session ends.
class OnboardingController extends Notifier<OnboardingState> {
  @override
  OnboardingState build() {
    ref.listen(sessionControllerProvider, (prev, next) {
      if (next is SessionUnauthenticated && prev is! SessionUnauthenticated) {
        state = const OnboardingState();
      }
    });
    return const OnboardingState();
  }

  void _draft(OnboardingDraft d) => state = state.copyWith(draft: d);

  /// Sets `native_lang` and switches the UI language to it.
  Future<void> setLanguage(String tag) async {
    _draft(state.draft.copyWith(nativeLang: tag));
    await ref.read(uiLocaleProvider.notifier).set(tag);
  }

  void setMbti(String mbti) => _draft(state.draft.copyWith(mbti: mbti));

  void setNickname(String nickname) {
    state = state.copyWith(
      draft: state.draft.copyWith(nickname: nickname),
      badFields: state.badFields.difference({'nickname'}),
    );
  }

  void setAge(AgeChoice age) {
    state = state.copyWith(
      draft: state.draft.copyWith(age: age),
      badFields: state.badFields.difference({'age_band'}),
    );
  }

  /// Scores the quiz and keeps the result for the result page.
  void setQuizAnswers(List<QuizChoice> answers) =>
      state = state.copyWith(quizResult: scoreQuiz(answers));

  void flipQuizDimension(Dimension d) {
    final r = state.quizResult;
    if (r == null) return;
    state = state.copyWith(quizResult: flipDimension(r, d));
  }

  /// Takes the quiz result as the chosen MBTI.
  void confirmQuizResult() {
    final r = state.quizResult;
    if (r != null) setMbti(r);
  }

  /// Sends the draft, then reloads `/me` so the session becomes ready.
  /// Ignored while a submit is running or the draft is incomplete. Failures
  /// land in [OnboardingState.failure]; the draft stays for a retry.
  Future<void> submit() async {
    final d = state.draft;
    if (state.submitting || !d.canSubmit) return;
    state = state.copyWith(
      submitting: true,
      failure: () => null,
      badFields: const {},
    );
    try {
      await ref
          .read(onboardingRepositoryProvider)
          .complete(
            nativeLang: d.nativeLang!,
            mbti: d.mbti!,
            nickname: d.nickname.trim(),
            ageBand: d.age!.band!,
            tz: await ref.read(deviceTimeZoneProvider)(),
          );
      await ref.read(sessionControllerProvider.notifier).refreshMe();
      state = state.copyWith(submitting: false);
    } on AppFailure catch (f) {
      state = state.copyWith(
        submitting: false,
        failure: () => f,
        badFields: _fieldsOf(f),
      );
    }
  }

  static Set<String> _fieldsOf(AppFailure f) {
    if (f.code != 'VALIDATION_FAILED') return const {};
    final fields = f.details['fields'];
    return fields is List ? {for (final x in fields) x.toString()} : const {};
  }
}

final onboardingControllerProvider =
    NotifierProvider<OnboardingController, OnboardingState>(
      OnboardingController.new,
    );
