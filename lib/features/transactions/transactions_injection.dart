import 'package:get_it/get_it.dart';

import '../../core/database/finance_store.dart';
import '../accounts/data/datasources/finance_record_mapper_impl.dart';
import 'data/repositories/transactions_repository_impl.dart';
import 'domain/repositories/transactions_repository.dart';
import 'domain/usecases/delete_transaction_use_case.dart';
import 'domain/usecases/save_expense_use_case.dart';
import 'domain/usecases/save_income_use_case.dart';
import 'domain/usecases/save_transfer_use_case.dart';
import 'domain/usecases/search_transactions_use_case.dart';
import 'domain/usecases/update_transaction_use_case.dart';
import 'presentation/controller/delete_transaction/delete_transaction_cubit.dart';
import 'presentation/controller/save_expense/save_expense_cubit.dart';
import 'presentation/controller/save_income/save_income_cubit.dart';
import 'presentation/controller/save_transfer/save_transfer_cubit.dart';
import 'presentation/controller/search_transactions/search_transactions_cubit.dart';
import 'presentation/controller/update_transaction/update_transaction_cubit.dart';

void registerTransactions(GetIt sl) {
  if (!sl.isRegistered<FinanceStore>()) {
    sl.registerLazySingleton<FinanceStore>(
      () => FinanceStore(mapper: const FinanceRecordMapperImpl()),
    );
  }
  sl.registerLazySingleton<TransactionsRepository>(
    () => TransactionsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => SaveIncomeUseCase(sl()));
  sl.registerLazySingleton(() => SaveExpenseUseCase(sl()));
  sl.registerLazySingleton(() => SaveTransferUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTransactionUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTransactionUseCase(sl()));
  sl.registerLazySingleton(() => SearchTransactionsUseCase(sl()));
  sl.registerFactory(() => SaveIncomeCubit(sl()));
  sl.registerFactory(() => SaveExpenseCubit(sl()));
  sl.registerFactory(() => SaveTransferCubit(sl()));
  sl.registerFactory(() => UpdateTransactionCubit(sl()));
  sl.registerFactory(() => DeleteTransactionCubit(sl()));
  sl.registerFactory(() => SearchTransactionsCubit(sl()));
}
