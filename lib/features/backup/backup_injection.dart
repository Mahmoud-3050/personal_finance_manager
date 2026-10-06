import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/database/finance_store.dart';
import '../../core/di/feature_scope.dart';
import '../../core/services/network/netwok_info.dart';
import '../accounts/data/datasources/finance_record_mapper_impl.dart';
import 'data/datasources/backup_settings_data_source.dart';
import 'data/datasources/book_snapshot_data_source.dart';
import 'data/datasources/cloud_backup_data_source.dart';
import 'data/datasources/export_file_data_source.dart';
import 'data/repositories/backup_repository_impl.dart';
import 'domain/repositories/backup_repository.dart';
import 'domain/usecases/export_book_use_case.dart';
import 'domain/usecases/get_backup_status_use_case.dart';
import 'domain/usecases/import_book_use_case.dart';
import 'domain/usecases/list_cloud_copies_use_case.dart';
import 'domain/usecases/preview_import_use_case.dart';
import 'domain/usecases/restore_cloud_copy_use_case.dart';
import 'domain/usecases/run_automatic_backup_use_case.dart';
import 'domain/usecases/run_manual_backup_use_case.dart';
import 'domain/usecases/set_backup_schedule_use_case.dart';
import 'domain/usecases/sign_in_for_backup_use_case.dart';
import 'presentation/controller/export_book/export_book_cubit.dart';
import 'presentation/controller/get_backup_status/get_backup_status_cubit.dart';
import 'presentation/controller/list_cloud_copies/list_cloud_copies_cubit.dart';
import 'presentation/controller/import_book/import_book_cubit.dart';
import 'presentation/controller/preview_import/preview_import_cubit.dart';
import 'presentation/controller/restore_cloud_copy/restore_cloud_copy_cubit.dart';
import 'presentation/controller/run_automatic_backup/run_automatic_backup_cubit.dart';
import 'presentation/controller/run_manual_backup/run_manual_backup_cubit.dart';
import 'presentation/controller/set_backup_schedule/set_backup_schedule_cubit.dart';
import 'presentation/controller/sign_in_for_backup/sign_in_for_backup_cubit.dart';

void registerBackupDataLayer(GetIt sl) {
  if (!sl.isRegistered<FinanceStore>()) {
    sl.registerLazySingleton<FinanceStore>(
      () => FinanceStore(mapper: const FinanceRecordMapperImpl()),
    );
  }
  if (!sl.isRegistered<BookSnapshotDataSource>()) {
    sl.registerLazySingleton<BookSnapshotDataSource>(
      () => FinanceStoreBookSnapshotDataSource(sl()),
    );
  }
  if (!sl.isRegistered<BackupSettingsStore>()) {
    sl.registerLazySingleton<BackupSettingsStore>(
      () => BackupSettingsDataSource(
        sl<SharedPreferences>(instanceName: 'sharedPreferences'),
      ),
    );
  }
  if (!sl.isRegistered<CloudBackupDataSource>()) {
    sl.registerLazySingleton<CloudBackupDataSource>(
      FirebaseCloudBackupDataSource.new,
    );
  }
  if (!sl.isRegistered<ExportFileDataSource>()) {
    sl.registerLazySingleton<ExportFileDataSource>(
      DeviceExportFileDataSource.new,
    );
  }
  if (!sl.isRegistered<BackupRepository>()) {
    sl.registerLazySingleton<BackupRepository>(
      () => BackupRepositoryImpl(
        books: sl(),
        settings: sl(),
        cloud: sl(),
        files: sl(),
        network: sl<NetworkInfo>(),
      ),
    );
  }
}

void registerGetBackupStatus(GetIt sl) {
  sl.registerLazySingleton(() => GetBackupStatusUseCase(sl()));
  sl.registerFactory(() => GetBackupStatusCubit(sl()));
}

void registerSignInForBackup(GetIt sl) {
  sl.registerLazySingleton(() => SignInForBackupUseCase(sl()));
  sl.registerFactory(() => SignInForBackupCubit(sl()));
}

void registerRunManualBackup(GetIt sl) {
  sl.registerLazySingleton(() => RunManualBackupUseCase(sl()));
  sl.registerFactory(() => RunManualBackupCubit(sl()));
}

void registerSetBackupSchedule(GetIt sl) {
  sl.registerLazySingleton(() => SetBackupScheduleUseCase(sl()));
  sl.registerFactory(() => SetBackupScheduleCubit(sl()));
}

void registerRunAutomaticBackup(GetIt sl) {
  sl.registerLazySingleton(() => RunAutomaticBackupUseCase(sl()));
  sl.registerFactory(() => RunAutomaticBackupCubit(sl()));
}

void registerListCloudCopies(GetIt sl) {
  sl.registerLazySingleton(() => ListCloudCopiesUseCase(sl()));
  sl.registerFactory(() => ListCloudCopiesCubit(sl()));
}

void registerRestoreCloudCopy(GetIt sl) {
  sl.registerLazySingleton(() => RestoreCloudCopyUseCase(sl()));
  sl.registerFactory(() => RestoreCloudCopyCubit(sl()));
}

void registerExportBook(GetIt sl) {
  sl.registerLazySingleton(() => ExportBookUseCase(sl()));
  sl.registerFactory(() => ExportBookCubit(sl()));
}

void registerImportBook(GetIt sl) {
  sl.registerLazySingleton(() => ImportBookUseCase(sl()));
  sl.registerFactory(() => ImportBookCubit(sl()));
}

void registerPreviewImport(GetIt sl) {
  sl.registerLazySingleton(() => PreviewImportUseCase(sl()));
  sl.registerFactory(() => PreviewImportCubit(sl()));
}

const List<FeatureRegistration> backupRouteRegistrations =
    <FeatureRegistration>[
      registerBackupDataLayer,
      registerGetBackupStatus,
      registerSignInForBackup,
      registerRunManualBackup,
      registerSetBackupSchedule,
      registerListCloudCopies,
      registerRestoreCloudCopy,
      registerExportBook,
      registerImportBook,
      registerPreviewImport,
    ];
