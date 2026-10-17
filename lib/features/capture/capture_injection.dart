import 'package:get_it/get_it.dart';

import 'data/datasources/capture_draft_data_source.dart';
import 'data/repositories/capture_repository_impl.dart';
import 'domain/repositories/capture_repository.dart';
import 'domain/usecases/confirm_capture_draft_use_case.dart';
import 'domain/usecases/discard_capture_draft_use_case.dart';
import 'presentation/controller/confirm_capture_draft/confirm_capture_draft_cubit.dart';
import 'presentation/controller/discard_capture_draft/discard_capture_draft_cubit.dart';

void registerCaptureDataLayer(GetIt sl) {
  sl.registerLazySingleton<CaptureDraftDataSource>(
    MemoryCaptureDraftDataSource.new,
  );
  sl.registerLazySingleton<CaptureRepository>(
    () => CaptureRepositoryImpl(source: sl()),
  );
}

void registerConfirmCaptureDraft(GetIt sl) {
  sl.registerLazySingleton<ConfirmCaptureDraftUseCase>(
    () => ConfirmCaptureDraftUseCase(
      repository: sl(),
      saveIncome: sl(),
      saveExpense: sl(),
    ),
  );
  sl.registerFactory<ConfirmCaptureDraftCubit>(
    () => ConfirmCaptureDraftCubit(sl()),
  );
}

void registerDiscardCaptureDraft(GetIt sl) {
  sl.registerLazySingleton<DiscardCaptureDraftUseCase>(
    () => DiscardCaptureDraftUseCase(repository: sl()),
  );
  sl.registerFactory<DiscardCaptureDraftCubit>(
    () => DiscardCaptureDraftCubit(sl()),
  );
}
