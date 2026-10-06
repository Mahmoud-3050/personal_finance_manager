import 'package:get_it/get_it.dart';

import '../../core/database/finance_store.dart';
import '../accounts/data/datasources/finance_record_mapper_impl.dart';
import 'data/repositories/categories_repository_impl.dart';
import 'domain/repositories/categories_repository.dart';
import 'domain/usecases/deactivate_category_use_case.dart';
import 'domain/usecases/delete_category_use_case.dart';
import 'domain/usecases/get_categories_use_case.dart';
import 'domain/usecases/save_category_use_case.dart';
import 'presentation/controller/deactivate_category/deactivate_category_cubit.dart';
import 'presentation/controller/delete_category/delete_category_cubit.dart';
import 'presentation/controller/get_categories/get_categories_cubit.dart';
import 'presentation/controller/save_category/save_category_cubit.dart';

void registerCategories(GetIt sl) {
  if (!sl.isRegistered<FinanceStore>()) {
    sl.registerLazySingleton<FinanceStore>(
      () => FinanceStore(mapper: const FinanceRecordMapperImpl()),
    );
  }
  sl.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(sl()),
  );
  sl.registerLazySingleton(() => SaveCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeactivateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetCategoriesUseCase(sl()));
  sl.registerFactory(() => SaveCategoryCubit(sl()));
  sl.registerFactory(() => DeactivateCategoryCubit(sl()));
  sl.registerFactory(() => DeleteCategoryCubit(sl()));
  sl.registerFactory(() => GetCategoriesCubit(sl()));
}
