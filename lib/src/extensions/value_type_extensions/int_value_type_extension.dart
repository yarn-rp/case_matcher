import 'package:case_matcher/src/case_matcher.dart';
import 'package:case_matcher/src/extensions/matcher_operators/matcher_operators.dart';
import 'package:case_matcher/src/match_case/match_case.dart';
import 'package:matcher/matcher.dart';

/// Extension for CaseMatchers with an [int] value type
extension IntLeftExtension<Q> on CaseMatcher<int, Q> {
  /// Register case using [equals] matcher.
  void onEquals(
    int value,
    HandleFunction<int, Q> handler, {
    int? priority,
  }) =>
      onCase(
        equals(value),
        handler,
        priority: priority,
      );

  /// Register case using [equals] matcher and denying it.
  void onNotEquals(
    int value,
    HandleFunction<int, Q> handler, {
    int? priority,
  }) =>
      onCase(
        ~equals(value),
        handler,
        priority: priority,
      );

  /// Register case using [greaterThan] matcher.
  void onGreaterThan(
    int value,
    HandleFunction<int, Q> handler, {
    int? priority,
  }) =>
      onCase(
        greaterThan(value),
        handler,
        priority: priority,
      );

  /// Register case using [greaterThanOrEqualTo] matcher.
  void onGreaterThanOrEqualTo(
    int value,
    HandleFunction<int, Q> handler, {
    int? priority,
  }) =>
      onCase(
        greaterThanOrEqualTo(value),
        handler,
        priority: priority,
      );
}
