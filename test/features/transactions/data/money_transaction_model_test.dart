import 'package:finzomanager/features/transactions/data/models/money_transaction_model.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/entities/money_transaction.dart';
import 'package:finzomanager/shared/domain/services/percentage_commission.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 10, 6);

  MoneyTransactionModel sample({
    CommissionBasis basis = CommissionBasis.fixed,
    int rate = 0,
    int commission = 500,
  }) {
    return MoneyTransactionModel(
      id: 'tx',
      type: MoneyTransactionType.transfer,
      amountMinor: 100000,
      date: const CalendarDate(2026, 10, 2),
      fromAccountId: 'a',
      toAccountId: 'b',
      commissionMinor: commission,
      commissionBasis: basis,
      commissionRateMinor: rate,
      createdAt: now,
      updatedAt: now,
    );
  }

  test(
    'toJson writes commission_basis and commission_rate_minor; missing keys read as fixed and zero',
    () {
      final Map<String, dynamic> json = sample(
        basis: CommissionBasis.percentage,
        rate: 100,
        commission: 1000,
      ).toJson();
      expect(json['commission_basis'], 'percentage');
      expect(json['commission_rate_minor'], 100);
      final Map<String, dynamic> legacy = sample().toJson()
        ..remove('commission_basis')
        ..remove('commission_rate_minor');
      final MoneyTransactionModel restored = MoneyTransactionModel.fromJson(
        legacy,
      );
      expect(restored.commissionBasis, CommissionBasis.fixed);
      expect(restored.commissionRateMinor, 0);
      expect(restored.commissionMinor, 500);
    },
  );
}
