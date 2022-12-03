import 'dart:collection';

import 'package:case_matcher/src/constants/case_matcher_constants.dart';
import 'package:case_matcher/src/match_case/match_case.dart';
import 'package:matcher/matcher.dart';
import 'package:meta/meta.dart';

/// {@template case_matcher}
/// Base class to case declaration functionality.
///
/// Provide matchers cases using the [onCase] function, where you can create
/// your own custom matchers and build code expressively
///
/// It's required to pass a [onDefault] function in case you don't match any
/// case
/// {@endtemplate}
abstract class CaseMatcher<ValueType, MatchResultType> {
  /// {@macro case_matcher}
  CaseMatcher({
    required this.onDefault,
  });

  /// Value that is going to be matched to all different matchers defined.

  /// Default function that is going to be applied to value in case there is
  /// not matching with any case.
  final HandleFunction<ValueType, MatchResultType> onDefault;

  /// All matches cases
  final HashMap<int, HashSet<MatchCase<ValueType, MatchResultType>>>
      _priorityToCasesMap =
      HashMap<int, HashSet<MatchCase<ValueType, MatchResultType>>>.fromIterable(
    List<num>.generate(
      kMaxPriority,
      (index) => index,
    ),
    key: (priority) => int.parse(priority.toString()),
    value: (_) => HashSet.identity(),
  );

  /// Add new case to [_priorityToCasesMap] so it can be used to match later on.
  ///
  /// Throws [AssertionError] if [priority] is not between 0 and [kMaxPriority].
  /// Throws [AssertionError] if there is another matcher with the same priority
  /// already in the map.
  @protected
  @visibleForTesting
  void on(
    Matcher matcher,
    HandleFunction<ValueType, MatchResultType> handler, {
    int? priority,
  }) {
    // Just a mapping to priorities, so you can handle priorities in a human way
    final realPriority = priority ?? kDefaultPriority;
    assert(
      realPriority <= kMaxPriority,
      'Priority must be less or equals than $kMaxPriority',
    );
    assert(
      realPriority >= 0,
      'Priority must be greater or equals than 0',
    );

    // Verify that matcher is not already declared.
    final cases = _priorityToCasesMap[realPriority]!;
    assert(
      !cases.any((matchCase) => matchCase.matcher == matcher),
      'Matcher $matcher is already declared with the same priority',
    );

    cases.add(
      MatchCase(
        matcher: matcher,
        handler: handler,
        priority: realPriority,
      ),
    );
  }

  /// Invoke this to add a new case to all the possible cases.
  void onCase(
    Matcher matcher,
    HandleFunction<ValueType, MatchResultType> handler, {
    int? priority,
  }) =>
      on(
        matcher,
        handler,
        priority: priority,
      );

  /// Returns true if matcher matches with value, and false if don't/
  bool _caseMatchWithValue(
    MatchCase<ValueType, MatchResultType> matchCase,
    ValueType value,
  ) =>
      matchCase.matcher.matches(value, {});

  /// Applies the handler function of the first case that matches with [value].
  ///
  /// Cases are analyzed in order of priority, so the first case that matches
  /// with value is the one with the "highest" priority.
  MatchResultType match(ValueType value) {
    var priority = 0;

    while (priority < kMaxPriority) {
      try {
        final cases = _priorityToCasesMap[priority]!;
        final matchCase = cases.firstWhere(
          (matchCase) => _caseMatchWithValue(matchCase, value),
        );

        return matchCase.handler(value);
      } catch (_) {
        // Analyze next priority
        priority++;
      }
    }

    // If none of the cases match, then return the default handler for value.
    return onDefault(value);
  }
}
