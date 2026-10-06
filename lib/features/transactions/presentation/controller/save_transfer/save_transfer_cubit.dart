import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../shared/domain/finance_records.dart';
import '../../../domain/usecases/save_transfer_use_case.dart';

part 'save_transfer_states.dart';

class SaveTransferCubit extends Cubit<SaveTransferState> {
  SaveTransferCubit(this._useCase)
    : super(const ApiCallHolding<FinanceRecords>());

  final SaveTransferUseCase _useCase;

  Future<void> fSaveTransfer(SaveTransferParams params) async {
    emit(const ApiCallLoading<FinanceRecords>());
    final result = await _useCase(params);
    result.fold(
      (failure) =>
          emit(ApiCallError<FinanceRecords>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<FinanceRecords>(data: data)),
    );
  }
}
