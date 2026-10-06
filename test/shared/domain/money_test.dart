import 'package:finzomanager/shared/domain/entities/money.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('12.50 is exact piastres and a third decimal is rejected', () {
    final parsed = Money.parse('12.50', allowNegative: false, allowZero: false);
    expect(parsed.rightOrNull?.minor, 1250);
    expect(parsed.rightOrNull?.format(), '12.50');
    expect(
      Money.parse('12.505', allowNegative: false, allowZero: false).isLeft,
      isTrue,
    );
    expect(
      Money.parse('0', allowNegative: false, allowZero: false).isLeft,
      isTrue,
    );
    expect(
      Money.parse('-1.25', allowNegative: true, allowZero: false).rightOrNull?.minor,
      -125,
    );
    expect(Money.parse('0', allowNegative: true, allowZero: true).rightOrNull?.minor, 0);
  });
}
