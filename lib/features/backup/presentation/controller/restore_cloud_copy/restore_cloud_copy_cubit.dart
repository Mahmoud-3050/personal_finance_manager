import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../shared/domain/finance_records.dart';
import '../../../domain/usecases/restore_cloud_copy_use_case.dart';

part 'restore_cloud_copy_states.dart';

class RestoreCloudCopyCubit extends Cubit<RestoreCloudCopyState> {
  RestoreCloudCopyCubit(this._useCase)
    : super(const ApiCallHolding<FinanceRecords>());

  final RestoreCloudCopyUseCase _useCase;

  Future<void> fRestoreCloudCopy({
    required String copyId,
    required bool confirmed,
  }) async {
    emit(const ApiCallLoading<FinanceRecords>());
    final result = await _useCase(
      RestoreCloudCopyParams(copyId: copyId, confirmed: confirmed),
    );
    result.fold(
      (failure) =>
          emit(ApiCallError<FinanceRecords>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<FinanceRecords>(data: data)),
    );
  }
}
