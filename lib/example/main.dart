import 'dart:developer';
import 'dart:math' show Random;

import 'package:case_matcher/case_matcher.dart';
import 'package:case_matcher/src/extensions/extensions.dart';
import 'package:matcher/matcher.dart';

class IntMatcher extends CaseMatcher<int, String> {
  IntMatcher()
      : super(
          onDefault: (element) => 'Could not match any case : $element',
        ) {
    // Just simple specifications.
    // An extension is provided for this unary matchers so you don't have to
    // write onCase(matcher).
    onEquals(10, (value) => 'Is exactly 10');
    onNotEquals(5, (value) => 'Is not exactly 5');
    onGreaterThan(5, (value) => '$value is greater than 5');

    // More complex specifications
    onCase(
      greaterThan(5) & lessThan(10),
      (value) => '$value is greater than 5 and less than 10',
    );
    onCase(
      greaterThan(5) | lessThan(10),
      (value) => '$value is greater than 5 or less than 10',
    );
  }
}

void main() {
  final objects = List.generate(100, (index) => index);

  final objectToTest = objects[Random().nextInt(objects.length)];
  final toStringMatcher = IntMatcher();
  final result = toStringMatcher.match(objectToTest);
  log('El type de ${objectToTest} es: ${result}');
}
