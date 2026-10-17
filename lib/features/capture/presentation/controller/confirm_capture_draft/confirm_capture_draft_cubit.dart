import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../shared/domain/finance_records.dart';
import '../../../domain/entities/capture_draft.dart';
import '../../../domain/usecases/confirm_capture_draft_use_case.dart';

part 'confirm_capture_draft_states.dart';

class ConfirmCaptureDraftCubit extends Cubit<ConfirmCaptureDraftState> {
  ConfirmCaptureDraftCubit(this._useCase)
    : super(const ApiCallHolding<FinanceRecords>());

  final ConfirmCaptureDraftUseCase _useCase;

  Future<void> fConfirmCaptureDraft(CaptureDraft draft) async {
    if (state.isLoading || state.isSuccess) {
      return;
    }
    emit(const ApiCallLoading<FinanceRecords>());
    final result = await _useCase(ConfirmCaptureDraftParams(draft: draft));
    result.fold(
      (failure) =>
          emit(ApiCallError<FinanceRecords>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<FinanceRecords>(data: data)),
    );
  }
}
