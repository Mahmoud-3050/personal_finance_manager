import 'package:finzomanager/shared/domain/services/percentage_commission.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('1% of 100000 piastres is 1000', () {
    expect(
      percentageCommissionMinor(amountMinor: 100000, rateMinor: 100),
      1000,
    );
  });

  test('1% of 33333 piastres is 333', () {
    expect(
      percentageCommissionMinor(amountMinor: 33333, rateMinor: 100),
      333,
    );
  });

  test('0.50% of 100 piastres is 1', () {
    expect(
      percentageCommissionMinor(amountMinor: 100, rateMinor: 50),
      1,
    );
  });

  test('1% of 49 piastres is 0', () {
    expect(
      percentageCommissionMinor(amountMinor: 49, rateMinor: 100),
      0,
    );
  });

  test('150% of 100000 piastres is 150000', () {
    expect(
      percentageCommissionMinor(amountMinor: 100000, rateMinor: 15000),
      150000,
    );
  });
}
