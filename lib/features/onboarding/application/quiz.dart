/// The four MBTI dimensions, in letter order.
enum Dimension { ei, sn, tf, jp }

enum QuizChoice { a, b }

/// One two-choice question deciding one dimension. Text lives in the ARB
/// under [promptKey], [aKey] and [bKey].
class QuizQuestion {
  const new({
    required this.dimension,
    required this.promptKey,
    required this.aKey,
    required this.bKey,
    required this.aLetter,
    required this.bLetter,
  });

  final Dimension dimension;
  final String promptKey;
  final String aKey;
  final String bKey;
  final String aLetter;
  final String bLetter;
}

const List<QuizQuestion> kQuizQuestions = [
  QuizQuestion(
    dimension: Dimension.ei,
    promptKey: 'quiz_ei_prompt',
    aKey: 'quiz_ei_a',
    bKey: 'quiz_ei_b',
    aLetter: 'E',
    bLetter: 'I',
  ),
  QuizQuestion(
    dimension: Dimension.sn,
    promptKey: 'quiz_sn_prompt',
    aKey: 'quiz_sn_a',
    bKey: 'quiz_sn_b',
    aLetter: 'S',
    bLetter: 'N',
  ),
  QuizQuestion(
    dimension: Dimension.tf,
    promptKey: 'quiz_tf_prompt',
    aKey: 'quiz_tf_a',
    bKey: 'quiz_tf_b',
    aLetter: 'T',
    bLetter: 'F',
  ),
  QuizQuestion(
    dimension: Dimension.jp,
    promptKey: 'quiz_jp_prompt',
    aKey: 'quiz_jp_a',
    bKey: 'quiz_jp_b',
    aLetter: 'J',
    bLetter: 'P',
  ),
];

/// The MBTI type for one answer per question, in [kQuizQuestions] order.
String scoreQuiz(List<QuizChoice> answers) {
  if (answers.length != kQuizQuestions.length) {
    throw ArgumentError.value(
      answers.length,
      'answers',
      'need exactly ${kQuizQuestions.length} answers',
    );
  }
  return kQuizQuestions.indexed
      .map((e) => answers[e.$1] == QuizChoice.a ? e.$2.aLetter : e.$2.bLetter)
      .join();
}

/// [mbti] with the letter for [d] swapped to its opposite.
String flipDimension(String mbti, Dimension d) {
  final q = kQuizQuestions[d.index];
  final letters = mbti.split('');
  final valid =
      letters.length == 4 &&
      kQuizQuestions.indexed.every(
        (e) => letters[e.$1] == e.$2.aLetter || letters[e.$1] == e.$2.bLetter,
      );
  if (!valid) {
    throw ArgumentError.value(mbti, 'mbti', 'not an MBTI type');
  }
  letters[d.index] = letters[d.index] == q.aLetter ? q.bLetter : q.aLetter;
  return letters.join();
}
