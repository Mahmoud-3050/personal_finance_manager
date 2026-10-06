import '../../shared/domain/entities/account.dart';
import '../../shared/domain/entities/category.dart';
import '../../shared/domain/entities/money_transaction.dart';
import '../../shared/domain/entities/subcategory.dart';
import 'finance_database.dart';

abstract interface class FinanceRecordMapper {
  List<Account> readAccounts(List<AccountRow> rows);

  List<Category> readCategories(List<CategoryRow> rows);

  List<Subcategory> readSubcategories(List<SubcategoryRow> rows);

  List<MoneyTransaction> readTransactions(List<TransactionRow> rows);

  List<AccountRowsCompanion> writeAccounts(List<Account> accounts);

  List<CategoryRowsCompanion> writeCategories(List<Category> categories);

  List<SubcategoryRowsCompanion> writeSubcategories(
    List<Subcategory> subcategories,
  );

  List<TransactionRowsCompanion> writeTransactions(
    List<MoneyTransaction> transactions,
  );
}
