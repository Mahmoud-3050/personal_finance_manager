import 'package:either/either.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../shared/domain/entities/account.dart';
import '../../../../shared/domain/finance_records.dart';
import '../../../../shared/domain/services/balance_calculator.dart';
import '../entities/account_list_data.dart';
import '../repositories/accounts_repository.dart';

class GetAccountsUseCase extends UseCase<AccountListData, NoParams> {
  GetAccountsUseCase(this._repository);

  final AccountsRepository _repository;

  @override
  Future<Either<Failure, AccountListData>> call(NoParams params) async {
    final Either<Failure, FinanceRecords> loaded = await _repository.load();
    return loaded.map((FinanceRecords records) {
      return AccountListData(
        records: records,
        balances: <String, int>{
          for (final Account account in records.accounts)
            account.id: accountBalanceMinor(account, records.transactions),
        },
      );
    });
  }
}
