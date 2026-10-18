import 'package:get_it/get_it.dart';

import '../../core/services/network/netwok_info.dart';
import 'data/datasources/capture_draft_data_source.dart';
import 'data/datasources/receipt_image_data_source.dart';
import 'data/datasources/receipt_reader_data_source.dart';
import 'data/repositories/capture_repository_impl.dart';
import 'data/repositories/receipt_capture_repository_impl.dart';
import 'domain/repositories/capture_repository.dart';
import 'domain/repositories/receipt_capture_repository.dart';
import 'domain/repositories/receipt_reader.dart';
import 'domain/usecases/confirm_capture_draft_use_case.dart';
import 'domain/usecases/delete_receipt_photo_use_case.dart';
import 'domain/usecases/discard_capture_draft_use_case.dart';
import 'domain/usecases/pick_receipt_image_use_case.dart';
import 'domain/usecases/read_receipt_use_case.dart';
import 'presentation/controller/confirm_capture_draft/confirm_capture_draft_cubit.dart';
import 'presentation/controller/discard_capture_draft/discard_capture_draft_cubit.dart';
import 'presentation/controller/release_receipt_photo/release_receipt_photo_cubit.dart';
import 'presentation/controller/start_receipt_capture/start_receipt_capture_cubit.dart';

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

void registerStartReceiptCapture(GetIt sl) {
  _registerReceiptInfrastructure(sl);
  sl.registerLazySingleton<PickReceiptImageUseCase>(
    () => PickReceiptImageUseCase(repository: sl()),
  );
  sl.registerLazySingleton<ReadReceiptUseCase>(
    () => ReadReceiptUseCase(repository: sl()),
  );
  sl.registerLazySingleton<DeleteReceiptPhotoUseCase>(
    () => DeleteReceiptPhotoUseCase(repository: sl()),
  );
  sl.registerFactory<StartReceiptCaptureCubit>(
    () => StartReceiptCaptureCubit(
      pickReceiptImage: sl(),
      readReceipt: sl(),
      deleteReceiptPhoto: sl(),
    ),
  );
}

void registerReleaseReceiptPhoto(GetIt sl) {
  _registerReceiptInfrastructure(sl);
  sl.registerLazySingleton<DeleteReceiptPhotoUseCase>(
    () => DeleteReceiptPhotoUseCase(repository: sl()),
  );
  sl.registerFactory<ReleaseReceiptPhotoCubit>(
    () => ReleaseReceiptPhotoCubit(sl()),
  );
}

void _registerReceiptInfrastructure(GetIt sl) {
  sl.registerLazySingleton<ReceiptImageDataSource>(
    ReceiptImageDataSourceImpl.new,
  );
  sl.registerLazySingleton<ReceiptReader>(EmptyReceiptReader.new);
  sl.registerLazySingleton<ReceiptCaptureRepository>(
    () => ReceiptCaptureRepositoryImpl(
      images: sl(),
      reader: sl(),
      network: sl<NetworkInfo>(),
    ),
  );
}
