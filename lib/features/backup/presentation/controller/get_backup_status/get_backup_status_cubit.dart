import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/backup_settings.dart';
import '../../../domain/usecases/get_backup_status_use_case.dart';

part 'get_backup_status_states.dart';

class GetBackupStatusCubit extends Cubit<GetBackupStatusState> {
  GetBackupStatusCubit(this._useCase)
    : super(const ApiCallHolding<BackupSettings>());

  final GetBackupStatusUseCase _useCase;

  Future<void> fGetBackupStatus() async {
    emit(const ApiCallLoading<BackupSettings>());
    final result = await _useCase(const NoParams());
    result.fold(
      (failure) =>
          emit(ApiCallError<BackupSettings>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<BackupSettings>(data: data)),
    );
  }
}
