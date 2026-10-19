import 'package:finzomanager/features/accounts/data/models/account_model.dart';
import 'package:finzomanager/shared/domain/entities/account.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/services/percentage_commission.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime now = DateTime.utc(2026, 10, 6);

  AccountModel sample({
    int defaultCommissionMinor = 0,
    CommissionBasis defaultCommissionBasis = CommissionBasis.fixed,
    int defaultCommissionRateMinor = 0,
  }) {
    return AccountModel(
      id: 'bank',
      name: 'Bank',
      type: AccountType.bank,
      openingBalanceMinor: 2500000,
      defaultCommissionMinor: defaultCommissionMinor,
      defaultCommissionBasis: defaultCommissionBasis,
      defaultCommissionRateMinor: defaultCommissionRateMinor,
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

  test(
    'toJson writes basis and rate; missing keys read as fixed and zero',
    () {
      final Map<String, dynamic> json = sample(
        defaultCommissionBasis: CommissionBasis.percentage,
        defaultCommissionRateMinor: 100,
      ).toJson();
      expect(json['default_commission_basis'], 'percentage');
      expect(json['default_commission_rate_minor'], 100);
      final Map<String, dynamic> legacy = sample(
        defaultCommissionMinor: 300,
      ).toJson()
        ..remove('default_commission_basis')
        ..remove('default_commission_rate_minor');
      final AccountModel restored = AccountModel.fromJson(legacy);
      expect(restored.defaultCommissionBasis, CommissionBasis.fixed);
      expect(restored.defaultCommissionRateMinor, 0);
      expect(restored.defaultCommissionMinor, 300);
    },
  );
}
