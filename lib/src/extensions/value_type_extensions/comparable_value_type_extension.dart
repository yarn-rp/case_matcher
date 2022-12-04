import 'package:case_matcher/src/case_matcher.dart';
import 'package:case_matcher/src/extensions/extensions.dart';
import 'package:case_matcher/src/match_case/match_case.dart';
import 'package:matcher/matcher.dart';

/// Extension for CaseMatchers with an [Comparable] value type
extension ComparableLeftExtension<Y, T extends Comparable<Y>, Q>
    on CaseMatcher<T, Q> {
  /// Register case using [equals] matcher.
  ///
  /// If you pass an Iterable instance, it will try to match with any of the
  /// elements in the iterable.
  /// If you pass a single instance, it will try to match to that value.
  void onEquals(
    dynamic value,
    HandleFunction<T, Q> handler, {
    int? priority,
  }) {
    if (value is Iterable<T>) {
      onCase(
        value.map(equals).reduce((value, element) => value | element),
        handler,
        priority: priority,
      );
      return;
    }

    onCase(
      equals(value),
      handler,
      priority: priority,
    );
  }

  /// Register case using [equals] matcher.
  ///
  /// If you pass an Iterable instance, it will try to match with any of the
  /// elements in the iterable.
  /// If you pass a single instance, it will try to match to that value.
  void onNotEquals(
    dynamic value,
    HandleFunction<T, Q> handler, {
    int? priority,
  }) {
    if (value is Iterable) {
      onCase(
        value.map(equals).reduce((value, element) => ~(value | element)),
        handler,
        priority: priority,
      );
      return;
    }

    onCase(
      ~equals(value),
      handler,
      priority: priority,
    );
  }

  /// Register case using [greaterThan] matcher.
  void onGreaterThan(
    T value,
    HandleFunction<T, Q> handler, {
    int? priority,
  }) =>
      onCase(
        greaterThan(value),
        handler,
        priority: priority,
      );

  /// Register case using [greaterThanOrEqualTo] matcher.
  void onGreaterThanOrEqualTo(
    T value,
    HandleFunction<T, Q> handler, {
    int? priority,
  }) =>
      onCase(
        greaterThanOrEqualTo(value),
        handler,
        priority: priority,
      );
}
