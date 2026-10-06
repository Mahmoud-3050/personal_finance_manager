import 'package:get_it/get_it.dart';

import '../../core/database/finance_store.dart';
import 'data/datasources/finance_record_mapper_impl.dart';
import 'data/repositories/accounts_repository_impl.dart';
import 'domain/repositories/accounts_repository.dart';
import 'domain/usecases/deactivate_account_use_case.dart';
import 'domain/usecases/delete_account_use_case.dart';
import 'domain/usecases/get_accounts_use_case.dart';
import 'domain/usecases/reactivate_account_use_case.dart';
import 'domain/usecases/save_account_use_case.dart';
import 'presentation/controller/deactivate_account/deactivate_account_cubit.dart';
import 'presentation/controller/delete_account/delete_account_cubit.dart';
import 'presentation/controller/get_accounts/get_accounts_cubit.dart';
import 'presentation/controller/reactivate_account/reactivate_account_cubit.dart';
import 'presentation/controller/save_account/save_account_cubit.dart';

void registerAccounts(GetIt sl) {
  if (!sl.isRegistered<FinanceStore>()) {
    sl.registerLazySingleton<FinanceStore>(
      () => FinanceStore(mapper: const FinanceRecordMapperImpl()),
    );
  }
  sl.registerLazySingleton<AccountsRepository>(
    () => AccountsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => SaveAccountUseCase(sl()));
  sl.registerLazySingleton(() => DeactivateAccountUseCase(sl()));
  sl.registerLazySingleton(() => ReactivateAccountUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAccountUseCase(sl()));
  sl.registerLazySingleton(() => GetAccountsUseCase(sl()));
  sl.registerFactory(() => SaveAccountCubit(sl()));
  sl.registerFactory(() => DeactivateAccountCubit(sl()));
  sl.registerFactory(() => ReactivateAccountCubit(sl()));
  sl.registerFactory(() => DeleteAccountCubit(sl()));
  sl.registerFactory(() => GetAccountsCubit(sl()));
}
