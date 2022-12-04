# Case Matcher

[![style: very good analysis][very_good_analysis_badge]][very_good_analysis_link]
[![Powered by Mason](https://img.shields.io/endpoint?url=https%3A%2F%2Ftinyurl.com%2Fmason-badge)](https://github.com/felangel/mason)
[![License: MIT][license_badge]][license_link]

An experimental declarative library for case matching in Dart using [matcher library](https://api.flutter.dev/flutter/package-matcher_matcher/package-matcher_matcher-library.html)

## Overview

Pattern specification is a powerful tool for matching and extracting data from objects. Unfortunately, Dart doesn't have a powerful built-in pattern matching mechanism yet like many other languages do. This library provides a declarative way to match and extract data from objects using the [matcher library](https://api.flutter.dev/flutter/package-matcher_matcher/package-matcher_matcher-library.html).

### What's the purpose of this library? 

Main idea in here is to write declarative code that is easy to read and understand, and to avoid writing a lot of boilerplate code for matching and extracting data from objects. For example, let's say given a number, we want to map it into a string with semantic info about that number. In many languages like rust, you can do something like this:

```rust
let number = 13;

println!("Tell me about {}", number);

match number {
    1 => "The very first unit!",
    // Match several values
    2 | 3 | 5 | 7 | 11 => "This is a prime less than 11",
    // Match an inclusive range
    11..=19 => "A teen",
    // Handle the rest of cases
    _ => "Ain't special",
}
```
Rust is know for being a very expressive language, and this is just one of the many examples of how expressive it can be. In Dart, pattern matching is not yet supported, but we can still write declarative code that is easy to read and understand via using [Matchers](https://api.flutter.dev/flutter/package-matcher_matcher/package-matcher_matcher-library.html). 

Matchers were initially exclusively used inside for testing, specially for unit testing, but then they got extracted into a separate package, and now they can be used in other places. A Matcher is basically a class that has a `matches` method that takes an input and returns a boolean value if input follows certain pattern specified in that function. Code below is from matcher library:

```dart
abstract class Matcher {
  const Matcher();

  /// Does the matching of the actual vs expected values.
  ///
  /// [item] is the actual value. [matchState] can be supplied
  /// and may be used to add details about the mismatch that are too
  /// costly to determine in [describeMismatch].
  bool matches(dynamic item, Map matchState);

  /// Builds a textual description of the matcher.
  Description describe(Description description);

  /// Builds a textual description of a specific mismatch.
  ///
  /// [item] is the value that was tested by [matches]; [matchState] is
  /// the [Map] that was passed to and supplemented by [matches]
  /// with additional information about the mismatch, and [mismatchDescription]
  /// is the [Description] that is being built to describe the mismatch.
  ///
  /// A few matchers make use of the [verbose] flag to provide detailed
  /// information that is not typically included but can be of help in
  /// diagnosing failures, such as stack traces.
  Description describeMismatch(dynamic item, Description mismatchDescription,
          Map matchState, bool verbose) =>
      mismatchDescription;
}
```

So basically, performing a `match` is almost the same as asking `if(condition)` in a conditional statement, only that condition sometimes are complex and can get nested into several conditions, making them hard to read if the case of study is just a little bit complex.

### Primes with case matcher
Let's see how can we write the primers example with case matcher library. 

```dart

final number = 13;

final matcher = CaseMatcher<int, String>(
  onDefault: (_) => 'Ain\'t special',
)
  // Just simple specifications.
  ..onEquals(1, (_) => 'The very first unit')
  ..onEquals([2, 3, 5, 7, 11], (value) => '$value is a prime less than 11')
  ..onCase(
    greaterThanOrEqualTo(11) & lessThanOrEqualTo(19),
    (value) => '$value is a teen',
  );

final result = matcher.match(number); 
// Same as final result = matcher << number;
```
This looks much more readable than a few if statements modifying a global variable, and is warrantying that only one of the cases will be executed (In next sections we will talk about which one is going to be executed in case there are multiple matches).

We implemented a `<<` operator that is just a syntactic sugar for `match` method. It's just a matter of preference, but I think it's more readable. Note that the other way doesn't work. You can't do `number >> matcher` because `<<` is a method of `CaseMatcher` class, not `int` class. `int` has its own `<<` and `>>` operators, which are used for bit shifting.

#### OnCase

All the library works on top of the `onCase` function. `OnCase` receives a matcher and a function that will be executed if the matcher matches the input. The function receives the input as a parameter. 

This cases are registered in a `LinkedHashSet` which will be iterated in order to find the first match. 
Within the `onCase` function there are a lot of functions provided in order to make things easier to define cases, which is the main goal of this library, making things easier. 

#### Logic operators to matchers
An extension was created in order to support basic logic operators for matchers.

```dart
extension LogicOperatorsMatcherExtension on Matcher {
  /// Applies the [allOf] matcher to both matchers.
  ///
  /// Matches in case [this] and [other] matches both match at the same time.
  Matcher operator &(Matcher other) => allOf(this, other);

  /// Applies the [anyOf] matcher to both matchers.
  ///
  /// Matches in case [this] or [other] match.
  Matcher operator |(Matcher other) => anyOf(this, other);

  /// Applies the [isNot] matcher to the given matcher.
  ///
  /// Matches in case [this] match doesn't match.
  Matcher operator ~() => isNot(this);
}
```

With this extension, you can write in a very clean way, some cool matchers to achieve very complex specifications.

#### Inheritance in case matchers.
Maybe even more important than the matchers themselves, is the ability to inherit from `CaseMatcher`. This is very useful when you want to define a base case matcher that will be used in several places, so you can just extract it and and call it later

```dart
/// You can create this class in a separate file and import it
class CustomCaseMatcher extends CaseMatcher<int,String> {
    CustomCaseMatcher() : super(
        onDefault: (_) => 'Ain\'t special',
    ) {
        // Just simple specifications.
        onEquals(1, (_) => 'The very first unit');
        onEquals([2, 3, 5, 7, 11], (value) => '$value is a prime less than 11');
        onCase(
        greaterThanOrEqualTo(11) & lessThanOrEqualTo(19),
        (value) => '$value is a teen',
        );
    }
}
/// ... and then you can use it like this
final matcher = CustomCaseMatcher();
final result = matcher << 13;
```

## Caveats
There are a few caveats for using this library (Currently*). The biggest one is that is not taking full information about the nature of the matcher. This means that all the matches are going to be analyzed, no matter if one matcher denies a set of other matches. 

For example, if you have a `greaterThan(10)` and a `greaterThan(11)`, you know that if the input is less than 10, there is no point on checking the second one, because it will always fail. We could achieve this by using meta-programming, but currently there is no way to do this in Dart.

Cases are always analyzed in order of priority, until we found the first match. This means that if you have a `greaterThan(10)` and a `greaterThan(11)`, and the input is 12, the case with the highest priority (or the first one declared) will be the only one executed.

### Performance
In terms of performance, this library is not the fastest one. It's not the slowest either, but it's not the fastest.

It will always be faster to write some condition statements than using this library, because at least you are not storing the cases in memory to know which one is going to be executed, but besides that it's not that bad. The `match` function is O(n) where n is the number of cases, and creating the CaseMatcher class is also O(n) assuming that `LinkedHashSet` is O(1) for adding elements.

So, in the worst case scenario, it will be `n + k*n = (k+1)*n = O(K*n)` where k is the number of times that the `match` function is called.Keep in mind that the linear if statements are also O(n) where n is the number of cases, so it's not that bad.

## Work in progress
This library is still in development, and it's not yet published in pub.dev. It's still in a very early stage, and it's not yet ready for production. Please feel free to contribute to the project, and help me make it better. 

PD: thanks to Copilot that helped me write this doc. I'm not sure if it's a good thing or a bad thing.

[dart_install_link]: https://dart.dev/get-dart
[github_actions_link]: https://docs.github.com/en/actions/learn-github-actions
[license_badge]: https://img.shields.io/badge/license-MIT-blue.svg
[license_link]: https://opensource.org/licenses/MIT
[logo_black]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_black.png#gh-light-mode-only
[logo_white]: https://raw.githubusercontent.com/VGVentures/very_good_brand/main/styles/README/vgv_logo_white.png#gh-dark-mode-only
[mason_link]: https://github.com/felangel/mason
[very_good_analysis_badge]: https://img.shields.io/badge/style-very_good_analysis-B22C89.svg
[very_good_analysis_link]: https://pub.dev/packages/very_good_analysis
[very_good_coverage_link]: https://github.com/marketplace/actions/very-good-coverage
[very_good_ventures_link]: https://verygood.ventures
[very_good_ventures_link_light]: https://verygood.ventures#gh-light-mode-only
[very_good_ventures_link_dark]: https://verygood.ventures#gh-dark-mode-only
[very_good_workflows_link]: https://github.com/VeryGoodOpenSource/very_good_workflows
