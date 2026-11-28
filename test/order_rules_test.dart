import 'package:flutter_test/flutter_test.dart';
import 'package:mawar_cake_house/features/orders/domain/order_rules.dart';

void main() {
  group('deposit and balance (FR-05, BR-01)', () {
    test('RM100 gives RM30 deposit and RM70 balance', () {
      expect(depositOf(100), closeTo(30, 0.001));
      expect(balanceOf(100), closeTo(70, 0.001));
    });
  });

  group('total input (FR-05)', () {
    test('accepts a positive number, ignoring spaces', () {
      expect(parseTotal(' 85.5 '), 85.5);
    });

    test('rejects zero, negative and text', () {
      expect(parseTotal('0'), isNull);
      expect(parseTotal('-5'), isNull);
      expect(parseTotal('abc'), isNull);
    });
  });

  group('allergy gate (FR-03, BR-02)', () {
    test('blocked until an option is chosen', () {
      expect(allergyAnswered({}, ''), isFalse);
    });

    test('"None" counts as answered', () {
      expect(allergyAnswered({'None'}, ''), isTrue);
    });

    test('"Other" needs text', () {
      expect(allergyAnswered({'Other'}, ''), isFalse);
      expect(allergyAnswered({'Other'}, 'sesame'), isTrue);
    });
  });
}
