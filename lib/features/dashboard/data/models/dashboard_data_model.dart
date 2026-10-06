import '../../../../shared/data/models/category_share_model.dart';
import '../../../../shared/domain/entities/account.dart';
import '../../../../shared/domain/entities/category_share.dart';
import '../../../../shared/domain/entities/money_transaction.dart';
import '../../../accounts/data/models/account_model.dart';
import '../../../transactions/data/models/money_transaction_model.dart';
import '../../domain/entities/dashboard_data.dart';

final class DashboardDataModel extends DashboardData {
  const DashboardDataModel({
    required super.totalMoneyMinor,
    required super.incomeMinor,
    required super.expenseMinor,
    required super.netMinor,
    required super.accounts,
    required super.accountBalances,
    required super.expenseShares,
    required super.recent,
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    return DashboardDataModel(
      totalMoneyMinor: json['total_money_minor'] as int,
      incomeMinor: json['income_minor'] as int,
      expenseMinor: json['expense_minor'] as int,
      netMinor: json['net_minor'] as int,
      accounts: _accounts(json['accounts']),
      accountBalances: _balances(json['account_balances']),
      expenseShares: _shares(json['expense_shares']),
      recent: _recent(json['recent']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'total_money_minor': totalMoneyMinor,
    'income_minor': incomeMinor,
    'expense_minor': expenseMinor,
    'net_minor': netMinor,
    'accounts': accounts
        .map((Account account) => AccountModel.fromEntity(account).toJson())
        .toList(),
    'account_balances': accountBalances,
    'expense_shares': expenseShares
        .map(
          (CategoryShare share) =>
              CategoryShareModel.fromEntity(share).toJson(),
        )
        .toList(),
    'recent': recent
        .map(
          (MoneyTransaction transaction) =>
              MoneyTransactionModel.fromEntity(transaction).toJson(),
        )
        .toList(),
  };

  static List<Account> _accounts(Object? raw) {
    final List<Object?> items = raw as List<Object?>? ?? const <Object?>[];
    return items
        .map(
          (Object? item) =>
              AccountModel.fromJson(item! as Map<String, dynamic>),
        )
        .toList();
  }

  static Map<String, int> _balances(Object? raw) {
    final Map<Object?, Object?> items =
        raw as Map<Object?, Object?>? ?? const <Object?, Object?>{};
    return <String, int>{
      for (final MapEntry<Object?, Object?> entry in items.entries)
        entry.key! as String: entry.value! as int,
    };
  }

  static List<CategoryShare> _shares(Object? raw) {
    final List<Object?> items = raw as List<Object?>? ?? const <Object?>[];
    return items
        .map(
          (Object? item) =>
              CategoryShareModel.fromJson(item! as Map<String, dynamic>),
        )
        .toList();
  }

  static List<MoneyTransaction> _recent(Object? raw) {
    final List<Object?> items = raw as List<Object?>? ?? const <Object?>[];
    return items
        .map(
          (Object? item) =>
              MoneyTransactionModel.fromJson(item! as Map<String, dynamic>),
        )
        .toList();
  }
}
