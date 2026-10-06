import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../shared/domain/finance_records.dart';
import '../../../domain/usecases/delete_account_use_case.dart';

part 'delete_account_states.dart';

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  DeleteAccountCubit(this._useCase)
    : super(const ApiCallHolding<FinanceRecords>());

  final DeleteAccountUseCase _useCase;

  Future<void> fDeleteAccount(DeleteAccountParams params) async {
    emit(const ApiCallLoading<FinanceRecords>());
    final result = await _useCase(params);
    result.fold(
      (failure) =>
          emit(ApiCallError<FinanceRecords>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<FinanceRecords>(data: data)),
    );
  }
}
