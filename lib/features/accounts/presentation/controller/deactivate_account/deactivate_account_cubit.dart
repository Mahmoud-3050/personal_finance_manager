import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../shared/domain/finance_records.dart';
import '../../../domain/usecases/deactivate_account_use_case.dart';

part 'deactivate_account_states.dart';

class DeactivateAccountCubit extends Cubit<DeactivateAccountState> {
  DeactivateAccountCubit(this._useCase)
    : super(const ApiCallHolding<FinanceRecords>());

  final DeactivateAccountUseCase _useCase;

  Future<void> fDeactivateAccount(DeactivateAccountParams params) async {
    emit(const ApiCallLoading<FinanceRecords>());
    final result = await _useCase(params);
    result.fold(
      (failure) =>
          emit(ApiCallError<FinanceRecords>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<FinanceRecords>(data: data)),
    );
  }
}
