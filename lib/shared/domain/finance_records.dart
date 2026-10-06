import 'package:either/either.dart';

import '../../core/error/failures.dart';
import 'entities/account.dart';
import 'entities/calendar_date.dart';
import 'entities/category.dart';
import 'entities/money_transaction.dart';
import 'entities/subcategory.dart';

final class FinanceRecords {
  const FinanceRecords({
    required this.accounts,
    required this.categories,
    required this.subcategories,
    required this.transactions,
  });

  factory FinanceRecords.empty() {
    return const FinanceRecords(
      accounts: <Account>[],
      categories: <Category>[],
      subcategories: <Subcategory>[],
      transactions: <MoneyTransaction>[],
    );
  }

  final List<Account> accounts;
  final List<Category> categories;
  final List<Subcategory> subcategories;
  final List<MoneyTransaction> transactions;

  bool get hasAccounts => accounts.isNotEmpty;

  FinanceRecords seedIfNeeded(DateTime now) {
    if (categories.isNotEmpty) {
      return this;
    }
    final List<Category> seeded = <Category>[];
    final List<Subcategory> children = <Subcategory>[];
    void add(CategoryKind kind, String name) {
      seeded.add(
        Category(
          id: 'seed-${kind.name}-$name',
          name: name,
          kind: kind,
          isActive: true,
        ),
      );
    }

    for (final String name in <String>[
      'راتب',
      'عمل حر',
      'نشاط تجاري',
      'هدايا',
      'أخرى',
    ]) {
      add(CategoryKind.income, name);
    }
    for (final String name in <String>[
      'طعام',
      'مواصلات',
      'تسوق',
      'فواتير',
      'صحة',
      'تعليم',
      'ترفيه',
      'أسرة',
      'أخرى',
    ]) {
      add(CategoryKind.expense, name);
    }
    final Category transport = seeded.firstWhere(
      (Category item) => item.name == 'مواصلات',
    );
    children.add(
      Subcategory(
        id: 'seed-fuel',
        categoryId: transport.id,
        name: 'وقود',
        isActive: true,
      ),
    );
    return FinanceRecords(
      accounts: accounts,
      categories: seeded,
      subcategories: children,
      transactions: transactions,
    );
  }

