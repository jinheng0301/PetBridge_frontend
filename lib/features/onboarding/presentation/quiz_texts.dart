import 'package:petbridge/core/l10n/app_localizations.dart';

/// Looks up the ARB text for a `QuizQuestion` key (`quiz_<dim>_<part>`).
String quizText(AppLocalizations l, String key) => switch (key) {
  'quiz_ei_prompt' => l.quiz_ei_prompt,
  'quiz_ei_a' => l.quiz_ei_a,
  'quiz_ei_b' => l.quiz_ei_b,
  'quiz_sn_prompt' => l.quiz_sn_prompt,
  'quiz_sn_a' => l.quiz_sn_a,
  'quiz_sn_b' => l.quiz_sn_b,
  'quiz_tf_prompt' => l.quiz_tf_prompt,
  'quiz_tf_a' => l.quiz_tf_a,
  'quiz_tf_b' => l.quiz_tf_b,
  'quiz_jp_prompt' => l.quiz_jp_prompt,
  'quiz_jp_a' => l.quiz_jp_a,
  'quiz_jp_b' => l.quiz_jp_b,
  _ => throw ArgumentError.value(key, 'key', 'unknown quiz text'),
};
