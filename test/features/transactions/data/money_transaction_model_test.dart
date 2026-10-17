import 'package:finzomanager/features/transactions/data/models/money_transaction_model.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/entities/money_transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 10, 6);

  MoneyTransactionModel sample({int commissionMinor = 0}) {
    return MoneyTransactionModel(
      id: 'tx',
      type: MoneyTransactionType.transfer,
      amountMinor: 100000,
      commissionMinor: commissionMinor,
      date: const CalendarDate(2026, 10, 2),
      fromAccountId: 'bank',
      toAccountId: 'wallet',
      createdAt: now,
      updatedAt: now,
    );
  }

  test('toJson writes commission_minor and a missing key reads as zero', () {
    expect(sample(commissionMinor: 500).toJson()['commission_minor'], 500);
    final Map<String, dynamic> legacy = sample().toJson()
      ..remove('commission_minor');
    expect(MoneyTransactionModel.fromJson(legacy).commissionMinor, 0);
  });
}