  Either<Failure, FinanceRecords> saveAccount({
    required String? id,
    required String name,
    required AccountType type,
    required int openingBalanceMinor,
    required CalendarDate openingDate,
    required bool includeInTotal,
    required DateTime now,
    String? bankName,
    String? accountNumber,
    String? phoneNumber,
  }) {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Left(ValidationFailure(message: 'name_required'));
    }
    if (id == null) {
      final Account created = _labeled(
        Account(
          id: 'acc-${now.microsecondsSinceEpoch}',
          name: trimmed,
          type: type,
          openingBalanceMinor: openingBalanceMinor,
          openingDate: openingDate,
          isActive: true,
          includeInTotal: includeInTotal,
          createdAt: now,
          updatedAt: now,
        ),
        type: type,
        bankName: bankName,
        accountNumber: accountNumber,
        phoneNumber: phoneNumber,
      );
      return Right(_copy(accounts: <Account>[...accounts, created]));
    }
    final Account? current = _account(id);
    if (current == null) {
      return const Left(ValidationFailure(message: 'account_missing'));
    }
    final bool typeChanged = current.type != type;
    final bool hasHistory = _touches(id);
    if (typeChanged && hasHistory) {
      return const Left(ValidationFailure(message: 'type_locked'));
    }
    if (openingDate.isAfter(current.openingDate) ||
        current.openingDate.isAfter(openingDate)) {
      final bool blocked = transactions.any((MoneyTransaction item) {
        final bool touches =
            item.accountId == id ||
            item.fromAccountId == id ||
            item.toAccountId == id;
        return touches && item.date.isBefore(openingDate);
      });
      if (blocked) {
        return const Left(ValidationFailure(message: 'opening_date_blocked'));
      }
    }
    final Account next = _labeled(
      current.copyWith(
        name: trimmed,
        type: type,
        openingBalanceMinor: openingBalanceMinor,
        openingDate: openingDate,
        includeInTotal: includeInTotal,
        clearBank: type != AccountType.bank,
        clearPhone: type != AccountType.eWallet,
        updatedAt: now,
      ),
      type: type,
      bankName: bankName,
      accountNumber: accountNumber,
      phoneNumber: phoneNumber,
    );
    return Right(_replaceAccount(next));
  }

  Either<Failure, FinanceRecords> deactivateAccount(String id, DateTime now) {
    final Account? account = _account(id);
    if (account == null) {
      return const Left(ValidationFailure(message: 'account_missing'));
    }
    return Right(
      _replaceAccount(
        account.copyWith(
          isActive: false,
          includeInTotal: false,
          updatedAt: now,
        ),
      ),
    );
  }

  Either<Failure, FinanceRecords> reactivateAccount(String id, DateTime now) {
    final Account? account = _account(id);
    if (account == null) {
      return const Left(ValidationFailure(message: 'account_missing'));
    }
    return Right(
      _replaceAccount(account.copyWith(isActive: true, updatedAt: now)),
    );
  }

  Either<Failure, FinanceRecords> deleteAccount(String id) {
    if (_touches(id)) {
      return const Left(ValidationFailure(message: 'account_has_history'));
    }
    return Right(
      _copy(accounts: accounts.where((Account item) => item.id != id).toList()),
    );
  }

  Either<Failure, FinanceRecords> saveMovement({
    required String? id,
    required MoneyTransactionType type,
    required int amountMinor,
    required CalendarDate date,
    required DateTime now,
    String? accountId,
    String? categoryId,
    String? subcategoryId,
    String? fromAccountId,
    String? toAccountId,
    String? description,
    String? notes,
  }) {
    if (amountMinor <= 0) {
      return const Left(ValidationFailure(message: 'amount_positive'));
    }
    if (type == MoneyTransactionType.transfer) {
      final String? source = fromAccountId;
      final String? destination = toAccountId;
      if (source == null || destination == null || source == destination) {
        return const Left(ValidationFailure(message: 'transfer_accounts'));
      }
      final Account? from = _account(source);
      final Account? to = _account(destination);
      if (from == null || to == null || !from.isActive || !to.isActive) {
        return const Left(ValidationFailure(message: 'account_inactive'));
      }
      if (date.isBefore(from.openingDate) || date.isBefore(to.openingDate)) {
        return const Left(ValidationFailure(message: 'date_before_opening'));
      }
    } else {
      final Account? account = accountId == null ? null : _account(accountId);
      if (account == null || !account.isActive) {
        return const Left(ValidationFailure(message: 'account_inactive'));
      }
      if (date.isBefore(account.openingDate)) {
        return const Left(ValidationFailure(message: 'date_before_opening'));
      }
      final CategoryKind kind = type == MoneyTransactionType.income
          ? CategoryKind.income
          : CategoryKind.expense;
      final String? categoryError = _categoryOk(
        categoryId,
        subcategoryId,
        kind,
      );
      if (categoryError != null) {
        return Left(ValidationFailure(message: categoryError));
      }
    }
    final MoneyTransaction row = MoneyTransaction(
      id: id ?? 'tx-${now.microsecondsSinceEpoch}',
      type: type,
      amountMinor: amountMinor,
      date: date,
      accountId: type == MoneyTransactionType.transfer ? null : accountId,
      categoryId: type == MoneyTransactionType.transfer ? null : categoryId,
      subcategoryId: type == MoneyTransactionType.transfer
          ? null
          : subcategoryId,
      fromAccountId: type == MoneyTransactionType.transfer
          ? fromAccountId
          : null,
      toAccountId: type == MoneyTransactionType.transfer ? toAccountId : null,
      description: description,
      notes: notes,
      createdAt: id == null
          ? now
          : transactions
                .firstWhere((MoneyTransaction item) => item.id == id)
                .createdAt,
      updatedAt: now,
    );
    if (id == null) {
      return Right(
        _copy(transactions: <MoneyTransaction>[...transactions, row]),
      );
    }
    if (!transactions.any((MoneyTransaction item) => item.id == id)) {
      return const Left(ValidationFailure(message: 'transaction_missing'));
    }
    return Right(
      _copy(
        transactions: transactions
            .map((MoneyTransaction item) => item.id == id ? row : item)
            .toList(),
      ),
    );
  }

  Either<Failure, FinanceRecords> deleteTransaction(String id) {
    if (!transactions.any((MoneyTransaction item) => item.id == id)) {
      return const Left(ValidationFailure(message: 'transaction_missing'));
    }
    return Right(
      _copy(
        transactions: transactions
            .where((MoneyTransaction item) => item.id != id)
            .toList(),
      ),
    );
  }

  Either<Failure, FinanceRecords> saveCategory({
    required String? id,
    required String? parentId,
    required String name,
    required CategoryKind kind,
  }) {
    final String trimmed = name.trim();
    if (trimmed.isEmpty) {
      return const Left(ValidationFailure(message: 'name_required'));
    }
    if (parentId != null) {
      if (id == null) {
        return Right(
          _copy(
            subcategories: <Subcategory>[
              ...subcategories,
              Subcategory(
                id: 'sub-${trimmed.hashCode}-${subcategories.length}',
                categoryId: parentId,
                name: trimmed,
                isActive: true,
              ),
            ],
          ),
        );
      }
      return Right(
        _copy(
          subcategories: subcategories
              .map(
                (Subcategory item) =>
                    item.id == id ? item.copyWith(name: trimmed) : item,
              )
              .toList(),
        ),
      );
    }
    if (id == null) {
      return Right(
        _copy(
          categories: <Category>[
            ...categories,
            Category(
              id: 'cat-${kind.name}-$trimmed-${categories.length}',
              name: trimmed,
              kind: kind,
              isActive: true,
            ),
          ],
        ),
      );
    }
    return Right(
      _copy(
        categories: categories
            .map(
              (Category item) =>
                  item.id == id ? item.copyWith(name: trimmed) : item,
            )
            .toList(),
      ),
    );
  }

  Either<Failure, FinanceRecords> deactivateCategory(String id) {
    if (categories.any((Category item) => item.id == id)) {
      return Right(
        _copy(
          categories: categories
              .map(
                (Category item) =>
                    item.id == id ? item.copyWith(isActive: false) : item,
              )
              .toList(),
        ),
      );
    }
    return Right(
      _copy(
        subcategories: subcategories
            .map(
              (Subcategory item) =>
                  item.id == id ? item.copyWith(isActive: false) : item,
            )
            .toList(),
      ),
    );
  }

  Either<Failure, FinanceRecords> deleteCategory(String id) {
    final bool used =
        transactions.any(
          (MoneyTransaction item) =>
              item.categoryId == id || item.subcategoryId == id,
        ) ||
        subcategories.any(
          (Subcategory item) =>
              item.categoryId == id &&
              transactions.any(
                (MoneyTransaction tx) => tx.subcategoryId == item.id,
              ),
        );
    if (used) {
      return const Left(ValidationFailure(message: 'category_used'));
    }
    return Right(
      _copy(
        categories: categories.where((Category item) => item.id != id).toList(),
        subcategories: subcategories
            .where((Subcategory item) => item.id != id && item.categoryId != id)
            .toList(),
      ),
    );
  }

  List<MoneyTransaction> search({
    String? query,
    DateRange? range,
    String? accountId,
    MoneyTransactionType? type,
    String? categoryId,
    String? subcategoryId,
    bool excludeTransfers = false,
  }) {
    final String needle = (query ?? '').trim().toLowerCase();
    return transactions.where((MoneyTransaction item) {
      if (range != null && !range.contains(item.date)) {
        return false;
      }
      if (type != null && item.type != type) {
        return false;
      }
      if (excludeTransfers && item.type == MoneyTransactionType.transfer) {
        return false;
      }
      if (accountId != null &&
          item.accountId != accountId &&
          item.fromAccountId != accountId &&
          item.toAccountId != accountId) {
        return false;
      }
      if (categoryId != null && item.categoryId != categoryId) {
        return false;
      }
      if (subcategoryId != null && item.subcategoryId != subcategoryId) {
        return false;
      }
      if (needle.isEmpty) {
        return true;
      }
      final String haystack = <String?>[
        item.description,
        item.notes,
        _accountName(item.accountId),
        _accountName(item.fromAccountId),
        _accountName(item.toAccountId),
        _categoryName(item.categoryId),
        _subcategoryName(item.subcategoryId),
      ].whereType<String>().join(' ').toLowerCase();
      return haystack.contains(needle);
    }).toList();
  }

  Account? _account(String id) {
    for (final Account account in accounts) {
      if (account.id == id) {
        return account;
      }
    }
    return null;
  }

  bool _touches(String id) {
    return transactions.any(
      (MoneyTransaction item) =>
          item.accountId == id ||
          item.fromAccountId == id ||
          item.toAccountId == id,
    );
  }

  String? _categoryOk(
    String? categoryId,
    String? subcategoryId,
    CategoryKind kind,
  ) {
    final Category? category = categories.cast<Category?>().firstWhere(
      (Category? item) => item?.id == categoryId,
      orElse: () => null,
    );
    if (category == null || !category.isActive || category.kind != kind) {
      return 'category_invalid';
    }
    if (subcategoryId == null) {
      return null;
    }
    final Subcategory? subcategory = subcategories
        .cast<Subcategory?>()
        .firstWhere(
          (Subcategory? item) => item?.id == subcategoryId,
          orElse: () => null,
        );
    if (subcategory == null ||
        !subcategory.isActive ||
        subcategory.categoryId != category.id) {
      return 'subcategory_invalid';
    }
    return null;
  }

  String? _accountName(String? id) {
    if (id == null) {
      return null;
    }
    return _account(id)?.name;
  }

  String? _categoryName(String? id) {
    for (final Category category in categories) {
      if (category.id == id) {
        return category.name;
      }
    }
    return null;
  }

  String? _subcategoryName(String? id) {
    for (final Subcategory subcategory in subcategories) {
      if (subcategory.id == id) {
        return subcategory.name;
      }
    }
    return null;
  }

  Account _labeled(
    Account account, {
    required AccountType type,
    String? bankName,
    String? accountNumber,
    String? phoneNumber,
  }) {
    return account.copyWith(
      type: type,
      bankName: type == AccountType.bank ? bankName : null,
      accountNumber: type == AccountType.bank ? accountNumber : null,
      phoneNumber: type == AccountType.eWallet ? phoneNumber : null,
      clearBank: type != AccountType.bank,
      clearPhone: type != AccountType.eWallet,
    );
  }

  FinanceRecords _replaceAccount(Account next) {
    return _copy(
      accounts: accounts
          .map((Account item) => item.id == next.id ? next : item)
          .toList(),
    );
  }

  FinanceRecords _copy({
    List<Account>? accounts,
    List<Category>? categories,
    List<Subcategory>? subcategories,
    List<MoneyTransaction>? transactions,
  }) {
    return FinanceRecords(
      accounts: accounts ?? this.accounts,
      categories: categories ?? this.categories,
      subcategories: subcategories ?? this.subcategories,
      transactions: transactions ?? this.transactions,
    );
  }
}
