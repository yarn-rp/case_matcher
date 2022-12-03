import 'package:case_matcher/case_matcher.dart';
import 'package:case_matcher/src/match_case/match_case.dart';
import 'package:mocktail/mocktail.dart';
import 'package:test/test.dart';

class TestType {}

class MatcherA extends Mock implements Matcher {}

class MatcherB extends Mock implements Matcher {}

class MatcherC extends Mock implements Matcher {}

class TestMappedType {}

class TestMappedTypeA extends TestMappedType {}

class TestMappedTypeB extends TestMappedType {}

class TestMappedTypeC extends TestMappedType {}

class TestCaseMatcher extends CaseMatcher<TestType, TestMappedType> {
  TestCaseMatcher({
    required this.matcherEventA,
    required this.onMatcherAHandler,
    required this.matcherEventB,
    required this.onMatcherCHandler,
    required this.onMatcherBHandler,
    required this.matcherEventC,
    required super.onDefault,
  }) {
    onCase(matcherEventA, onMatcherAHandler, priority: 10);
    onCase(matcherEventB, onMatcherBHandler);
    onCase(matcherEventC, onMatcherCHandler);
  }

  final MatcherA matcherEventA;
  final HandleFunction<TestType, TestMappedType> onMatcherAHandler;
  final MatcherB matcherEventB;
  final HandleFunction<TestType, TestMappedType> onMatcherBHandler;
  final MatcherC matcherEventC;
  final HandleFunction<TestType, TestMappedType> onMatcherCHandler;
}

class DuplicateHandlerMatcher extends CaseMatcher<TestType, TestMappedType> {
  DuplicateHandlerMatcher({
    required this.matcherEventA,
    required this.onMatcherAFirstHandler,
    required this.onMatcherASecondHandler,
    required super.onDefault,
  }) {
    onCase(matcherEventA, onMatcherAFirstHandler);
    onCase(matcherEventA, onMatcherASecondHandler);
  }

  final MatcherA matcherEventA;
  final HandleFunction<TestType, TestMappedType> onMatcherAFirstHandler;
  final HandleFunction<TestType, TestMappedType> onMatcherASecondHandler;
}

class MissingHandlerMatcher extends CaseMatcher<TestType, TestMappedType> {
  MissingHandlerMatcher({
    required super.onDefault,
  });
}

void main() {
  final testHandlerResult = TestMappedType();
  TestMappedType testHandler(_) => testHandlerResult;
  group('onCase function', () {
    test(
        'throws AssertionError when handler is registered more than once '
        'within the same priority', () {
      final matcherA = MatcherA();
      final expectedMessage =
          'Matcher $matcherA is already declared with the same priority';

      final expected = throwsA(
        isA<AssertionError>().having(
          (e) => e.message,
          'message',
          expectedMessage,
        ),
      );

      expect(
        () => DuplicateHandlerMatcher(
          onDefault: testHandler,
          onMatcherAFirstHandler: testHandler,
          onMatcherASecondHandler: testHandler,
          matcherEventA: matcherA,
        ),
        expected,
      );
    });

    test('Returns onDefault when specific event handler is not registered ',
        () {
      final valueToBeMatched = TestType();

      final caseMatcher = MissingHandlerMatcher(onDefault: testHandler);
      final result = caseMatcher.match(valueToBeMatched);

      expect(result, testHandlerResult);
    });
  });

  void setupMatcherResult(
    Matcher matcher, {
    required bool result,
    Object? valueToBeMatched,
  }) =>
      when(() => matcher.matches(valueToBeMatched ?? any(), any()))
          .thenAnswer((_) => result);

  void setupMatcherSuccess(
    Matcher matcher, {
    Object? valueToBeMatched,
  }) =>
      setupMatcherResult(
        matcher,
        result: true,
        valueToBeMatched: valueToBeMatched,
      );

  void setupMatcherFailure(
    Matcher matcher, {
    Object? valueToBeMatched,
  }) =>
      setupMatcherResult(
        matcher,
        result: false,
        valueToBeMatched: valueToBeMatched,
      );
  group('match function', () {
    final valueToBeMatched = TestType();

    final onMatchAResult = TestMappedTypeA();
    final onMatchBResult = TestMappedTypeB();
    final onMatchCResult = TestMappedTypeC();
    final matcherA = MatcherA();
    final matcherB = MatcherB();
    final matcherC = MatcherC();

    TestMappedTypeA onMatcherAHandler(v) => onMatchAResult;
    TestMappedTypeB onMatcherBHandler(v) => onMatchBResult;
    TestMappedTypeC onMatcherCHandler(v) => onMatchCResult;

    final matcher = TestCaseMatcher(
      matcherEventA: matcherA,
      onMatcherAHandler: onMatcherAHandler,
      matcherEventB: matcherB,
      onMatcherBHandler: onMatcherBHandler,
      matcherEventC: matcherC,
      onMatcherCHandler: onMatcherCHandler,
      onDefault: testHandler,
    );

    test(' Return TestMappedTypeA test instance when only matcherA matches',
        () {
      // Setup matcherA to match
      setupMatcherSuccess(matcherA, valueToBeMatched: valueToBeMatched);

      // Any other matcher won't match with any value
      <Matcher>[
        matcherB,
        matcherC,
      ].forEach(setupMatcherFailure);

      final result = matcher.match(valueToBeMatched);

      expect(result, onMatchAResult);
    });

    test('Return test TestMappedTypeB instance when only matcherB matches ',
        () {
      // Setup matcherB to match
      setupMatcherSuccess(matcherB, valueToBeMatched: valueToBeMatched);

      // Any other matcher won't match with any value
      <Matcher>[
        matcherA,
        matcherC,
      ].forEach(setupMatcherFailure);

      final result = matcher.match(valueToBeMatched);

      expect(result, onMatchBResult);
    });
    test('Return test TestMappedTypeB instance when only matcherB matches ',
        () {
      // Setup matcherC to match
      setupMatcherSuccess(matcherC, valueToBeMatched: valueToBeMatched);

      // Any other matcher won't match with any value
      <Matcher>[
        matcherA,
        matcherB,
      ].forEach(setupMatcherFailure);

      final result = matcher.match(valueToBeMatched);

      expect(result, onMatchCResult);
    });
  });
}
