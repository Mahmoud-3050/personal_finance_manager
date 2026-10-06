import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../shared/domain/finance_records.dart';
import '../../../domain/usecases/save_account_use_case.dart';

part 'save_account_states.dart';

class SaveAccountCubit extends Cubit<SaveAccountState> {
  SaveAccountCubit(this._useCase)
    : super(const ApiCallHolding<FinanceRecords>());

  final SaveAccountUseCase _useCase;

  Future<void> fSaveAccount(SaveAccountParams params) async {
    emit(const ApiCallLoading<FinanceRecords>());
    final result = await _useCase(params);
    result.fold(
      (failure) =>
          emit(ApiCallError<FinanceRecords>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<FinanceRecords>(data: data)),
    );
  }
}
