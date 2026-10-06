import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../shared/domain/finance_records.dart';
import '../../../domain/usecases/delete_transaction_use_case.dart';

part 'delete_transaction_states.dart';

class DeleteTransactionCubit extends Cubit<DeleteTransactionState> {
  DeleteTransactionCubit(this._useCase)
    : super(const ApiCallHolding<FinanceRecords>());

  final DeleteTransactionUseCase _useCase;

  Future<void> fDeleteTransaction(DeleteTransactionParams params) async {
    emit(const ApiCallLoading<FinanceRecords>());
    final result = await _useCase(params);
    result.fold(
      (failure) =>
          emit(ApiCallError<FinanceRecords>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<FinanceRecords>(data: data)),
    );
  }
}
