import 'package:case_matcher/src/constants/case_matcher_constants.dart';
import 'package:matcher/matcher.dart';

/// Function that returns value of type [MatchResultType] given a [ValueType]
/// instance.
typedef HandleFunction<ValueType, MatchResultType> = MatchResultType Function(
  ValueType value,
);

/// {@template match_case}
/// Representation for a case in a `CaseMatcher`
///
/// [ValueType] represents the type of the value that is being matched.
/// [MatchResultType] represents the type of the result of the match
/// Throws AssertionError if [priority] is not between 0 and [kMaxPriority].
/// {@endtemplate}.
class MatchCase<ValueType, MatchResultType> {
  /// {@macro match_case}
  MatchCase({
    required this.matcher,
    required this.handler,
    required this.priority,
  })  : assert(
          priority >= kMinPriority,
          'Priority cannot be less than [_kMinPriority]. '
          'Use double.infinity if you want to declare the lowest priority',
        ),
        assert(
          priority <= kMaxPriority,
          'Priority cannot be greater than. [_kMaxPriority] '
          'Use 0 if you want to declare the highest priority',
        );

  /// Matcher that is going to be used to match the value
  final Matcher matcher;

  /// Function that is going to be executed if [matcher] matches the value
  final HandleFunction<ValueType, MatchResultType> handler;

  /// The priority of the case. A case with bigger priority means that it will
  /// match over another case with lower priority.
  final int priority;
}
