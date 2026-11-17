import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:petbridge/features/onboarding/application/quiz.dart';

void main() {
  const a = QuizChoice.a;
  const b = QuizChoice.b;

  test('questions cover EI, SN, TF, JP in order with A as E, S, T, J', () {
    expect(kQuizQuestions.map((q) => q.dimension), [
      Dimension.ei,
      Dimension.sn,
      Dimension.tf,
      Dimension.jp,
    ]);
    expect(kQuizQuestions.map((q) => q.aLetter).join(), 'ESTJ');
    expect(kQuizQuestions.map((q) => q.bLetter).join(), 'INFP');
  });

  test('all A gives ESTJ', () {
    expect(scoreQuiz([a, a, a, a]), 'ESTJ');
  });

  test('all B gives INFP', () {
    expect(scoreQuiz([b, b, b, b]), 'INFP');
  });

  test('mixed a,b,a,b gives ENTP', () {
    expect(scoreQuiz([a, b, a, b]), 'ENTP');
  });

  test('flip TF of ENTP gives ENFP', () {
    expect(flipDimension('ENTP', Dimension.tf), 'ENFP');
  });

  test('flip is its own inverse on every dimension', () {
    for (final d in Dimension.values) {
      expect(flipDimension(flipDimension('ISFJ', d), d), 'ISFJ');
    }
    expect(flipDimension('ISFJ', Dimension.ei), 'ESFJ');
    expect(flipDimension('ISFJ', Dimension.jp), 'ISFP');
  });

  test('rejects 3 answers', () {
    expect(() => scoreQuiz([a, b, a]), throwsArgumentError);
  });

  test('flip rejects a bogus type', () {
    expect(() => flipDimension('ABCD', Dimension.ei), throwsArgumentError);
  });

  test('every question key exists in the en ARB', () {
    final arb = jsonDecode(
      File('assets/l10n/app_en.arb').readAsStringSync(),
    ) as Map<String, dynamic>;
    for (final q in kQuizQuestions) {
      for (final key in [q.promptKey, q.aKey, q.bKey]) {
        expect(arb[key], isA<String>(), reason: key);
      }
    }
  });
}
