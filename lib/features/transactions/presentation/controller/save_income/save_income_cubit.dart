import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/presentation/api_call_state.dart';
import '../../../../../shared/domain/finance_records.dart';
import '../../../domain/usecases/save_income_use_case.dart';

part 'save_income_states.dart';

class SaveIncomeCubit extends Cubit<SaveIncomeState> {
  SaveIncomeCubit(this._useCase)
    : super(const ApiCallHolding<FinanceRecords>());

  final SaveIncomeUseCase _useCase;

  Future<void> fSaveIncome(SaveIncomeParams params) async {
    emit(const ApiCallLoading<FinanceRecords>());
    final result = await _useCase(params);
    result.fold(
      (failure) =>
          emit(ApiCallError<FinanceRecords>(message: failure.message ?? '')),
      (data) => emit(ApiCallSuccess<FinanceRecords>(data: data)),
    );
  }
}
