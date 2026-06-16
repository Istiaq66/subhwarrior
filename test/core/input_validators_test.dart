import 'package:flutter_test/flutter_test.dart';
import 'package:subh_warrior/core/constants/app_constants.dart';
import 'package:subh_warrior/core/utils/input_validators.dart';

void main() {
  group('InputValidators.username (D5)', () {
    test('accepts a valid name', () {
      expect(InputValidators.username('Warrior_1'), isNull);
    });

    test('rejects too-short names', () {
      expect(InputValidators.username('ab'), isNotNull);
    });

    test('rejects too-long names', () {
      final long = 'a' * (AppConstants.usernameMaxLength + 1);
      expect(InputValidators.username(long), isNotNull);
    });

    test('rejects disallowed characters', () {
      expect(InputValidators.username('bad/name'), isNotNull);
      expect(InputValidators.username('emoji😀'), isNotNull);
    });

    test('trims before measuring length', () {
      expect(InputValidators.username('  ab  '), isNotNull);
      expect(InputValidators.username('  abc  '), isNull);
    });
  });

  group('InputValidators free text (D5)', () {
    test('workDescription enforces max length', () {
      expect(InputValidators.workDescription('ok'), isNull);
      expect(
        InputValidators.workDescription(
            'x' * (AppConstants.workDescriptionMaxLength + 1)),
        isNotNull,
      );
    });

    test('reflection allows null and enforces max length', () {
      expect(InputValidators.reflection(null), isNull);
      expect(InputValidators.reflection('ok'), isNull);
      expect(
        InputValidators.reflection(
            'x' * (AppConstants.reflectionMaxLength + 1)),
        isNotNull,
      );
    });
  });
}