import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../shared/domain/finance_records.dart';
import '../../../domain/usecases/update_transaction_use_case.dart';

part 'update_transaction_states.dart';

class UpdateTransactionCubit extends Cubit<UpdateTransactionState> {
  UpdateTransactionCubit(this._useCase)
    : super(const ApiCallHolding<FinanceRecords>());

  final UpdateTransactionUseCase _useCase;

  Future<void> fUpdateTransaction(UpdateTransactionParams params) async {
    emit(const ApiCallLoading<FinanceRecords>());
    final result = await _useCase(params);
    result.fold(
      (failure) =>
          emit(ApiCallError<FinanceRecords>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<FinanceRecords>(data: data)),
    );
  }
}
