import 'package:matcher/matcher.dart';

/// A very simple yet powerful extension to provide basic logic operators to
/// Matchers.
extension LogicOperatorsMatcherExtension on Matcher {
  /// Applies the [allOf] matcher to both matchers.
  ///
  /// Matches in case this and [other] matches both match at the same time.
  Matcher operator &(Matcher other) => allOf(this, other);

  /// Applies the [anyOf] matcher to both matchers.
  ///
  /// Matches in case this or [other] match.
  Matcher operator |(Matcher other) => anyOf(this, other);

  /// Applies the [isNot] matcher to the given matcher.
  ///
  /// Matches in case this match doesn't match.
  Matcher operator ~() => isNot(this);
}
