import 'package:finzomanager/shared/domain/entities/account.dart';
import 'package:finzomanager/shared/domain/entities/calendar_date.dart';
import 'package:finzomanager/shared/domain/entities/category.dart';
import 'package:finzomanager/shared/domain/entities/category_share.dart';
import 'package:finzomanager/shared/domain/entities/money_transaction.dart';
import 'package:finzomanager/shared/domain/entities/period_figures.dart';
import 'package:finzomanager/shared/domain/services/report_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a zero total is 0 percent and one third rounds to one decimal', () {
    expect(percentageLabel(0, 0), '0%');
    expect(percentageLabel(1, 3), '33.3%');
  });

  test('commissions are expenses and transfers stay the moved amount', () {
    final DateTime now = DateTime(2026, 10, 6);
    final Account bank = Account(
      id: 'bank',
      name: 'Bank',
      type: AccountType.bank,
      openingBalanceMinor: 0,
      openingDate: const CalendarDate(2026, 10, 1),
      isActive: true,
      includeInTotal: true,
      createdAt: now,
      updatedAt: now,
    );
    final Account wallet = Account(
      id: 'wallet',
      name: 'Wallet',
      type: AccountType.eWallet,
      openingBalanceMinor: 0,
      openingDate: const CalendarDate(2026, 10, 1),
      isActive: true,
      includeInTotal: true,
      createdAt: now,
      updatedAt: now,
    );
    const Category food = Category(
      id: 'food',
      name: 'طعام',
      kind: CategoryKind.expense,
      isActive: true,
    );
    const Category fee = Category(
      id: transferCommissionCategoryId,
      name: transferCommissionCategoryName,
      kind: CategoryKind.expense,
      isActive: true,
    );
    final List<MoneyTransaction> transactions = <MoneyTransaction>[
      MoneyTransaction(
        id: 'move',
        type: MoneyTransactionType.transfer,
        amountMinor: 100000,
        commissionMinor: 500,
        date: const CalendarDate(2026, 10, 2),
        fromAccountId: 'bank',
        toAccountId: 'wallet',
        createdAt: now,
        updatedAt: now,
      ),
      MoneyTransaction(
        id: 'pay',
        type: MoneyTransactionType.expense,
        amountMinor: 20000,
        commissionMinor: 300,
        date: const CalendarDate(2026, 10, 3),
        accountId: 'bank',
        categoryId: 'food',
        createdAt: now,
        updatedAt: now,
      ),
    ];
    final PeriodFigures figures = periodFigures(
      range: const DateRange(
        CalendarDate(2026, 10, 1),
        CalendarDate(2026, 10, 31),
      ),
      accounts: <Account>[bank, wallet],
      categories: const <Category>[food, fee],
      subcategories: const [],
      transactions: transactions,
    );
    expect(figures.expenseMinor, 20800);
    expect(figures.netMinor, -20800);
    expect(
      figures.expenseShares
          .firstWhere((CategoryShare share) => share.id == 'food')
          .amountMinor,
      20000,
    );
    expect(
      figures.expenseShares
          .firstWhere(
            (CategoryShare share) => share.id == transferCommissionCategoryId,
          )
          .amountMinor,
      800,
    );
    expect(figures.accounts.first.transfersOutMinor, 100000);
    expect(figures.accounts.first.expenseMinor, 20800);
    expect(figures.accounts.last.transfersInMinor, 100000);
    expect(figures.accounts.last.expenseMinor, 0);
  });
}
