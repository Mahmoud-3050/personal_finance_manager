import '../../../../core/database/finance_database.dart';
import '../../../../core/database/finance_record_mapper.dart';
import '../../../../shared/domain/entities/account.dart';
import '../../../../shared/domain/entities/category.dart';
import '../../../../shared/domain/entities/money_transaction.dart';
import '../../../../shared/domain/entities/subcategory.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/data/models/subcategory_model.dart';
import '../../../transactions/data/models/money_transaction_model.dart';
import '../models/account_model.dart';

class FinanceRecordMapperImpl implements FinanceRecordMapper {
  const FinanceRecordMapperImpl();

  @override
  List<Account> readAccounts(List<AccountRow> rows) {
    return rows.map(AccountModel.fromRow).toList();
  }

  @override
  List<Category> readCategories(List<CategoryRow> rows) {
    return rows.map(CategoryModel.fromRow).toList();
  }

  @override
  List<Subcategory> readSubcategories(List<SubcategoryRow> rows) {
    return rows.map(SubcategoryModel.fromRow).toList();
  }

  @override
  List<MoneyTransaction> readTransactions(List<TransactionRow> rows) {
    return rows.map(MoneyTransactionModel.fromRow).toList();
  }

  @override
  List<AccountRowsCompanion> writeAccounts(List<Account> accounts) {
    return accounts
        .map(
          (Account account) => AccountModel.fromEntity(account).toCompanion(),
        )
        .toList();
  }

  @override
  List<CategoryRowsCompanion> writeCategories(List<Category> categories) {
    return categories
        .map(
          (Category category) =>
              CategoryModel.fromEntity(category).toCompanion(),
        )
        .toList();
  }

  @override
  List<SubcategoryRowsCompanion> writeSubcategories(
    List<Subcategory> subcategories,
  ) {
    return subcategories
        .map(
          (Subcategory subcategory) =>
              SubcategoryModel.fromEntity(subcategory).toCompanion(),
        )
        .toList();
  }

  @override
  List<TransactionRowsCompanion> writeTransactions(
    List<MoneyTransaction> transactions,
  ) {
    return transactions
        .map(
          (MoneyTransaction transaction) =>
              MoneyTransactionModel.fromEntity(transaction).toCompanion(),
        )
        .toList();
  }
}
