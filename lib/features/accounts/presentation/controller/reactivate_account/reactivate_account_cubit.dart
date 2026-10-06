import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../shared/domain/finance_records.dart';
import '../../../domain/usecases/reactivate_account_use_case.dart';

part 'reactivate_account_states.dart';

class ReactivateAccountCubit extends Cubit<ReactivateAccountState> {
  ReactivateAccountCubit(this._useCase)
    : super(const ApiCallHolding<FinanceRecords>());

  final ReactivateAccountUseCase _useCase;

  Future<void> fReactivateAccount(ReactivateAccountParams params) async {
    emit(const ApiCallLoading<FinanceRecords>());
    final result = await _useCase(params);
    result.fold(
      (failure) =>
          emit(ApiCallError<FinanceRecords>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<FinanceRecords>(data: data)),
    );
  }
}
