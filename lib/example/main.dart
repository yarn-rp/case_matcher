import 'package:case_matcher/case_matcher.dart';
import 'package:matcher/matcher.dart';

void main() {
  final intToStringMatcher1 = CaseMatcher<int, String>(
    onDefault: (element) => 'Could not match any case : $element',
  )
    // Just simple specifications.
    ..onEquals(10, (value) => 'Is exactly 10')
    ..onEquals(5, (value) => 'Is exactly 5')
    ..onGreaterThan(5, (value) => '$value is greater than 5');

  final resultFor5 = intToStringMatcher1 << 5; // Is exactly 5
  print('5: $resultFor5');
  final resultFor10 = intToStringMatcher1 << 10; // Is exactly 10
  print('10: $resultFor10');
  final resultFor6 = intToStringMatcher1 << 6; // 6 is greater than 5
  print('6: $resultFor6');
  final intToStringMatcher2 = CaseMatcher<int, String>(
    onDefault: (element) => 'Could not match any case : $element',
  ) // More complex specifications
    ..onCase(
      greaterThan(5) & lessThan(10),
      (value) => '$value is greater than 5 and less than 10',
    )
    ..onCase(
      greaterThan(10) | lessThan(5),
      (value) => '$value is greater than 10 or less than 5',
    );

  final resultFor7 =
      intToStringMatcher2 << 7; // 7 is greater than 5 and less than 10
  print('7: $resultFor7');
  final resultFor11 =
      intToStringMatcher2 << 11; // 11 is greater than 10 or less than 5
  print('11: $resultFor11');
  final resultFor4 =
      intToStringMatcher2 << 4; // 4 is greater than 10 or less than 5
  print('4: $resultFor4');

  final matchersCombined = intToStringMatcher1 +
      intToStringMatcher2; // Contains all the cases from both matchers
}
