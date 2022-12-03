import 'package:case_matcher/case_matcher.dart';

/// A very simple yet powerful extension to provide basic logic operators to
/// Matchers.
extension CaseMatcherOperators<ValueType, MatchResultType>
    on CaseMatcher<ValueType, MatchResultType> {
  /// The operator that is going to be used to match with value.
  MatchResultType operator <<(ValueType value) => match(value);

  /// Sum of the cases of each case matcher.
  ///
  /// This can be understood as adding to first case matcher all the cases of
  /// [another]. The default case and all the other cases from will remain from
  /// [this].
  CaseMatcher<ValueType, MatchResultType> operator +(
    CaseMatcher<ValueType, MatchResultType> another,
  ) {
    final newCaseMatcher = CaseMatcher(
      onDefault: onDefault,
    );
    // Add all cases from this case matcher
    cases.forEach(newCaseMatcher.onMatchCase);
    // Add all cases from the other case matcher
    another.cases.forEach(newCaseMatcher.onMatchCase);

    return newCaseMatcher;
  }
}
