import 'package:get_it/get_it.dart';

import '../../core/database/finance_store.dart';
import '../accounts/data/datasources/finance_record_mapper_impl.dart';
import 'data/repositories/dashboard_repository_impl.dart';
import 'domain/repositories/dashboard_repository.dart';
import 'domain/usecases/get_dashboard_use_case.dart';
import 'presentation/controller/get_dashboard/get_dashboard_cubit.dart';

void registerDashboard(GetIt sl) {
  if (!sl.isRegistered<FinanceStore>()) {
    sl.registerLazySingleton<FinanceStore>(
      () => FinanceStore(mapper: const FinanceRecordMapperImpl()),
    );
  }
  sl.registerLazySingleton<DashboardRepository>(
    () => DashboardRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetDashboardUseCase(sl()));
  sl.registerFactory(() => GetDashboardCubit(sl()));
}
