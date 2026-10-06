import '../entities/account.dart';
import '../entities/account_period_figures.dart';
import '../entities/calendar_date.dart';
import '../entities/category.dart';
import '../entities/category_share.dart';
import '../entities/money_transaction.dart';
import '../entities/period_figures.dart';
import '../entities/subcategory.dart';
import 'balance_calculator.dart';

String percentageLabel(int part, int total) {
  if (total == 0) {
    return '0%';
  }
  final int tenths = ((part * 1000) + (total ~/ 2)) ~/ total;
  final int whole = tenths ~/ 10;
  final int fraction = tenths.abs() % 10;
  return '$whole.$fraction%';
}

PeriodFigures periodFigures({
  required DateRange range,
  required List<Account> accounts,
  required List<Category> categories,
  required List<Subcategory> subcategories,
  required List<MoneyTransaction> transactions,
}) {
  final List<MoneyTransaction> inside = transactions
      .where((MoneyTransaction item) => range.contains(item.date))
      .toList();
  final int income = _sum(inside, MoneyTransactionType.income);
  final int expense = _sum(inside, MoneyTransactionType.expense);
  return PeriodFigures(
    incomeMinor: income,
    expenseMinor: expense,
    netMinor: income - expense,
    expenseShares: _shares(
      inside,
      MoneyTransactionType.expense,
      CategoryKind.expense,
      expense,
      categories,
      subcategories,
    ),
    incomeShares: _shares(
      inside,
      MoneyTransactionType.income,
      CategoryKind.income,
      income,
      categories,
      subcategories,
    ),
    accounts: accounts
        .map((Account account) => _accountPeriod(account, range, transactions))
        .toList(),
  );
}

int _sum(List<MoneyTransaction> items, MoneyTransactionType type) {
  var total = 0;
  for (final MoneyTransaction item in items) {
    if (item.type == type) {
      total += item.amountMinor;
    }
  }
  return total;
}

List<CategoryShare> _shares(
  List<MoneyTransaction> items,
  MoneyTransactionType type,
  CategoryKind kind,
  int total,
  List<Category> categories,
  List<Subcategory> subcategories,
) {
  final List<CategoryShare> shares = <CategoryShare>[];
  for (final Category category in categories.where(
    (Category item) => item.kind == kind,
  )) {
    final int amount = items
        .where(
          (MoneyTransaction item) =>
              item.type == type && item.categoryId == category.id,
        )
        .fold(0, (int sum, MoneyTransaction item) => sum + item.amountMinor);
    if (amount == 0) {
      continue;
    }
    final List<CategoryShare> children = <CategoryShare>[];
    for (final Subcategory subcategory in subcategories.where(
      (Subcategory item) => item.categoryId == category.id,
    )) {
      final int childAmount = items
          .where(
            (MoneyTransaction item) =>
                item.type == type && item.subcategoryId == subcategory.id,
          )
          .fold(0, (int sum, MoneyTransaction item) => sum + item.amountMinor);
      if (childAmount == 0) {
        continue;
      }
      children.add(
        CategoryShare(
          id: subcategory.id,
          name: subcategory.name,
          amountMinor: childAmount,
          percentageLabel: percentageLabel(childAmount, total),
        ),
      );
    }
    shares.add(
      CategoryShare(
        id: category.id,
        name: category.name,
        amountMinor: amount,
        percentageLabel: percentageLabel(amount, total),
        children: children,
      ),
    );
  }
  return shares;
}

AccountPeriodFigures _accountPeriod(
  Account account,
  DateRange range,
  List<MoneyTransaction> transactions,
) {
  final bool opensInside = range.contains(account.openingDate);
  final int starting = opensInside
      ? account.openingBalanceMinor
      : accountBalanceMinor(
          account,
          transactions
              .where((MoneyTransaction item) => item.date.isBefore(range.start))
              .toList(),
        );
  var income = 0;
  var expense = 0;
  var transfersIn = 0;
  var transfersOut = 0;
  for (final MoneyTransaction item in transactions) {
    if (!range.contains(item.date)) {
      continue;
    }
    switch (item.type) {
      case MoneyTransactionType.income:
        if (item.accountId == account.id) {
          income += item.amountMinor;
        }
      case MoneyTransactionType.expense:
        if (item.accountId == account.id) {
          expense += item.amountMinor;
        }
      case MoneyTransactionType.transfer:
        if (item.toAccountId == account.id) {
          transfersIn += item.amountMinor;
        }
        if (item.fromAccountId == account.id) {
          transfersOut += item.amountMinor;
        }
    }
  }
  return AccountPeriodFigures(
    accountId: account.id,
    name: account.name,
    startingMinor: starting,
    incomeMinor: income,
    expenseMinor: expense,
    transfersInMinor: transfersIn,
    transfersOutMinor: transfersOut,
    endingMinor: starting + income - expense + transfersIn - transfersOut,
  );
}

List<MoneyTransaction> newestTransactions(
  List<MoneyTransaction> transactions, {
  int limit = 10,
}) {
  final List<MoneyTransaction> sorted = List<MoneyTransaction>.of(transactions)
    ..sort((MoneyTransaction a, MoneyTransaction b) {
      final int byDate = b.date.compareTo(a.date);
      if (byDate != 0) {
        return byDate;
      }
      return b.createdAt.compareTo(a.createdAt);
    });
  if (sorted.length <= limit) {
    return sorted;
  }
  return sorted.sublist(0, limit);
}
