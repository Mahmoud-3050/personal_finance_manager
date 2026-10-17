import 'package:finzomanager/features/accounts/data/models/account_model.dart';
import 'package:finzomanager/shared/domain/entities/account.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 10, 6);

  AccountModel sample({int defaultCommissionMinor = 0}) {
    return AccountModel(
      id: 'bank',
      name: 'Bank',
      type: AccountType.bank,
      openingBalanceMinor: 2500000,
      defaultCommissionMinor: defaultCommissionMinor,
      openingDate: const CalendarDate(2026, 10, 1),
      isActive: true,
      includeInTotal: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  test(
    'toJson writes default_commission_minor and a missing key reads as zero',
    () {
      expect(
        sample(
          defaultCommissionMinor: 300,
        ).toJson()['default_commission_minor'],
        300,
      );
      final Map<String, dynamic> legacy = sample().toJson()
        ..remove('default_commission_minor');
      expect(AccountModel.fromJson(legacy).defaultCommissionMinor, 0);
    },
  );
}
