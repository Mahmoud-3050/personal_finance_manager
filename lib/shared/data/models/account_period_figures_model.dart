import '../../domain/entities/account_period_figures.dart';

final class AccountPeriodFiguresModel extends AccountPeriodFigures {
  const AccountPeriodFiguresModel({
    required super.accountId,
    required super.name,
    required super.startingMinor,
    required super.incomeMinor,
    required super.expenseMinor,
    required super.transfersInMinor,
    required super.transfersOutMinor,
    required super.endingMinor,
  });

  factory AccountPeriodFiguresModel.fromEntity(AccountPeriodFigures figures) {
    return AccountPeriodFiguresModel(
      accountId: figures.accountId,
      name: figures.name,
      startingMinor: figures.startingMinor,
      incomeMinor: figures.incomeMinor,
      expenseMinor: figures.expenseMinor,
      transfersInMinor: figures.transfersInMinor,
      transfersOutMinor: figures.transfersOutMinor,
      endingMinor: figures.endingMinor,
    );
  }

  factory AccountPeriodFiguresModel.fromJson(Map<String, dynamic> json) {
    return AccountPeriodFiguresModel(
      accountId: json['account_id'] as String,
      name: json['name'] as String,
      startingMinor: json['starting_minor'] as int,
      incomeMinor: json['income_minor'] as int,
      expenseMinor: json['expense_minor'] as int,
      transfersInMinor: json['transfers_in_minor'] as int,
      transfersOutMinor: json['transfers_out_minor'] as int,
      endingMinor: json['ending_minor'] as int,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'account_id': accountId,
    'name': name,
    'starting_minor': startingMinor,
    'income_minor': incomeMinor,
    'expense_minor': expenseMinor,
    'transfers_in_minor': transfersInMinor,
    'transfers_out_minor': transfersOutMinor,
    'ending_minor': endingMinor,
  };
}
