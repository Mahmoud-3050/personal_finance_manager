import 'package:get_it/get_it.dart';

import '../../core/database/finance_store.dart';
import '../accounts/data/datasources/finance_record_mapper_impl.dart';
import 'data/repositories/reports_repository_impl.dart';
import 'domain/repositories/reports_repository.dart';
import 'domain/usecases/get_report_use_case.dart';
import 'presentation/controller/get_report/get_report_cubit.dart';

void registerReports(GetIt sl) {
  if (!sl.isRegistered<FinanceStore>()) {
    sl.registerLazySingleton<FinanceStore>(
      () => FinanceStore(mapper: const FinanceRecordMapperImpl()),
    );
  }
  sl.registerLazySingleton<ReportsRepository>(
    () => ReportsRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => GetReportUseCase(sl()));
  sl.registerFactory(() => GetReportCubit(sl()));
}
