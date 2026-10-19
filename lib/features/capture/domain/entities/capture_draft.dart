import 'package:equatable/equatable.dart';

import '../../../../shared/domain/entities/account.dart';
import '../../../../shared/domain/entities/calendar_date.dart';
import '../../../../shared/domain/services/percentage_commission.dart';

enum CaptureKind { income, expense }

enum CaptureField {
  amount,
  date,
  account,
  category,
  subcategory,
  notes,
  commission,
  shopName,
}

final class CaptureDraft extends Equatable {
  const CaptureDraft({
    required this.kind,
    required this.date,
    required this.uncertainFields,
    this.amountMinor,
    this.accountId,
    this.accountType,
    this.categoryId,
    this.subcategoryId,
    this.notes,
    this.commissionMinor,
    this.shopName,
  });

  factory CaptureDraft.handStarted() {
    return CaptureDraft(
      kind: CaptureKind.expense,
      date: CalendarDate.today(),
      uncertainFields: const <CaptureField>{},
    );
  }

  final CaptureKind kind;
  final int? amountMinor;
  final CalendarDate date;
  final String? accountId;
  final AccountType? accountType;
  final String? categoryId;
  final String? subcategoryId;
  final String? notes;
  final int? commissionMinor;
  final String? shopName;
  final Set<CaptureField> uncertainFields;

  bool get feeApplies =>
      kind == CaptureKind.expense &&
      (accountType == AccountType.bank || accountType == AccountType.eWallet);

  int get commissionToSave => feeApplies ? commissionMinor ?? 0 : 0;

  CaptureDraft changeKind({
    required CaptureKind kind,
    required bool keepCategory,
  }) {
    return copyWith(
      kind: kind,
      clearCategory: !keepCategory,
      clearSubcategory: !keepCategory,
      clearCommission: kind == CaptureKind.income,
    );
  }

  CaptureDraft changeAccount(Account? account) {
    if (account == null) {
      return copyWith(clearAccount: true, clearCommission: true);
    }
    final CaptureDraft selected = copyWith(
      accountId: account.id,
      accountType: account.type,
    );
    if (!selected.feeApplies) {
      return selected.copyWith(clearCommission: true);
    }
    if (account.defaultCommissionBasis == CommissionBasis.percentage) {
      final int fee = percentageCommissionMinor(
        amountMinor: selected.amountMinor ?? 0,
        rateMinor: account.defaultCommissionRateMinor,
      );
      return selected.copyWith(commissionMinor: fee);
    }
    return selected.copyWith(commissionMinor: account.defaultCommissionMinor);
  }

  CaptureDraft copyWith({
    CaptureKind? kind,
    int? amountMinor,
    bool clearAmount = false,
    CalendarDate? date,
    String? accountId,
    AccountType? accountType,
    bool clearAccount = false,
    String? categoryId,
    bool clearCategory = false,
    String? subcategoryId,
    bool clearSubcategory = false,
    String? notes,
    bool clearNotes = false,
    int? commissionMinor,
    bool clearCommission = false,
    String? shopName,
    bool clearShopName = false,
    Set<CaptureField>? uncertainFields,
  }) {
    return CaptureDraft(
      kind: kind ?? this.kind,
      amountMinor: clearAmount ? null : amountMinor ?? this.amountMinor,
      date: date ?? this.date,
      accountId: clearAccount ? null : accountId ?? this.accountId,
      accountType: clearAccount ? null : accountType ?? this.accountType,
      categoryId: clearCategory ? null : categoryId ?? this.categoryId,
      subcategoryId: clearSubcategory
          ? null
          : subcategoryId ?? this.subcategoryId,
      notes: clearNotes ? null : notes ?? this.notes,
      commissionMinor: clearCommission
          ? null
          : commissionMinor ?? this.commissionMinor,
      shopName: clearShopName ? null : shopName ?? this.shopName,
      uncertainFields: uncertainFields ?? this.uncertainFields,
    );
  }

  @override
  List<Object?> get props => <Object?>[
    kind,
    amountMinor,
    date,
    accountId,
    accountType,
    categoryId,
    subcategoryId,
    notes,
    commissionMinor,
    shopName,
    uncertainFields,
  ];
}
