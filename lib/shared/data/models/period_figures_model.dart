import '../../domain/entities/account_period_figures.dart';
import '../../domain/entities/category_share.dart';
import '../../domain/entities/period_figures.dart';
import 'account_period_figures_model.dart';
import 'category_share_model.dart';

final class PeriodFiguresModel extends PeriodFigures {
  const PeriodFiguresModel({
    required super.incomeMinor,
    required super.expenseMinor,
    required super.netMinor,
    required super.expenseShares,
    required super.incomeShares,
    required super.accounts,
  });

  factory PeriodFiguresModel.fromEntity(PeriodFigures figures) {
    return PeriodFiguresModel(
      incomeMinor: figures.incomeMinor,
      expenseMinor: figures.expenseMinor,
      netMinor: figures.netMinor,
      expenseShares: figures.expenseShares,
      incomeShares: figures.incomeShares,
      accounts: figures.accounts,
    );
  }

  factory PeriodFiguresModel.fromJson(Map<String, dynamic> json) {
    return PeriodFiguresModel(
      incomeMinor: json['income_minor'] as int,
      expenseMinor: json['expense_minor'] as int,
      netMinor: json['net_minor'] as int,
      expenseShares: _shares(json['expense_shares']),
      incomeShares: _shares(json['income_shares']),
      accounts: _accounts(json['accounts']),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'income_minor': incomeMinor,
    'expense_minor': expenseMinor,
    'net_minor': netMinor,
    'expense_shares': expenseShares
        .map(
          (CategoryShare share) =>
              CategoryShareModel.fromEntity(share).toJson(),
        )
        .toList(),
    'income_shares': incomeShares
        .map(
          (CategoryShare share) =>
              CategoryShareModel.fromEntity(share).toJson(),
        )
        .toList(),
    'accounts': accounts
        .map(
          (AccountPeriodFigures figures) =>
              AccountPeriodFiguresModel.fromEntity(figures).toJson(),
        )
        .toList(),
  };

  static List<CategoryShare> _shares(Object? raw) {
    final List<Object?> items = raw as List<Object?>? ?? const <Object?>[];
    return items
        .map(
          (Object? item) =>
              CategoryShareModel.fromJson(item! as Map<String, dynamic>),
        )
        .toList();
  }

  static List<AccountPeriodFigures> _accounts(Object? raw) {
    final List<Object?> items = raw as List<Object?>? ?? const <Object?>[];
    return items
        .map(
          (Object? item) =>
              AccountPeriodFiguresModel.fromJson(item! as Map<String, dynamic>),
        )
        .toList();
  }
}
