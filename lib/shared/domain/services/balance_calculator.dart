import '../entities/account.dart';
import '../entities/money_transaction.dart';

int accountBalanceMinor(Account account, List<MoneyTransaction> transactions) {
  var balance = account.openingBalanceMinor;
  for (final MoneyTransaction transaction in transactions) {
    switch (transaction.type) {
      case MoneyTransactionType.income:
        if (transaction.accountId == account.id) {
          balance += transaction.amountMinor;
        }
      case MoneyTransactionType.expense:
        if (transaction.accountId == account.id) {
          balance -= transaction.amountMinor;
        }
      case MoneyTransactionType.transfer:
        if (transaction.toAccountId == account.id) {
          balance += transaction.amountMinor;
        }
        if (transaction.fromAccountId == account.id) {
          balance -= transaction.amountMinor;
        }
    }
  }
  return balance;
}

int totalMoneyMinor(
  List<Account> accounts,
  List<MoneyTransaction> transactions,
) {
  var total = 0;
  for (final Account account in accounts) {
    if (!account.includeInTotal) {
      continue;
    }
    total += accountBalanceMinor(account, transactions);
  }
  return total;
}
