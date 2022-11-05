import 'package:matcher/matcher.dart';
import 'package:meta/meta.dart';

/// Min priority supported by library.
///
/// Currently, priorities are defined by a non-negative integer.
const num _kMinPriority = double.infinity;

/// Max priority supported by library
///
/// Currently, priorities are defined by a non-negative integer.
const num _kMaxPriority = 0;

/// Default priority value
///
/// Currently, `_kDefaultPriority = _kMinPriority`, so default is always the
/// lowest.
const num _kDefaultPriority = _kMinPriority;

/// Function that returns value of type [MatchResultType] given a [ValueType]
/// instance.
typedef HandleFunction<ValueType, MatchResultType> = MatchResultType Function(
  ValueType value,
);

/// {@template case_matcher}
/// Base class to case declaration functionality.
///
/// Provide matchers cases using the [onCase] function, where you can create
/// your own custom matchers and build code expressively
///
/// [value] refers to the value that is going to be matched with all machers
/// provided using [onCase] syntax.
/// {@endtemplate}
abstract class CaseMatcher<ValueType, MatchResultType> {
  /// {@macro case_matcher}
  CaseMatcher(
    this.value, {
    required this.onDefault,
  });

  /// Value that is going to be matched to all different matchers defined.
  final ValueType value;

  /// Default function that is going to be aplied to value in case there is
  /// not mathcing with any case.
  final HandleFunction<ValueType, MatchResultType> onDefault;

  /// All matches cases
  final Set<_MatchCase<ValueType, MatchResultType>> _matchesSet = const {};

  /// Invoque this to add a new handler to
  @protected
  @visibleForTesting
  void onCase(
    Matcher matcher,
    HandleFunction<ValueType, MatchResultType> handler, {
    num priority = _kDefaultPriority,
  }) {
    // Just a mapping to priorities, so you can handle priorities in a human way
    final realPriority = double.infinity - priority;

    _matchesSet.add(
      _MatchCase<ValueType, MatchResultType>(
        matcher: matcher,
        handler: handler,
        priority: realPriority,
      ),
    );
  }

  /// Runs all the matches that match with [ValueType] value
  /// Then, returns the match with the highest priority
  @protected
  MatchResultType run() {
    final matches =
        _matchesSet.where((element) => element.matcher.matches(value, {}));

    if (matches.isEmpty) {
      return onDefault(value);
    }
    return matches.first.handler(value);
  }
}

class _MatchCase<ValueType, MatchResultType> {
  _MatchCase({
    required this.matcher,
    required this.handler,
    required this.priority,
  })  : assert(
          priority <= _kMinPriority,
          'Priority cannot be greater than [_kMinPriority]. '
          'Use double.infinity if you want to declare the lowest priority',
        ),
        assert(
          priority >= _kMaxPriority,
          'Priority cannot be greater than. [_kMaxPriority] '
          'Use 0 if you want to declare the highest priority',
        );

  final Matcher matcher;
  final HandleFunction<ValueType, MatchResultType> handler;
  final num priority;
}
