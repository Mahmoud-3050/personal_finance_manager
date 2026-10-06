import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../core/usecases/usecase.dart';
import '../../../domain/entities/backup_settings.dart';
import '../../../domain/usecases/sign_in_for_backup_use_case.dart';

part 'sign_in_for_backup_states.dart';

class SignInForBackupCubit extends Cubit<SignInForBackupState> {
  SignInForBackupCubit(this._useCase)
    : super(const ApiCallHolding<BackupSettings>());

  final SignInForBackupUseCase _useCase;

  Future<void> fSignInForBackup() async {
    emit(const ApiCallLoading<BackupSettings>());
    final result = await _useCase(const NoParams());
    result.fold(
      (failure) =>
          emit(ApiCallError<BackupSettings>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<BackupSettings>(data: data)),
    );
  }
}
