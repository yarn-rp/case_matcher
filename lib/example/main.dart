import 'package:case_matcher/case_matcher.dart';
import 'package:matcher/matcher.dart';

void main() {
  const number = 3;

  final matcher = CaseMatcher<int, String>(
    onDefault: (_) => "Ain't special",
  )
    // Just simple specifications.
    ..onEquals(1, (value) => 'The very first unit')
    ..onNotEquals(
      [2, 3, 5, 7, 11, 13],
      (value) => 'This is not a prime less than 11',
    )
    ..onCase(
      greaterThanOrEqualTo(11) & lessThanOrEqualTo(19),
      (value) => 'A teen',
    );
  // ignore: unused_local_variable
  final result = matcher << number;
}
